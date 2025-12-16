import 'dart:async';
import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../secret_stream.dart';
import '../../../secure_key.dart';
import 'secret_pull_stream.dart';

part 'secret_stream_pull_transformer.freezed.dart';

@freezed
sealed class _SinkState<TState extends Object> with _$SinkState<TState> {
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
    // ignore: avoid_positional_boolean_parameters for single param
    this.requireFinalized,
  );

  /// @nodoc
  @protected
  @visibleForTesting
  int get headerBytes;

  /// @nodoc
  @protected
  @visibleForTesting
  void rekey(TState cryptoState);

  /// @nodoc
  @protected
  @visibleForTesting
  void disposeState(TState cryptoState);

  /// @nodoc
  @protected
  @visibleForTesting
  TState initialize(SecureKey key, Uint8List header);

  /// @nodoc
  @protected
  @visibleForTesting
  SecretStreamPlainMessage decryptMessage(
    TState cryptoState,
    SecretStreamCipherMessage event,
  );

  /// @nodoc
  @nonVirtual
  void init(EventSink<SecretStreamPlainMessage> sink, SecureKey key) =>
      switch (_state) {
        _Uninitialized() => _state = _SinkState.preInit(sink, key.copy()),
        _ => _throwInitialized(),
      };

  /// @nodoc
  @nonVirtual
  void triggerRekey() => switch (_state) {
    _PostInit(:final cryptoState) => rekey(cryptoState),
    _Uninitialized() => _throwUninitialized(),
    _PreInit() => _throwPreInit(),
    _Finalized() => _throwFinalized(),
    _Closed() => _throwClosed(),
  };

  @override
  @nonVirtual
  void add(SecretStreamCipherMessage event) => switch (_state) {
    _PreInit(:final outSink, :final key) => _addHeader(
      outSink,
      key,
      event.message,
    ),
    _PostInit(:final outSink, :final cryptoState) => _addMessage(
      outSink,
      cryptoState,
      event,
    ),
    _Uninitialized() => _throwUninitialized(),
    _Finalized() => _throwFinalized(),
    _Closed() => _throwClosed(),
  };

  @override
  @nonVirtual
  void addError(Object error, [StackTrace? stackTrace]) => switch (_state) {
    _PreInit(:final outSink) ||
    _PostInit(:final outSink) ||
    _Finalized(:final outSink) => outSink.addError(error, stackTrace),
    _ => null,
  };

  @override
  @nonVirtual
  void close() {
    switch (_state) {
      case _PreInit(:final outSink, :final key):
        key.dispose();
        outSink.close();
        _state = const _SinkState.closed();
      case _PostInit(:final outSink, :final cryptoState):
        if (requireFinalized) {
          outSink.addError(StreamClosedEarlyException());
        }
        disposeState(cryptoState);
        outSink.close();
        _state = const _SinkState.closed();
      case _Finalized(:final outSink):
        outSink.close();
        _state = const _SinkState.closed();
      case _Uninitialized():
        _state = const _SinkState.closed();
      case _Closed():
        break;
    }
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

  Never _throwInitialized() =>
      throw StateError('Transformer has already been initialized');

  Never _throwUninitialized() =>
      throw StateError('Transformer has not been initialized');

  Never _throwPreInit() =>
      throw StateError('Transformer has not received the header yet');

  Never _throwFinalized() =>
      throw StateError('Transformer has already received the final message');

  Never _throwClosed() => throw StateError(
    'Transformer has not been initialized or was already closed',
  );
}

/// @nodoc
@internal
abstract class SecretStreamPullTransformer<TState extends Object>
    implements
        SecretExStreamTransformer<
          SecretStreamCipherMessage,
          SecretStreamPlainMessage
        > {
  /// @nodoc
  final SecureKey key;

  /// @nodoc
  final bool requireFinalized;

  /// @nodoc
  const SecretStreamPullTransformer(
    this.key,
    // ignore: avoid_positional_boolean_parameters for single param
    this.requireFinalized,
  );

  /// @nodoc
  @protected
  @visibleForTesting
  // ignore: avoid_positional_boolean_parameters for single param
  SecretStreamPullTransformerSink<TState> createSink(bool requireFinalized);

  @override
  SecretExStream<SecretStreamPlainMessage> bind(
    Stream<SecretStreamCipherMessage> stream,
  ) {
    // ignore: close_sinks is returned by method
    final transformerSink = createSink(requireFinalized);
    final baseStream = Stream<SecretStreamPlainMessage>.eventTransformed(
      stream,
      (sink) => transformerSink..init(sink, key),
    );
    return SecretPullStream(transformerSink, baseStream);
  }

  @override
  StreamTransformer<RS, RT> cast<RS, RT>() =>
      StreamTransformer.castFrom<
        SecretStreamCipherMessage,
        SecretStreamPlainMessage,
        RS,
        RT
      >(this);
}
