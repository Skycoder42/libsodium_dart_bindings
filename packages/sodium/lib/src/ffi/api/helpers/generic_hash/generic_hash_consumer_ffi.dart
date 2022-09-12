import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../../api/generic_hash.dart';
import '../../../../api/secure_key.dart';
import '../../../../api/sodium_exception.dart';
import '../../../bindings/libsodium.ffi.dart';
import '../../../bindings/memory_protection.dart';
import '../../../bindings/secure_key_native.dart';
import '../../../bindings/sodium_pointer.dart';

/// @nodoc
@internal
class GenericHashConsumerFFI implements GenericHashConsumer {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  final int outLen;

  final _hashCompleter = Completer<Uint8List>();
  late final SodiumPointer<Uint8> _state;

  @override
  Future<Uint8List> get hash => _hashCompleter.future;

  /// @nodoc
  GenericHashConsumerFFI({
    required this.sodium,
    required this.outLen,
    SecureKey? key,
  }) {
    _state = SodiumPointer.alloc(
      sodium,
      count: sodium.crypto_generichash_statebytes(),
      zeroMemory: true,
    );

    try {
      final result = key.runMaybeUnlockedNative(
        sodium,
        (keyPtr) => sodium.crypto_generichash_init(
          _state.ptr.cast(),
          keyPtr?.ptr ?? nullptr,
          keyPtr?.count ?? 0,
          outLen,
        ),
      );
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

      final result = sodium.crypto_generichash_update(
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
  Future addStream(Stream<Uint8List> stream) {
    _ensureNotCompleted();
    return stream.map(add).drain<void>();
  }

  @override
  Future<Uint8List> close() {
    _ensureNotCompleted();

    SodiumPointer<UnsignedChar>? outPtr;
    try {
      outPtr = SodiumPointer<UnsignedChar>.alloc(
        sodium,
        count: outLen,
        zeroMemory: true,
      );

      final result = sodium.crypto_generichash_final(
        _state.ptr.cast(),
        outPtr.ptr,
        outPtr.count,
      );
      SodiumException.checkSucceededInt(result);

      _hashCompleter.complete(Uint8List.fromList(outPtr.asListView()));
    } catch (e, s) {
      _hashCompleter.completeError(e, s);
    } finally {
      outPtr?.dispose();
      _state.dispose();
    }

    return _hashCompleter.future;
  }

  void _ensureNotCompleted() {
    if (_hashCompleter.isCompleted) {
      throw StateError('Hash has already been finalized');
    }
  }
}
