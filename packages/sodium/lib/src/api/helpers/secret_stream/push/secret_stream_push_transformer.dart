import 'dart:async';
import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../secret_stream.dart';
import '../../../secure_key.dart';
import 'init_push_result.dart';
import 'secret_push_stream.dart';

part 'secret_stream_push_transformer.freezed.dart';

@freezed
sealed class _SinkState<TState extends Object> with _$SinkState<TState> {
  const factory _SinkState.uninitialized() = _Uninitialized<TState>;

  const factory _SinkState.initialized(
    EventSink<SecretStreamCipherMessage> outSink,
    TState cryptoState,
    Uint8List? pendingHeader,
  ) = _Initialized<TState>;

  const factory _SinkState.finalized(
    EventSink<SecretStreamCipherMessage> outSink,
  ) = _Finalized<TState>;

  const factory _SinkState.closed() = _Closed<TState>;
}

/// @nodoc
@internal
abstract class SecretStreamPushTransformerSink<TState extends Object>
    implements EventSink<SecretStreamPlainMessage> {
  _SinkState<TState> _state = const _SinkState.uninitialized();

  /// @nodoc
  @protected
  void rekey(TState cryptoState);

  /// @nodoc
  @protected
  void disposeState(TState cryptoState);

  /// @nodoc
  @protected
  InitPushResult<TState> initialize(SecureKey key);

  /// @nodoc
  @protected
  SecretStreamCipherMessage encryptMessage(
    TState cryptoState,
    SecretStreamPlainMessage event,
  );

  /// @nodoc
  @nonVirtual
  void init(EventSink<SecretStreamCipherMessage> outSink, SecureKey key) =>
      _state.maybeWhen(
        uninitialized: () => _initImpl(outSink, key),
        orElse: _throwInitialized,
      );

  /// @nodoc
  @nonVirtual
  void triggerRekey() => _state.when(
        initialized: (_, cryptoState, __) => rekey(cryptoState),
        uninitialized: _throwUninitialized,
        finalized: _throwFinalized,
        closed: _throwClosed,
      );

  @override
  @nonVirtual
  void add(SecretStreamPlainMessage event) => _state.when(
        initialized: (outSink, cryptoState, pendingHeader) => _addImpl(
          outSink,
          cryptoState,
          pendingHeader,
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
        initialized: (outSink, _, __) => outSink,
        finalized: (outSink) => outSink,
        orElse: () => null,
      )
      ?.addError(error, stackTrace);

  @override
  @nonVirtual
  void close({bool withFinalize = true}) {
    _state.when(
      initialized: (outSink, cryptoState, pendingHeader) {
        if (withFinalize) {
          _addImpl(
            outSink,
            cryptoState,
            pendingHeader,
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
    try {
      final initResult = initialize(key);
      _state = _SinkState.initialized(
        outSink,
        initResult.state,
        initResult.header,
      );
    } catch (e, s) {
      outSink.addError(e, s);
      _state = _SinkState.finalized(outSink);
    }
  }

  void _addImpl(
    EventSink<SecretStreamCipherMessage> outSink,
    TState cryptoState,
    Uint8List? pendingHeader,
    SecretStreamPlainMessage event,
  ) {
    try {
      if (pendingHeader != null) {
        outSink.add(SecretStreamCipherMessage(pendingHeader));
        _state = _SinkState.initialized(outSink, cryptoState, null);
      }
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

/// @nodoc
@internal
abstract class SecretStreamPushTransformer<TState extends Object>
    implements
        SecretExStreamTransformer<SecretStreamPlainMessage,
            SecretStreamCipherMessage> {
  /// @nodoc
  final SecureKey key;

  /// @nodoc
  const SecretStreamPushTransformer(this.key);

  /// @nodoc
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
