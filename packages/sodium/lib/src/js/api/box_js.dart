import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/box.dart';
import '../../api/detached_cipher_result.dart';
import '../../api/key_pair.dart';
import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart' hide KeyPair;
import '../bindings/to_safe_int.dart';
import 'secure_key_js.dart';

/// @nodoc
@internal
class PrecalculatedBoxJS implements PrecalculatedBox {
  /// @nodoc
  final BoxJS box;

  /// @nodoc
  final SecureKeyJS sharedKey;

  /// @nodoc
  PrecalculatedBoxJS(this.box, this.sharedKey);

  @override
  Uint8List easy({
    required Uint8List message,
    required Uint8List nonce,
  }) {
    box.validateNonce(nonce);

    return JsError.wrap(
      () => sharedKey.runUnlockedSync(
        (sharedKeyData) => box.sodium.crypto_box_easy_afternm(
          message,
          nonce,
          sharedKeyData,
        ),
      ),
    );
  }

  @override
  Uint8List openEasy({
    required Uint8List cipherText,
    required Uint8List nonce,
  }) {
    box
      ..validateEasyCipherText(cipherText)
      ..validateNonce(nonce);

    return JsError.wrap(
      () => sharedKey.runUnlockedSync(
        (sharedKeyData) => box.sodium.crypto_box_open_easy_afternm(
          cipherText,
          nonce,
          sharedKeyData,
        ),
      ),
    );
  }

  @override
  DetachedCipherResult detached({
    required Uint8List message,
    required Uint8List nonce,
  }) {
    // Simulate detached, as it is not exposed from JS
    final easyCipher = easy(
      message: message,
      nonce: nonce,
    );
    return DetachedCipherResult(
      cipherText: easyCipher.sublist(box.macBytes),
      mac: easyCipher.sublist(0, box.macBytes),
    );
  }

  @override
  Uint8List openDetached({
    required Uint8List cipherText,
    required Uint8List mac,
    required Uint8List nonce,
  }) =>
      // Simulate detached, as it is not exposed from JS
      openEasy(
        cipherText: Uint8List.fromList(mac + cipherText),
        nonce: nonce,
      );

  @override
  void dispose() => sharedKey.dispose();
}

/// @nodoc
@internal
class BoxJS with BoxValidations implements Box {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  BoxJS(this.sodium);

  @override
  int get publicKeyBytes => sodium.crypto_box_PUBLICKEYBYTES.toSafeUInt32();

  @override
  int get secretKeyBytes => sodium.crypto_box_SECRETKEYBYTES.toSafeUInt32();

  @override
  int get macBytes => sodium.crypto_box_MACBYTES.toSafeUInt32();

  @override
  int get nonceBytes => sodium.crypto_box_NONCEBYTES.toSafeUInt32();

  @override
  int get seedBytes => sodium.crypto_box_SEEDBYTES.toSafeUInt32();

  @override
  int get sealBytes => sodium.crypto_box_SEALBYTES.toSafeUInt32();

  @override
  KeyPair keyPair() {
    final keyPair = JsError.wrap(() => sodium.crypto_box_keypair());

    return KeyPair(
      publicKey: keyPair.publicKey,
      secretKey: SecureKeyJS(sodium, keyPair.privateKey),
    );
  }

  @override
  KeyPair seedKeyPair(SecureKey seed) {
    validateSeed(seed);

    final keyPair = JsError.wrap(
      () => seed.runUnlockedSync(
        (seedData) => sodium.crypto_box_seed_keypair(seedData),
      ),
    );

    return KeyPair(
      publicKey: keyPair.publicKey,
      secretKey: SecureKeyJS(sodium, keyPair.privateKey),
    );
  }

  @override
  Uint8List easy({
    required Uint8List message,
    required Uint8List nonce,
    required Uint8List publicKey,
    required SecureKey secretKey,
  }) {
    validateNonce(nonce);
    validatePublicKey(publicKey);
    validateSecretKey(secretKey);

    return JsError.wrap(
      () => secretKey.runUnlockedSync(
        (secretKeyData) => sodium.crypto_box_easy(
          message,
          nonce,
          publicKey,
          secretKeyData,
        ),
      ),
    );
  }

  @override
  Uint8List openEasy({
    required Uint8List cipherText,
    required Uint8List nonce,
    required Uint8List publicKey,
    required SecureKey secretKey,
  }) {
    validateEasyCipherText(cipherText);
    validateNonce(nonce);
    validatePublicKey(publicKey);
    validateSecretKey(secretKey);

    return JsError.wrap(
      () => secretKey.runUnlockedSync(
        (secretKeyData) => sodium.crypto_box_open_easy(
          cipherText,
          nonce,
          publicKey,
          secretKeyData,
        ),
      ),
    );
  }

  @override
  DetachedCipherResult detached({
    required Uint8List message,
    required Uint8List nonce,
    required Uint8List publicKey,
    required SecureKey secretKey,
  }) {
    validateNonce(nonce);
    validatePublicKey(publicKey);
    validateSecretKey(secretKey);

    final cipher = JsError.wrap(
      () => secretKey.runUnlockedSync(
        (secretKeyData) => sodium.crypto_box_detached(
          message,
          nonce,
          publicKey,
          secretKeyData,
        ),
      ),
    );

    return DetachedCipherResult(
      cipherText: cipher.ciphertext,
      mac: cipher.mac,
    );
  }

  @override
  Uint8List openDetached({
    required Uint8List cipherText,
    required Uint8List mac,
    required Uint8List nonce,
    required Uint8List publicKey,
    required SecureKey secretKey,
  }) {
    validateMac(mac);
    validateNonce(nonce);
    validatePublicKey(publicKey);
    validateSecretKey(secretKey);

    return JsError.wrap(
      () => secretKey.runUnlockedSync(
        (secretKeyData) => sodium.crypto_box_open_detached(
          cipherText,
          mac,
          nonce,
          publicKey,
          secretKeyData,
        ),
      ),
    );
  }

  @override
  PrecalculatedBox precalculate({
    required Uint8List publicKey,
    required SecureKey secretKey,
  }) {
    validatePublicKey(publicKey);
    validateSecretKey(secretKey);

    return PrecalculatedBoxJS(
      this,
      SecureKeyJS(
        sodium,
        JsError.wrap(
          () => secretKey.runUnlockedSync(
            (secretKeyData) => sodium.crypto_box_beforenm(
              publicKey,
              secretKeyData,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Uint8List seal({
    required Uint8List message,
    required Uint8List publicKey,
  }) {
    validatePublicKey(publicKey);

    return JsError.wrap(
      () => sodium.crypto_box_seal(
        message,
        publicKey,
      ),
    );
  }

  @override
  Uint8List sealOpen({
    required Uint8List cipherText,
    required Uint8List publicKey,
    required SecureKey secretKey,
  }) {
    validateSealCipherText(cipherText);
    validatePublicKey(publicKey);
    validateSecretKey(secretKey);

    return JsError.wrap(
      () => secretKey.runUnlockedSync(
        (secretKeyData) => sodium.crypto_box_seal_open(
          cipherText,
          publicKey,
          secretKeyData,
        ),
      ),
    );
  }
}
