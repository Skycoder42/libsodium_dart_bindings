import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'detached_cipher_result.dart';
import 'helpers/validations.dart';
import 'secure_key.dart';

/// A meta class that provides access to all libsodium secretbox APIs.
///
/// This class provides the dart interface for the crypto operations documented
/// in https://libsodium.gitbook.io/doc/secret-key_cryptography/secretbox.
/// Please refer to that documentation for more details about these APIs.
abstract class SecretBox {
  const SecretBox._(); // coverage:ignore-line

  /// Provides crypto_secretbox_KEYBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretbox#constants.
  int get keyBytes;

  /// Provides crypto_secretbox_MACBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretbox#constants.
  int get macBytes;

  /// Provides crypto_secretbox_NONCEBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretbox#constants.
  int get nonceBytes;

  /// Provides crypto_secretbox_keygen.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretbox#detached-mode.
  SecureKey keygen();

  /// Provides crypto_secretbox_easy.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretbox#combined-mode
  Uint8List easy({
    required Uint8List message,
    required Uint8List nonce,
    required SecureKey key,
  });

  /// Provides crypto_secretbox_open_easy.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretbox#combined-mode
  Uint8List openEasy({
    required Uint8List cipherText,
    required Uint8List nonce,
    required SecureKey key,
  });

  /// Provides crypto_secretbox_detached.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretbox#detached-mode.
  DetachedCipherResult detached({
    required Uint8List message,
    required Uint8List nonce,
    required SecureKey key,
  });

  /// Provides crypto_secretbox_open_detached.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secretbox#detached-mode.
  Uint8List openDetached({
    required Uint8List cipherText,
    required Uint8List mac,
    required Uint8List nonce,
    required SecureKey key,
  });
}

@internal
mixin SecretBoxValidations implements SecretBox {
  void validateNonce(Uint8List nonce) => Validations.checkIsSame(
        nonce.length,
        nonceBytes,
        'nonce',
      );

  void validateKey(SecureKey key) => Validations.checkIsSame(
        key.length,
        keyBytes,
        'key',
      );

  void validateMac(Uint8List mac) => Validations.checkIsSame(
        mac.length,
        macBytes,
        'mac',
      );

  void validateEasyCipherText(Uint8List cipherText) => Validations.checkAtLeast(
        cipherText.length,
        macBytes,
        'cipherText',
      );
}
