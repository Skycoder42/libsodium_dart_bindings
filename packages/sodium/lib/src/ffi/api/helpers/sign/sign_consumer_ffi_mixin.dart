import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../../api/sodium_exception.dart';
import '../../../bindings/libsodium.ffi.dart';
import '../../../bindings/memory_protection.dart';
import '../../../bindings/sodium_pointer.dart';

/// @nodoc
@internal
mixin SignConsumerFFIMixin<T extends Object>
    implements StreamConsumer<Uint8List>, Sink<Uint8List> {
  /// @nodoc
  LibSodiumFFI get sodium;

  final _signatureCompleter = Completer<T>();
  late final SodiumPointer<UnsignedChar> _state;

  /// @nodoc
  @protected
  Future<T> get result => _signatureCompleter.future;

  /// @nodoc
  @protected
  T finalize(SodiumPointer<UnsignedChar> state);

  /// @nodoc
  @protected
  void initState() {
    _state = SodiumPointer.alloc(
      sodium,
      count: sodium.crypto_sign_statebytes(),
      zeroMemory: true,
    );

    try {
      final result = sodium.crypto_sign_init(_state.ptr.cast());
      SodiumException.checkSucceededInt(result);
    } catch (e) {
      _state.dispose();
      rethrow;
    }
  }

  @override
  void add(Uint8List data) {
    _ensureNotCompleted();

    SodiumPointer<UnsignedChar>? messagePtr;
    try {
      messagePtr = data.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = sodium.crypto_sign_update(
        _state.ptr.cast(),
        messagePtr.ptr,
        messagePtr.count,
      );
      SodiumException.checkSucceededInt(result);
    } finally {
      messagePtr?.dispose();
    }
  }

  @override
  Future<void> addStream(Stream<Uint8List> stream) {
    _ensureNotCompleted();
    return stream.map(add).drain<void>();
  }

  @override
  Future<T> close() {
    _ensureNotCompleted();

    try {
      final result = finalize(_state);
      _signatureCompleter.complete(result);
    } catch (e, s) {
      _signatureCompleter.completeError(e, s);
    } finally {
      _state.dispose();
    }

    return _signatureCompleter.future;
  }

  void _ensureNotCompleted() {
    if (_signatureCompleter.isCompleted) {
      throw StateError('Signature has already been finalized');
    }
  }
}
