import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'detached_cipher_result.dart';
import 'helpers/validations.dart';
import 'secure_key.dart';

/// A meta class that provides access to all libsodium aead APIs.
///
/// Currently, only the crypto_aead_xchacha20poly1305_ietf_* APIs have been
/// implemented.
///
/// This class provides the dart interface for the crypto operations documented
/// in https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/xchacha20-poly1305_construction.
/// Please refer to that documentation for more details about these APIs.
abstract class Aead {
  const Aead._(); // coverage:ignore-line

  /// Provides crypto_aead_xchacha20poly1305_ietf_KEYBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/xchacha20-poly1305_construction#constants
  int get keyBytes;

  /// Provides crypto_aead_xchacha20poly1305_ietf_NPUBBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/xchacha20-poly1305_construction#constants
  int get nonceBytes;

  /// Provides crypto_aead_xchacha20poly1305_ietf_ABYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/xchacha20-poly1305_construction#constants
  int get aBytes;

  /// Provides crypto_aead_xchacha20poly1305_ietf_keygen.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/xchacha20-poly1305_construction#detached-mode
  SecureKey keygen();

  /// Provides crypto_aead_xchacha20poly1305_ietf_encrypt.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/xchacha20-poly1305_construction#combined-mode
  Uint8List encrypt({
    required Uint8List message,
    required Uint8List nonce,
    required SecureKey key,
    Uint8List? additionalData,
  });

  /// Provides crypto_aead_xchacha20poly1305_ietf_decrypt.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/xchacha20-poly1305_construction#combined-mode
  Uint8List decrypt({
    required Uint8List cipherText,
    required Uint8List nonce,
    required SecureKey key,
    Uint8List? additionalData,
  });

  /// Provides crypto_aead_xchacha20poly1305_ietf_encrypt_detached.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/xchacha20-poly1305_construction#detached-mode
  DetachedCipherResult encryptDetached({
    required Uint8List message,
    required Uint8List nonce,
    required SecureKey key,
    Uint8List? additionalData,
  });

  /// Provides crypto_aead_xchacha20poly1305_ietf_decrypt_detached.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/xchacha20-poly1305_construction#detached-mode
  Uint8List decryptDetached({
    required Uint8List cipherText,
    required Uint8List mac,
    required Uint8List nonce,
    required SecureKey key,
    Uint8List? additionalData,
  });
}

@internal
mixin AeadValidations implements Aead {
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
        aBytes,
        'mac',
      );

  void validateEasyCipherText(Uint8List cipherText) => Validations.checkAtLeast(
        cipherText.length,
        aBytes,
        'cipherText',
      );
}
