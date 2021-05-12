import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'detached_cipher_result.dart';
import 'helpers/validations.dart';
import 'key_pair.dart';
import 'secure_key.dart';

/// A meta class that provides access to all libsodium box APIs.
///
/// This class provides the dart interface for the crypto operations documented
/// in https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption.
/// Please refer to that documentation for more details about these APIs.
abstract class Box {
  const Box._(); // coverage:ignore-line

  /// Provides crypto_box_PUBLICKEYBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption#constants
  int get publicKeyBytes;

  /// Provides crypto_box_SECRETKEYBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption#constants
  int get secretKeyBytes;

  /// Provides crypto_box_MACBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption#constants
  int get macBytes;

  /// Provides crypto_box_NONCEBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption#constants
  int get nonceBytes;

  /// Provides crypto_box_SEEDBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption#constants
  int get seedBytes;

  /// Provides crypto_box_keypair.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption#key-pair-generation
  KeyPair keyPair();

  /// Provides crypto_box_seed_keypair.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption#key-pair-generation
  KeyPair seedKeyPair(SecureKey seed);

  /// Provides crypto_box_easy.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption#combined-mode
  Uint8List easy({
    required Uint8List message,
    required Uint8List nonce,
    required Uint8List recipientPublicKey,
    required SecureKey senderSecretKey,
  });

  /// Provides crypto_box_open_easy.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption#combined-mode
  Uint8List openEasy({
    required Uint8List cipherText,
    required Uint8List nonce,
    required Uint8List senderPublicKey,
    required SecureKey recipientSecretKey,
  });

  /// Provides crypto_box_detached.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption#detached-mode
  DetachedCipherResult detached({
    required Uint8List message,
    required Uint8List nonce,
    required Uint8List recipientPublicKey,
    required SecureKey senderSecretKey,
  });

  /// Provides crypto_box_open_detached.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption#detached-mode
  Uint8List openDetached({
    required Uint8List cipherText,
    required Uint8List mac,
    required Uint8List nonce,
    required Uint8List senderPublicKey,
    required SecureKey recipientSecretKey,
  });
}

@internal
mixin BoxValidations implements Box {
  void validatePublicKey(Uint8List publicKey) => Validations.checkIsSame(
        publicKey.length,
        publicKeyBytes,
        'publicKey',
      );

  void validateSecretKey(SecureKey secretKey) => Validations.checkIsSame(
        secretKey.length,
        secretKeyBytes,
        'secretKey',
      );

  void validateMac(Uint8List mac) => Validations.checkIsSame(
        mac.length,
        macBytes,
        'mac',
      );

  void validateNonce(Uint8List nonce) => Validations.checkIsSame(
        nonce.length,
        nonceBytes,
        'nonce',
      );

  void validateSeed(SecureKey seed) => Validations.checkIsSame(
        seed.length,
        seedBytes,
        'seed',
      );

  void validateEasyCipherText(Uint8List cipherText) => Validations.checkAtLeast(
        cipherText.length,
        macBytes,
        'cipherText',
      );
}
