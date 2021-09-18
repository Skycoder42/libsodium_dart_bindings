import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../api/advanced/advanced_scalar_mult.dart';
import '../../../api/secure_key.dart';
import '../../../api/sodium_exception.dart';
import '../../bindings/libsodium.ffi.dart';
import '../../bindings/memory_protection.dart';
import '../../bindings/secure_key_native.dart';
import '../../bindings/sodium_pointer.dart';
import '../secure_key_ffi.dart';

@internal
class AdvancedScalarMultFFI
    with AdvancedScalarMultValidations
    implements AdvancedScalarMult {
  final LibSodiumFFI sodium;

  AdvancedScalarMultFFI(this.sodium);

  @override
  int get bytes => sodium.crypto_scalarmult_bytes();

  @override
  int get scalarBytes => sodium.crypto_scalarmult_scalarbytes();

  @override
  Uint8List base({required SecureKey secretKey}) {
    validateSecretKey(secretKey);
    SodiumPointer<Uint8>? outPtr;
    try {
      outPtr = SodiumPointer.alloc(
        sodium,
        count: bytes,
      );

      final result = secretKey.runUnlockedNative(
        sodium,
        (secretKeyPtr) => sodium.crypto_scalarmult_base(
          outPtr!.ptr,
          secretKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return outPtr.copyAsList();
    } finally {
      outPtr?.dispose();
    }
  }

  @override
  SecureKey call({
    required SecureKey secretKey,
    required Uint8List otherPublicKey,
  }) {
    validateSecretKey(secretKey);
    validatePublicKey(otherPublicKey);

    SecureKeyFFI? sharedSecret;
    SodiumPointer<Uint8>? publicPtr;
    try {
      sharedSecret = SecureKeyFFI.alloc(sodium, scalarBytes);
      publicPtr = otherPublicKey.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = sharedSecret.runUnlockedNative(
        (sharedSecretPtr) => secretKey.runUnlockedNative(
          sodium,
          (secretKeyPtr) => sodium.crypto_scalarmult(
            sharedSecretPtr.ptr,
            secretKeyPtr.ptr,
            publicPtr!.ptr,
          ),
        ),
        writable: true,
      );
      SodiumException.checkSucceededInt(result);

      return sharedSecret;
    } catch (e) {
      sharedSecret?.dispose();
      rethrow;
    } finally {
      publicPtr?.dispose();
    }
  }
}
