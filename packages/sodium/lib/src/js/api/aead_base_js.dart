import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/aead.dart';
import '../../api/detached_cipher_result.dart';
import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart';

/// @nodoc
@internal
typedef InternalEncrypt = Uint8List Function(
  Uint8List message,
  Uint8List? additionalData,
  Uint8List? secretNonce,
  Uint8List publicNonce,
  Uint8List key,
);

/// @nodoc
@internal
typedef InternalDecrypt = Uint8List Function(
  Uint8List? secretNonce,
  Uint8List ciphertext,
  Uint8List? additionalData,
  Uint8List publicNonce,
  Uint8List key,
);

/// @nodoc
@internal
typedef InternalEncryptDetached = CryptoBox Function(
  Uint8List message,
  Uint8List? additionalData,
  Uint8List? secretNonce,
  Uint8List publicNonce,
  Uint8List key,
);

/// @nodoc
@internal
typedef InternalDecryptDetached = Uint8List Function(
  Uint8List? secretNonce,
  Uint8List ciphertext,
  Uint8List mac,
  Uint8List? additionalData,
  Uint8List publicNonce,
  Uint8List key,
);

/// @nodoc
@internal
abstract class AeadBaseJS with AeadValidations implements Aead {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  AeadBaseJS(this.sodium);

  /// @nodoc
  @protected
  InternalEncrypt get internalEncrypt;

  /// @nodoc
  @protected
  InternalDecrypt get internalDecrypt;

  /// @nodoc
  @protected
  InternalEncryptDetached get internalEncryptDetached;

  /// @nodoc
  @protected
  InternalDecryptDetached get internalDecryptDetached;

  @override
  Uint8List encrypt({
    required Uint8List message,
    required Uint8List nonce,
    required SecureKey key,
    Uint8List? additionalData,
  }) {
    validateNonce(nonce);
    validateKey(key);

    return jsErrorWrap(
      () => key.runUnlockedSync(
        (keyData) => internalEncrypt(
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

    return jsErrorWrap(
      () => key.runUnlockedSync(
        (keyData) => internalDecrypt(
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

    final cipher = jsErrorWrap(
      () => key.runUnlockedSync(
        (keyData) => internalEncryptDetached(
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

    return jsErrorWrap(
      () => key.runUnlockedSync(
        (keyData) => internalDecryptDetached(
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
