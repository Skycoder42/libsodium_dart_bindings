import 'dart:typed_data';

import '../../api/box.dart';
import '../../api/detached_cipher_result.dart';
import '../../api/key_pair.dart';
import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart' hide KeyPair;
import '../bindings/to_safe_int.dart';
import 'secure_key_js.dart';

class BoxJS with BoxValidations implements Box {
  final LibSodiumJS sodium;

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
    required Uint8List recipientPublicKey,
    required SecureKey senderSecretKey,
  }) {
    validateNonce(nonce);
    validatePublicKey(recipientPublicKey);
    validateSecretKey(senderSecretKey);

    return JsError.wrap(
      () => senderSecretKey.runUnlockedSync(
        (secretKeyData) => sodium.crypto_box_easy(
          message,
          nonce,
          recipientPublicKey,
          secretKeyData,
        ),
      ),
    );
  }

  @override
  Uint8List openEasy({
    required Uint8List cipherText,
    required Uint8List nonce,
    required Uint8List senderPublicKey,
    required SecureKey recipientSecretKey,
  }) {
    validateEasyCipherText(cipherText);
    validateNonce(nonce);
    validatePublicKey(senderPublicKey);
    validateSecretKey(recipientSecretKey);

    return JsError.wrap(
      () => recipientSecretKey.runUnlockedSync(
        (secretKeyData) => sodium.crypto_box_open_easy(
          cipherText,
          nonce,
          senderPublicKey,
          secretKeyData,
        ),
      ),
    );
  }

  @override
  DetachedCipherResult detached({
    required Uint8List message,
    required Uint8List nonce,
    required Uint8List recipientPublicKey,
    required SecureKey senderSecretKey,
  }) {
    validateNonce(nonce);
    validatePublicKey(recipientPublicKey);
    validateSecretKey(senderSecretKey);

    final cipher = JsError.wrap(
      () => senderSecretKey.runUnlockedSync(
        (secretKeyData) => sodium.crypto_box_detached(
          message,
          nonce,
          recipientPublicKey,
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
    required Uint8List senderPublicKey,
    required SecureKey recipientSecretKey,
  }) {
    validateMac(mac);
    validateNonce(nonce);
    validatePublicKey(senderPublicKey);
    validateSecretKey(recipientSecretKey);

    return JsError.wrap(
      () => recipientSecretKey.runUnlockedSync(
        (secretKeyData) => sodium.crypto_box_open_detached(
          cipherText,
          mac,
          nonce,
          senderPublicKey,
          secretKeyData,
        ),
      ),
    );
  }
}
