import 'dart:ffi';

import 'package:meta/meta.dart';

import '../../api/kdf.dart';
import '../../api/secure_key.dart';
import '../../api/sodium_exception.dart';
import '../bindings/libsodium.ffi.wrapper.dart';
import '../bindings/memory_protection.dart';
import '../bindings/secure_key_native.dart';
import '../bindings/sodium_pointer.dart';
import 'helpers/keygen_mixin.dart';
import 'secure_key_ffi.dart';

/// @nodoc
@internal
class KdfFFI with KdfValidations, KeygenMixin implements Kdf {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  KdfFFI(this.sodium);

  @override
  int get bytesMin => sodium.crypto_kdf_bytes_min();

  @override
  int get bytesMax => sodium.crypto_kdf_bytes_max();

  @override
  int get contextBytes => sodium.crypto_kdf_contextbytes();

  @override
  int get keyBytes => sodium.crypto_kdf_keybytes();

  @override
  SecureKey keygen() => keygenImpl(
    sodium: sodium,
    keyBytes: keyBytes,
    implementation: sodium.crypto_kdf_keygen,
  );

  @override
  SecureKey deriveFromKey({
    required SecureKey masterKey,
    required String context,
    required BigInt subkeyId,
    required int subkeyLen,
  }) {
    validateMasterKey(masterKey);
    validateContext(context);
    validateSubkeyLen(subkeyLen);

    SecureKeyFFI? subKey;
    SodiumPointer<Char>? contextPtr;
    try {
      subKey = SecureKeyFFI.alloc(sodium, subkeyLen);
      contextPtr = context.toSodiumPointer(
        sodium,
        memoryWidth: contextBytes,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = subKey.runUnlockedNative(
        (subKeyPtr) => masterKey.runUnlockedNative(
          sodium,
          (masterKeyPtr) => sodium.crypto_kdf_derive_from_key(
            subKeyPtr.ptr,
            subKeyPtr.count,
            subkeyId.toSigned(64).toInt(),
            contextPtr!.ptr,
            masterKeyPtr.ptr,
          ),
        ),
        writable: true,
      );
      SodiumException.checkSucceededInt(result);

      return subKey;
    } catch (e) {
      subKey?.dispose();
      rethrow;
    } finally {
      contextPtr?.dispose();
    }
  }
}
