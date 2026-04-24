// ignore_for_file: unnecessary_lambdas to catch member access errors

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/kem.dart';
import '../../api/key_pair.dart';
import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart' hide KemEncResult, KeyPair;
import 'secure_key_js.dart';

/// @nodoc
@internal
class KemJS with KemValidations implements Kem {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  KemJS(this.sodium);

  @override
  int get publicKeyBytes => sodium.crypto_kem_PUBLICKEYBYTES;

  @override
  int get secretKeyBytes => sodium.crypto_kem_SECRETKEYBYTES;

  @override
  int get ciphertextBytes => sodium.crypto_kem_CIPHERTEXTBYTES;

  @override
  int get sharedSecretBytes => sodium.crypto_kem_SHAREDSECRETBYTES;

  @override
  int get seedBytes => sodium.crypto_kem_SEEDBYTES;

  @override
  String get primitive => sodium.crypto_kem_primitive();

  @override
  KeyPair keyPair() {
    final keyPair = jsErrorWrap(() => sodium.crypto_kem_keypair());

    return KeyPair(
      publicKey: keyPair.publicKey.toDart,
      secretKey: SecureKeyJS(sodium, keyPair.privateKey),
    );
  }

  @override
  KeyPair seedKeyPair(SecureKey seed) {
    validateSeed(seed);

    final keyPair = jsErrorWrap(
      () => seed.runUnlockedSync(
        (seedData) => sodium.crypto_kem_seed_keypair(seedData.toJS),
      ),
    );

    return KeyPair(
      publicKey: keyPair.publicKey.toDart,
      secretKey: SecureKeyJS(sodium, keyPair.privateKey),
    );
  }

  @override
  KemEncResult enc({required Uint8List publicKey}) {
    validatePublicKey(publicKey);

    final result = jsErrorWrap(() => sodium.crypto_kem_enc(publicKey.toJS));

    return (
      ciphertext: result.ciphertext.toDart,
      sharedSecret: SecureKeyJS(sodium, result.sharedSecret),
    );
  }

  @override
  SecureKey dec({required Uint8List ciphertext, required SecureKey secretKey}) {
    validateCiphertext(ciphertext);
    validateSecretKey(secretKey);

    final sharedSecret = jsErrorWrap(
      () => secretKey.runUnlockedSync(
        (secretKeyData) =>
            sodium.crypto_kem_dec(ciphertext.toJS, secretKeyData.toJS),
      ),
    );

    return SecureKeyJS(sodium, sharedSecret);
  }
}
