import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../api/secure_key.dart';
import '../../../api/sodium_exception.dart';
import '../../../api/sumo/sign_sumo.dart';
import '../../bindings/secure_key_native.dart';
import '../../bindings/sodium_scope.dart';
import '../sign_ffi.dart';

/// @nodoc
@internal
class SignSumoFFI extends SignFFI with SignSumoValidations implements SignSumo {
  /// @nodoc
  SignSumoFFI(super.sodium);

  @override
  SecureKey skToSeed(SecureKey secretKey) {
    validateSecretKey(secretKey);

    return sodiumScope(sodium, (scope) {
      final seed = scope.allocSecureKey(seedBytes);

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

      return scope.takeSecureKey(seed);
    });
  }

  @override
  Uint8List skToPk(SecureKey secretKey) {
    validateSecretKey(secretKey);

    return sodiumScope(sodium, (scope) {
      final publicKey = scope.alloc<UnsignedChar>(publicKeyBytes);

      final result = secretKey.runUnlockedNative(
        sodium,
        (secretKeyPtr) => sodium.crypto_sign_ed25519_sk_to_pk(
          publicKey.ptr,
          secretKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return scope.takeBytes(publicKey);
    });
  }

  @override
  Uint8List pkToCurve25519(Uint8List publicKey) {
    validatePublicKey(publicKey);

    return sodiumScope(sodium, (scope) {
      final x25519PublicKeyPtr = scope.alloc<UnsignedChar>(
        sodium.crypto_scalarmult_curve25519_bytes(),
      );
      final ed25519PublicKeyPtr = scope.copyList<UnsignedChar>(publicKey);

      final result = sodium.crypto_sign_ed25519_pk_to_curve25519(
        x25519PublicKeyPtr.ptr,
        ed25519PublicKeyPtr.ptr,
      );
      SodiumException.checkSucceededInt(result);

      return scope.takeBytes(x25519PublicKeyPtr);
    });
  }

  @override
  SecureKey skToCurve25519(SecureKey secretKey) {
    validateSecretKeyOrSeed(secretKey);

    return sodiumScope(sodium, (scope) {
      final x25519SecretKey = scope.allocSecureKey(
        sodium.crypto_scalarmult_curve25519_bytes(),
      );

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

      return scope.takeSecureKey(x25519SecretKey);
    });
  }
}
