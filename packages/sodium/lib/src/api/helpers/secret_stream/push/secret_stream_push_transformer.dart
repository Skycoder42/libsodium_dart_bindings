import 'dart:async';
import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meta/meta.dart';

import '../../../secret_stream.dart';
import '../../../secure_key.dart';
import 'init_push_result.dart';
import 'secret_push_stream.dart';

part 'secret_stream_push_transformer.freezed.dart';

@freezed
class _SinkState<TState extends Object> with _$_SinkState<TState> {
  const factory _SinkState.uninitialized() = _Uninitialized<TState>;

  const factory _SinkState.initialized(
    EventSink<SecretStreamCipherMessage> outSink,
    TState cryptoState,
  ) = _Initialized<TState>;

  const factory _SinkState.finalized(
    EventSink<SecretStreamCipherMessage> outSink,
  ) = _Finalized<TState>;

  const factory _SinkState.closed() = _Closed<TState>;
}

@internal
abstract class SecretStreamPushTransformerSink<TState extends Object>
    implements EventSink<SecretStreamPlainMessage> {
  _SinkState<TState> _state = const _SinkState.uninitialized();

  @protected
  void rekey(TState cryptoState);

  @protected
  void disposeState(TState cryptoState);

  @protected
  InitPushResult<TState> initialize(SecureKey key);

  @protected
  SecretStreamCipherMessage encryptMessage(
    TState cryptoState,
    SecretStreamPlainMessage event,
  );

  @nonVirtual
  void init(EventSink<SecretStreamCipherMessage> outSink, SecureKey key) =>
      _state.maybeWhen(
        uninitialized: () => _initImpl(outSink, key),
        orElse: _throwInitialized,
      );

  @nonVirtual
  void triggerRekey() => _state.when(
        initialized: (_, cryptoState) => rekey(cryptoState),
        uninitialized: _throwUninitialized,
        finalized: _throwFinalized,
        closed: _throwClosed,
      );

  @override
  @nonVirtual
  void add(SecretStreamPlainMessage event) => _state.when(
        initialized: (outSink, cryptoState) => _addImpl(
          outSink,
          cryptoState,
          event,
        ),
        uninitialized: _throwUninitialized,
        finalized: _throwFinalized,
        closed: _throwClosed,
      );

  @override
  @nonVirtual
  void addError(Object error, [StackTrace? stackTrace]) => _state
      .maybeWhen(
        initialized: (outSink, _) => outSink,
        finalized: (outSink) => outSink,
        orElse: () => null,
      )
      ?.addError(error, stackTrace);

  @override
  @nonVirtual
  void close({bool withFinalize = true}) {
    _state.when(
      initialized: (outSink, cryptoState) {
        if (withFinalize) {
          _addImpl(
            outSink,
            cryptoState,
            SecretStreamPlainMessage(
              Uint8List(0),
              tag: SecretStreamMessageTag.finalPush,
            ),
          );
          close(withFinalize: false);
        } else {
          disposeState(cryptoState);
          outSink.close();
          _state = const _SinkState.closed();
        }
      },
      finalized: (outSink) {
        outSink.close();
        _state = const _SinkState.closed();
      },
      uninitialized: () {
        _state = const _SinkState.closed();
      },
      closed: () {},
    );
  }

  void _initImpl(EventSink<SecretStreamCipherMessage> outSink, SecureKey key) {
    InitPushResult<TState>? initResult;
    try {
      initResult = initialize(key);
      outSink.add(SecretStreamCipherMessage(initResult.header));

      _state = _SinkState.initialized(
        outSink,
        initResult.state,
      );
    } catch (e, s) {
      if (initResult != null) {
        disposeState(initResult.state);
      }
      outSink.addError(e, s);
      _state = _SinkState.finalized(outSink);
    }
  }

  void _addImpl(
    EventSink<SecretStreamCipherMessage> outSink,
    TState cryptoState,
    SecretStreamPlainMessage event,
  ) {
    try {
      outSink.add(encryptMessage(cryptoState, event));

      if (event.tag == SecretStreamMessageTag.finalPush) {
        disposeState(cryptoState);
        _state = _SinkState.finalized(outSink);
      }
    } catch (e, s) {
      outSink.addError(e, s);
    }
  }

  Never _throwInitialized() => throw StateError(
        'Transformer has already been initialized',
      );

  Never _throwUninitialized() => throw StateError(
        'Transformer has not been initialized',
      );

  Never _throwFinalized(EventSink<SecretStreamCipherMessage> _) =>
      throw StateError(
        'Transformer has already received the final message',
      );

  Never _throwClosed() => throw StateError(
        'Transformer has not been initialized or was already closed',
      );
}

@internal
abstract class SecretStreamPushTransformer<TState extends Object>
    implements
        SecretExStreamTransformer<SecretStreamPlainMessage,
            SecretStreamCipherMessage> {
  final SecureKey key;

  const SecretStreamPushTransformer(this.key);

  @protected
  SecretStreamPushTransformerSink<TState> createSink();

  @override
  SecretExStream<SecretStreamCipherMessage> bind(
    Stream<SecretStreamPlainMessage> stream,
  ) {
    // ignore: close_sinks
    final transformerSink = createSink();
    final baseStream = Stream<SecretStreamCipherMessage>.eventTransformed(
      stream,
      (sink) => transformerSink..init(sink, key),
    );
    return SecretPushStream(transformerSink, baseStream);
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() => StreamTransformer.castFrom<
      SecretStreamPlainMessage, SecretStreamCipherMessage, RS, RT>(this);
}
