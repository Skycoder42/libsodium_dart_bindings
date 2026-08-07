import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:meta/meta.dart';

import '../../api/kem.dart';
import '../../api/key_pair.dart';
import '../../api/secure_key.dart';
import '../../api/sodium_exception.dart';
import '../bindings/libsodium.ffi.wrapper.dart';
import '../bindings/secure_key_native.dart';
import '../bindings/sodium_scope.dart';
import 'helpers/keygen_mixin.dart';

/// @nodoc
@internal
class KemFFI with KemValidations, KeygenMixin implements Kem {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  KemFFI(this.sodium);

  @override
  int get publicKeyBytes => sodium.crypto_kem_publickeybytes();

  @override
  int get secretKeyBytes => sodium.crypto_kem_secretkeybytes();

  @override
  int get ciphertextBytes => sodium.crypto_kem_ciphertextbytes();

  @override
  int get sharedSecretBytes => sodium.crypto_kem_sharedsecretbytes();

  @override
  int get seedBytes => sodium.crypto_kem_seedbytes();

  @override
  String get primitive =>
      sodium.crypto_kem_primitive().cast<Utf8>().toDartString();

  @override
  KeyPair keyPair() => keyPairImpl(
    sodium: sodium,
    secretKeyBytes: secretKeyBytes,
    publicKeyBytes: publicKeyBytes,
    implementation: sodium.crypto_kem_keypair,
  );

  @override
  KeyPair seedKeyPair(SecureKey seed) {
    validateSeed(seed);
    return seedKeyPairImpl(
      sodium: sodium,
      seed: seed,
      secretKeyBytes: secretKeyBytes,
      publicKeyBytes: publicKeyBytes,
      implementation: sodium.crypto_kem_seed_keypair,
    );
  }

  @override
  KemEncResult enc({required Uint8List publicKey}) {
    validatePublicKey(publicKey);

    return sodiumScope(sodium, (scope) {
      final ctPtr = scope.alloc<UnsignedChar>(ciphertextBytes);
      final ssKey = scope.allocSecureKey(sharedSecretBytes);
      final pkPtr = scope.copyList<UnsignedChar>(publicKey);

      final result = ssKey.runUnlockedNative(
        (ssPtr) => sodium.crypto_kem_enc(ctPtr.ptr, ssPtr.ptr, pkPtr.ptr),
        writable: true,
      );
      SodiumException.checkSucceededInt(result);

      return (
        ciphertext: scope.takeBytes<Uint8List>(ctPtr),
        sharedSecret: scope.takeSecureKey(ssKey),
      );
    });
  }

  @override
  SecureKey dec({required Uint8List ciphertext, required SecureKey secretKey}) {
    validateCiphertext(ciphertext);
    validateSecretKey(secretKey);

    return sodiumScope(sodium, (scope) {
      final ssKey = scope.allocSecureKey(sharedSecretBytes);
      final ctPtr = scope.copyList<UnsignedChar>(ciphertext);

      final result = ssKey.runUnlockedNative(
        (ssPtr) => secretKey.runUnlockedNative(
          sodium,
          (skPtr) => sodium.crypto_kem_dec(ssPtr.ptr, ctPtr.ptr, skPtr.ptr),
        ),
        writable: true,
      );
      SodiumException.checkSucceededInt(result);

      return scope.takeSecureKey(ssKey);
    });
  }
}
