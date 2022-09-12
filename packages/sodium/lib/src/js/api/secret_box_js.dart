import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/detached_cipher_result.dart';
import '../../api/secret_box.dart';
import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart' hide SecretBox;
import '../bindings/to_safe_int.dart';
import 'secure_key_js.dart';

/// @nodoc
@internal
class SecretBoxJS with SecretBoxValidations implements SecretBox {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  SecretBoxJS(this.sodium);

  @override
  int get keyBytes => sodium.crypto_secretbox_KEYBYTES.toSafeUInt32();

  @override
  int get macBytes => sodium.crypto_secretbox_MACBYTES.toSafeUInt32();

  @override
  int get nonceBytes => sodium.crypto_secretbox_NONCEBYTES.toSafeUInt32();

  @override
  SecureKey keygen() => SecureKeyJS(
        sodium,
        jsErrorWrap(sodium.crypto_secretbox_keygen),
      );

  @override
  Uint8List easy({
    required Uint8List message,
    required Uint8List nonce,
    required SecureKey key,
  }) {
    validateNonce(nonce);
    validateKey(key);

    return jsErrorWrap(
      () => key.runUnlockedSync(
        (keyData) => sodium.crypto_secretbox_easy(
          message,
          nonce,
          keyData,
        ),
      ),
    );
  }

  @override
  Uint8List openEasy({
    required Uint8List cipherText,
    required Uint8List nonce,
    required SecureKey key,
  }) {
    validateEasyCipherText(cipherText);
    validateNonce(nonce);
    validateKey(key);

    return jsErrorWrap(
      () => key.runUnlockedSync(
        (keyData) => sodium.crypto_secretbox_open_easy(
          cipherText,
          nonce,
          keyData,
        ),
      ),
    );
  }

  @override
  DetachedCipherResult detached({
    required Uint8List message,
    required Uint8List nonce,
    required SecureKey key,
  }) {
    validateNonce(nonce);
    validateKey(key);

    final cipher = jsErrorWrap(
      () => key.runUnlockedSync(
        (keyData) => sodium.crypto_secretbox_detached(
          message,
          nonce,
          keyData,
        ),
      ),
    );

    return DetachedCipherResult(
      cipherText: cipher.cipher,
      mac: cipher.mac,
    );
  }

  @override
  Uint8List openDetached({
    required Uint8List cipherText,
    required Uint8List mac,
    required Uint8List nonce,
    required SecureKey key,
  }) {
    validateMac(mac);
    validateNonce(nonce);
    validateKey(key);

    return jsErrorWrap(
      () => key.runUnlockedSync(
        (keyData) => sodium.crypto_secretbox_open_detached(
          cipherText,
          mac,
          nonce,
          keyData,
        ),
      ),
    );
  }
}
