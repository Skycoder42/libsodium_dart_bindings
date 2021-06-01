import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/aead.dart';
import '../../api/detached_cipher_result.dart';
import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart';
import '../bindings/to_safe_int.dart';
import 'secure_key_js.dart';

@internal
class AeadJS with AeadValidations implements Aead {
  final LibSodiumJS sodium;

  AeadJS(this.sodium);

  @override
  int get keyBytes =>
      sodium.crypto_aead_xchacha20poly1305_ietf_KEYBYTES.toSafeUInt32();

  @override
  int get nonceBytes =>
      sodium.crypto_aead_xchacha20poly1305_ietf_NPUBBYTES.toSafeUInt32();

  @override
  int get aBytes =>
      sodium.crypto_aead_xchacha20poly1305_ietf_ABYTES.toSafeUInt32();

  @override
  SecureKey keygen() => SecureKeyJS(
        sodium,
        JsError.wrap(
          () => sodium.crypto_aead_xchacha20poly1305_ietf_keygen(),
        ),
      );

  @override
  Uint8List encrypt({
    required Uint8List message,
    required Uint8List nonce,
    required SecureKey key,
    Uint8List? additionalData,
  }) {
    validateNonce(nonce);
    validateKey(key);

    return JsError.wrap(
      () => key.runUnlockedSync(
        (keyData) => sodium.crypto_aead_xchacha20poly1305_ietf_encrypt(
          message,
          additionalData,
          null,
          nonce,
          keyData,
        ),
      ),
    );
  }

  @override
  Uint8List decrypt({
    required Uint8List cipherText,
    required Uint8List nonce,
    required SecureKey key,
    Uint8List? additionalData,
  }) {
    validateEasyCipherText(cipherText);
    validateNonce(nonce);
    validateKey(key);

    return JsError.wrap(
      () => key.runUnlockedSync(
        (keyData) => sodium.crypto_aead_xchacha20poly1305_ietf_decrypt(
          null,
          cipherText,
          additionalData,
          nonce,
          keyData,
        ),
      ),
    );
  }

  @override
  DetachedCipherResult encryptDetached({
    required Uint8List message,
    required Uint8List nonce,
    required SecureKey key,
    Uint8List? additionalData,
  }) {
    validateNonce(nonce);
    validateKey(key);

    final cipher = JsError.wrap(
      () => key.runUnlockedSync(
        (keyData) => sodium.crypto_aead_xchacha20poly1305_ietf_encrypt_detached(
          message,
          additionalData,
          null,
          nonce,
          keyData,
        ),
      ),
    );

    return DetachedCipherResult(
      cipherText: cipher.ciphertext,
      mac: cipher.mac,
    );
  }

  @override
  Uint8List decryptDetached({
    required Uint8List cipherText,
    required Uint8List mac,
    required Uint8List nonce,
    required SecureKey key,
    Uint8List? additionalData,
  }) {
    validateMac(mac);
    validateNonce(nonce);
    validateKey(key);

    return JsError.wrap(
      () => key.runUnlockedSync(
        (keyData) => sodium.crypto_aead_xchacha20poly1305_ietf_decrypt_detached(
          null,
          cipherText,
          mac,
          additionalData,
          nonce,
          keyData,
        ),
      ),
    );
  }
}
