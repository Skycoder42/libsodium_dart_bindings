import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../api/secure_key.dart';
import '../../../api/sodium_exception.dart';
import '../../../api/sumo/sign_sumo.dart';
import '../../bindings/memory_protection.dart';
import '../../bindings/secure_key_native.dart';
import '../../bindings/sodium_pointer.dart';
import '../secure_key_ffi.dart';
import '../sign_ffi.dart';

/// @nodoc
@internal
class SignSumoFFI extends SignFFI implements SignSumo {
  /// @nodoc
  SignSumoFFI(super.sodium);

  @override
  SecureKey skToSeed(SecureKey secretKey) {
    validateSecretKey(secretKey);

    final seed = SecureKeyFFI.alloc(sodium, seedBytes);
    try {
      final result = seed.runUnlockedNative(
        (seedPtr) => secretKey.runUnlockedNative(
          sodium,
          (secretKeyPtr) => sodium.crypto_sign_ed25519_sk_to_seed(
            seedPtr.ptr,
            secretKeyPtr.ptr,
          ),
        ),
        writable: true,
      );
      SodiumException.checkSucceededInt(result);

      return seed;
    } catch (e) {
      seed.dispose();
      rethrow;
    }
  }

  @override
  Uint8List skToPk(SecureKey secretKey) {
    validateSecretKey(secretKey);

    final publicKey = _allocatePublicKey();
    try {
      final result = secretKey.runUnlockedNative(
        sodium,
        (secretKeyPtr) => sodium.crypto_sign_ed25519_sk_to_pk(
          publicKey.ptr,
          secretKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return Uint8List.fromList(publicKey.asListView());
    } finally {
      publicKey.dispose();
    }
  }

  @override
  Uint8List pkToCurve25519(Uint8List publicKey) {
    validatePublicKey(publicKey);

    final ed25519PublicKey = publicKey.toSodiumPointer<UnsignedChar>(
      sodium,
      memoryProtection: MemoryProtection.readOnly,
    );
    final curve25519PublicKey = _allocatePublicKey();

    try {
      final result = sodium.crypto_sign_ed25519_pk_to_curve25519(
        curve25519PublicKey.ptr,
        ed25519PublicKey.ptr,
      );
      SodiumException.checkSucceededInt(result);

      return Uint8List.fromList(curve25519PublicKey.asListView());
    } finally {
      ed25519PublicKey.dispose();
      curve25519PublicKey.dispose();
    }
  }

  @override
  Uint8List skToCurve25519(SecureKey secretKey) {
    validateSecretKey(secretKey);

    final publicKey = _allocatePublicKey();
    try {
      final result = secretKey.runUnlockedNative(
        sodium,
        (secretKeyPtr) => sodium.crypto_sign_ed25519_sk_to_curve25519(
          publicKey.ptr,
          secretKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return Uint8List.fromList(publicKey.asListView());
    } finally {
      publicKey.dispose();
    }
  }

  SodiumPointer<UnsignedChar> _allocatePublicKey() =>
      SodiumPointer<UnsignedChar>.alloc(sodium, count: publicKeyBytes);
}
