import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:meta/meta.dart';

import '../../api/kem.dart';
import '../../api/key_pair.dart';
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

    SodiumPointer<UnsignedChar>? ctPtr;
    SecureKeyFFI? ssKey;
    SodiumPointer<UnsignedChar>? pkPtr;
    try {
      ctPtr = SodiumPointer.alloc(sodium, count: ciphertextBytes);
      ssKey = SecureKeyFFI.alloc(sodium, sharedSecretBytes);
      pkPtr = publicKey.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = ssKey.runUnlockedNative(
        (ssPtr) => sodium.crypto_kem_enc(ctPtr!.ptr, ssPtr.ptr, pkPtr!.ptr),
        writable: true,
      );
      SodiumException.checkSucceededInt(result);

      return (ciphertext: ctPtr.asListView(owned: true), sharedSecret: ssKey);
    } catch (_) {
      ctPtr?.dispose();
      ssKey?.dispose();
      rethrow;
    } finally {
      pkPtr?.dispose();
    }
  }

  @override
  SecureKey dec({required Uint8List ciphertext, required SecureKey secretKey}) {
    validateCiphertext(ciphertext);
    validateSecretKey(secretKey);

    SecureKeyFFI? ssKey;
    SodiumPointer<UnsignedChar>? ctPtr;
    try {
      ssKey = SecureKeyFFI.alloc(sodium, sharedSecretBytes);
      ctPtr = ciphertext.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = ssKey.runUnlockedNative(
        (ssPtr) => secretKey.runUnlockedNative(
          sodium,
          (skPtr) => sodium.crypto_kem_dec(ssPtr.ptr, ctPtr!.ptr, skPtr.ptr),
        ),
        writable: true,
      );
      SodiumException.checkSucceededInt(result);

      return ssKey;
    } catch (_) {
      ssKey?.dispose();
      rethrow;
    } finally {
      ctPtr?.dispose();
    }
  }
}
