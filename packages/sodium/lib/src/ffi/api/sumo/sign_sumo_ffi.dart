import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../api/secure_key.dart';
import '../../../api/sodium_exception.dart';
import '../../../api/sumo/sign_sumo.dart';
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

      return Uint8List.fromList(publicKey.asListView());
    } finally {
      publicKey.dispose();
    }
  }
}
