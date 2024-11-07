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
class SignSumoFFI extends SignFFI with SignSumoValidations implements SignSumo {
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

    final publicKey =
        SodiumPointer<UnsignedChar>.alloc(sodium, count: publicKeyBytes);
    try {
      final result = secretKey.runUnlockedNative(
        sodium,
        (secretKeyPtr) => sodium.crypto_sign_ed25519_sk_to_pk(
          publicKey.ptr,
          secretKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return publicKey.asListView(owned: true);
    } catch (_) {
      publicKey.dispose();
      rethrow;
    }
  }

  @override
  Uint8List pkToCurve25519(Uint8List publicKey) {
    validatePublicKey(publicKey);

    SodiumPointer<UnsignedChar>? x25519PublicKeyPtr;
    SodiumPointer<UnsignedChar>? ed25519PublicKeyPtr;
    try {
      x25519PublicKeyPtr = SodiumPointer<UnsignedChar>.alloc(
        sodium,
        count: sodium.crypto_scalarmult_curve25519_bytes(),
      );
      ed25519PublicKeyPtr = publicKey.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      final result = sodium.crypto_sign_ed25519_pk_to_curve25519(
        x25519PublicKeyPtr.ptr,
        ed25519PublicKeyPtr.ptr,
      );
      SodiumException.checkSucceededInt(result);

      return x25519PublicKeyPtr.asListView(owned: true);
    } catch (_) {
      x25519PublicKeyPtr?.dispose();
      rethrow;
    } finally {
      ed25519PublicKeyPtr?.dispose();
    }
  }

  @override
  SecureKey skToCurve25519(SecureKey secretKey) {
    validateSecretKeyOrSeed(secretKey);

    final x25519SecretKey = SecureKeyFFI.alloc(
      sodium,
      sodium.crypto_scalarmult_curve25519_bytes(),
    );
    try {
      final result = x25519SecretKey.runUnlockedNative(
        (x25519SecretKeyPtr) => secretKey.runUnlockedNative(
          sodium,
          (secretKeyPtr) => sodium.crypto_sign_ed25519_sk_to_curve25519(
            x25519SecretKeyPtr.ptr,
            secretKeyPtr.ptr,
          ),
        ),
        writable: true,
      );
      SodiumException.checkSucceededInt(result);

      return x25519SecretKey;
    } catch (e) {
      x25519SecretKey.dispose();
      rethrow;
    }
  }
}
