// ignore_for_file: unnecessary_lambdas

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/detached_cipher_result.dart';
import '../../api/secret_box.dart';
import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart' hide SecretBox;
import 'secure_key_js.dart';

/// @nodoc
@internal
class SecretBoxJS with SecretBoxValidations implements SecretBox {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  SecretBoxJS(this.sodium);

  @override
  int get keyBytes => sodium.crypto_secretbox_KEYBYTES;

  @override
  int get macBytes => sodium.crypto_secretbox_MACBYTES;

  @override
  int get nonceBytes => sodium.crypto_secretbox_NONCEBYTES;

  @override
  SecureKey keygen() =>
      SecureKeyJS(sodium, jsErrorWrap(() => sodium.crypto_secretbox_keygen()));

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
        (keyData) => sodium
            .crypto_secretbox_easy(message.toJS, nonce.toJS, keyData.toJS)
            .toDart,
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
        (keyData) => sodium
            .crypto_secretbox_open_easy(
              cipherText.toJS,
              nonce.toJS,
              keyData.toJS,
            )
            .toDart,
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
          message.toJS,
          nonce.toJS,
          keyData.toJS,
        ),
      ),
    );

    return DetachedCipherResult(
      cipherText: cipher.cipher.toDart,
      mac: cipher.mac.toDart,
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
        (keyData) => sodium
            .crypto_secretbox_open_detached(
              cipherText.toJS,
              mac.toJS,
              nonce.toJS,
              keyData.toJS,
            )
            .toDart,
      ),
    );
  }
}
