import 'dart:async';
import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../secret_stream.dart';
import '../../../secure_key.dart';
import 'secret_pull_stream.dart';

part 'secret_stream_pull_transformer.freezed.dart';

@freezed
class _SinkState<TState extends Object> with _$SinkState<TState> {
  const factory _SinkState.uninitialized() = _Uninitialized<TState>;

  const factory _SinkState.preInit(
    EventSink<SecretStreamPlainMessage> outSink,
    SecureKey key,
  ) = _PreInit<TState>;

  const factory _SinkState.postInit(
    EventSink<SecretStreamPlainMessage> outSink,
    TState cryptoState,
  ) = _PostInit<TState>;

  const factory _SinkState.finalized(
    EventSink<SecretStreamPlainMessage> outSink,
  ) = _Finalized<TState>;

  const factory _SinkState.closed() = _Closed<TState>;
}

/// @nodoc
@internal
abstract class SecretStreamPullTransformerSink<TState extends Object>
    implements EventSink<SecretStreamCipherMessage> {
  /// @nodoc
  final bool requireFinalized;

  _SinkState<TState> _state = const _SinkState.uninitialized();

  /// @nodoc
  SecretStreamPullTransformerSink(
    // ignore: avoid_positional_boolean_parameters
    this.requireFinalized,
  );

  /// @nodoc
  @protected
  int get headerBytes;

  /// @nodoc
  @protected
  void rekey(TState cryptoState);

  /// @nodoc
  @protected
  void disposeState(TState cryptoState);

  /// @nodoc
  @protected
  TState initialize(
    SecureKey key,
    Uint8List header,
  );

  /// @nodoc
  @protected
  SecretStreamPlainMessage decryptMessage(
    TState cryptoState,
    SecretStreamCipherMessage event,
  );

  /// @nodoc
  @nonVirtual
  void init(EventSink<SecretStreamPlainMessage> sink, SecureKey key) =>
      _state.maybeWhen(
        uninitialized: () {
          _state = _SinkState.preInit(sink, key.copy());
          return null;
        },
        orElse: _throwInitialized,
      );

  /// @nodoc
  @nonVirtual
  void triggerRekey() => _state.when(
        postInit: (_, cryptoState) => rekey(cryptoState),
        uninitialized: _throwUninitialized,
        preInit: _throwPreInit,
        finalized: _throwFinalized,
        closed: _throwClosed,
      );

  @override
  @nonVirtual
  void add(SecretStreamCipherMessage event) => _state.when(
        preInit: (outSink, key) => _addHeader(outSink, key, event.message),
        postInit: (outSink, cryptoState) => _addMessage(
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
        preInit: (outSink, _) => outSink,
        postInit: (outSink, _) => outSink,
        finalized: (outSink) => outSink,
        orElse: () => null,
      )
      ?.addError(error, stackTrace);

  @override
  @nonVirtual
  void close() {
    _state.when(
      preInit: (outSink, key) {
        key.dispose();
        outSink.close();
        _state = const _SinkState.closed();
      },
      postInit: (outSink, cryptoState) {
        if (requireFinalized) {
          outSink.addError(StreamClosedEarlyException());
        }
        disposeState(cryptoState);
        outSink.close();
        _state = const _SinkState.closed();
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

  void _addHeader(
    EventSink<SecretStreamPlainMessage> outSink,
    SecureKey key,
    Uint8List header,
  ) {
    TState? cryptoState;
    try {
      if (header.length != headerBytes) {
        throw InvalidHeaderException(headerBytes, header.length);
      }

      cryptoState = initialize(key, header);
      _state = _SinkState.postInit(outSink, cryptoState);
    } catch (e, s) {
      if (cryptoState != null) {
        disposeState(cryptoState);
      }
      outSink.addError(e, s);
      _state = _SinkState.finalized(outSink);
      return;
    } finally {
      key.dispose();
    }
  }

  void _addMessage(
    EventSink<SecretStreamPlainMessage> outSink,
    TState cryptoState,
    SecretStreamCipherMessage event,
  ) {
    try {
      final plainMessage = decryptMessage(cryptoState, event);
      outSink.add(plainMessage);

      if (plainMessage.tag == SecretStreamMessageTag.finalPush) {
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

  Never _throwPreInit(EventSink<SecretStreamPlainMessage> _, SecureKey __) =>
      throw StateError(
        'Transformer has not received the header yet',
      );

  Never _throwFinalized(EventSink<SecretStreamPlainMessage> _) =>
      throw StateError(
        'Transformer has already received the final message',
      );

  Never _throwClosed() => throw StateError(
        'Transformer has not been initialized or was already closed',
      );
}

/// @nodoc
@internal
abstract class SecretStreamPullTransformer<TState extends Object>
    implements
        SecretExStreamTransformer<SecretStreamCipherMessage,
            SecretStreamPlainMessage> {
  /// @nodoc
  final SecureKey key;

  /// @nodoc
  final bool requireFinalized;

  /// @nodoc
  const SecretStreamPullTransformer(
    this.key,
    // ignore: avoid_positional_boolean_parameters
    this.requireFinalized,
  );

  /// @nodoc
  @protected
  // ignore: avoid_positional_boolean_parameters
  SecretStreamPullTransformerSink<TState> createSink(bool requireFinalized);

  @override
  SecretExStream<SecretStreamPlainMessage> bind(
    Stream<SecretStreamCipherMessage> stream,
  ) {
    // ignore: close_sinks
    final transformerSink = createSink(requireFinalized);
    final baseStream = Stream<SecretStreamPlainMessage>.eventTransformed(
      stream,
      (sink) => transformerSink..init(sink, key),
    );
    return SecretPullStream(transformerSink, baseStream);
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() => StreamTransformer.castFrom<
      SecretStreamCipherMessage, SecretStreamPlainMessage, RS, RT>(this);
}
