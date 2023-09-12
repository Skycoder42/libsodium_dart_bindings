import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'detached_cipher_result.dart';
import 'helpers/validations.dart';
import 'secure_key.dart';

/// A meta class that provides access to all libsodium aead APIs.
///
/// Currently, crypto_aead_chacha20poly1305_* and
/// crypto_aead_xchacha20poly1305_ietf* APIs have been implemented.
///
/// This class provides the dart interface for the crypto operations documented
/// in https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/original_chacha20-poly1305_construction
/// or https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/xchacha20-poly1305_construction.
/// Please refer to that documentation for more details about these APIs.
abstract class Aead {
  const Aead._(); // coverage:ignore-line

  /// Provides crypto_aead_*chacha20poly1305*_KEYBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/xchacha20-poly1305_construction#constants
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/original_chacha20-poly1305_construction#constants
  int get keyBytes;

  /// Provides crypto_aead_*chacha20poly1305*_NPUBBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/xchacha20-poly1305_construction#constants
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/original_chacha20-poly1305_construction#constants
  int get nonceBytes;

  /// Provides crypto_aead_*chacha20poly1305*_ABYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/xchacha20-poly1305_construction#constants
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/original_chacha20-poly1305_construction#constants
  int get aBytes;

  /// Provides crypto_aead_*chacha20poly1305*_keygen.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/xchacha20-poly1305_construction#detached-mode
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/original_chacha20-poly1305_construction#detached-mode
  SecureKey keygen();

  /// Provides crypto_aead_*chacha20poly1305*_encrypt.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/xchacha20-poly1305_construction#combined-mode
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/original_chacha20-poly1305_construction#combined-mode
  Uint8List encrypt({
    required Uint8List message,
    required Uint8List nonce,
    required SecureKey key,
    Uint8List? additionalData,
  });

  /// Provides crypto_aead_*chacha20poly1305*_decrypt.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/xchacha20-poly1305_construction#combined-mode
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/original_chacha20-poly1305_construction#combined-mode
  Uint8List decrypt({
    required Uint8List cipherText,
    required Uint8List nonce,
    required SecureKey key,
    Uint8List? additionalData,
  });

  /// Provides crypto_aead_*chacha20poly1305*_encrypt_detached.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/xchacha20-poly1305_construction#detached-mode
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/original_chacha20-poly1305_construction#detached-mode
  DetachedCipherResult encryptDetached({
    required Uint8List message,
    required Uint8List nonce,
    required SecureKey key,
    Uint8List? additionalData,
  });

  /// Provides crypto_aead_*chacha20poly1305*_decrypt_detached.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/xchacha20-poly1305_construction#detached-mode
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/original_chacha20-poly1305_construction#detached-mode
  Uint8List decryptDetached({
    required Uint8List cipherText,
    required Uint8List mac,
    required Uint8List nonce,
    required SecureKey key,
    Uint8List? additionalData,
  });
}

/// @nodoc
@internal
mixin AeadValidations implements Aead {
  /// @nodoc
  void validateNonce(Uint8List nonce) => Validations.checkIsSame(
        nonce.length,
        nonceBytes,
        'nonce',
      );

  /// @nodoc
  void validateKey(SecureKey key) => Validations.checkIsSame(
        key.length,
        keyBytes,
        'key',
      );

  /// @nodoc
  void validateMac(Uint8List mac) => Validations.checkIsSame(
        mac.length,
        aBytes,
        'mac',
      );

  /// @nodoc
  void validateEasyCipherText(Uint8List cipherText) => Validations.checkAtLeast(
        cipherText.length,
        aBytes,
        'cipherText',
      );
}
