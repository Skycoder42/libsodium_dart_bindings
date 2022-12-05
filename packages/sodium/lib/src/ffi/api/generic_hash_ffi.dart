import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/generic_hash.dart';
import '../../api/secure_key.dart';
import '../../api/sodium_exception.dart';
import '../bindings/libsodium.ffi.dart';
import '../bindings/memory_protection.dart';
import '../bindings/secure_key_native.dart';
import '../bindings/sodium_pointer.dart';
import 'helpers/generic_hash/generic_hash_consumer_ffi.dart';
import 'helpers/keygen_mixin.dart';

/// @nodoc
@internal
class GenericHashFFI
    with GenericHashValidations, KeygenMixin
    implements GenericHash {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  GenericHashFFI(this.sodium);

  @override
  int get bytes => sodium.crypto_generichash_bytes();

  @override
  int get bytesMin => sodium.crypto_generichash_bytes_min();

  @override
  int get bytesMax => sodium.crypto_generichash_bytes_max();

  @override
  int get keyBytes => sodium.crypto_generichash_keybytes();

  @override
  int get keyBytesMin => sodium.crypto_generichash_keybytes_min();

  @override
  int get keyBytesMax => sodium.crypto_generichash_keybytes_max();

  @override
  SecureKey keygen() => keygenImpl(
        sodium: sodium,
        keyBytes: keyBytes,
        implementation: sodium.crypto_generichash_keygen,
      );

  @override
  @pragma('vm:entry-point')
  Uint8List call({
    required Uint8List message,
    int? outLen,
    SecureKey? key,
  }) {
    if (outLen != null) {
      validateOutLen(outLen);
    }
    if (key != null) {
      validateKey(key);
    }

    SodiumPointer<UnsignedChar>? outPtr;
    SodiumPointer<UnsignedChar>? inPtr;
    try {
      outPtr = SodiumPointer.alloc(
        sodium,
        count: outLen ?? bytes,
      );
      inPtr = message.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = key.runMaybeUnlockedNative(
        sodium,
        (keyPtr) => sodium.crypto_generichash(
          outPtr!.ptr,
          outPtr.count,
          inPtr!.ptr,
          inPtr.count,
          keyPtr?.ptr ?? nullptr,
          keyPtr?.count ?? 0,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return Uint8List.fromList(outPtr.asListView());
    } finally {
      outPtr?.dispose();
      inPtr?.dispose();
    }
  }

  @override
  GenericHashConsumer createConsumer({
    int? outLen,
    SecureKey? key,
  }) {
    if (outLen != null) {
      validateOutLen(outLen);
    }
    if (key != null) {
      validateKey(key);
    }

    return GenericHashConsumerFFI(
      sodium: sodium,
      outLen: outLen ?? bytes,
      key: key,
    );
  }
}
