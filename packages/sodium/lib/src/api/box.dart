import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'detached_cipher_result.dart';
import 'helpers/validations.dart';
import 'key_pair.dart';
import 'secure_key.dart';

/// A meta class that provides access to all libsodium box APIs working with
/// precalculated key.
///
/// This class is a view on a [Box] that internally uses the *_afternm methods
/// instead of normal encryption methods, as those are faster when en/decrypting
/// multiple messages with the same partner. To create such a box, use
/// [Box.precalculate] with the corresponding keys.
///
/// This class provides the dart interface for the crypto operations documented
/// in https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption#precalculation-interface.
/// Please refer to that documentation for more details about these APIs.
abstract class PrecalculatedBox {
  const PrecalculatedBox._(); // coverage:ignore-line

  /// Provides crypto_box_easy_afternm.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption#precalculation-interface
  Uint8List easy({
    required Uint8List message,
    required Uint8List nonce,
  });

  /// Provides crypto_box_open_easy_afternm.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption#precalculation-interface
  Uint8List openEasy({
    required Uint8List cipherText,
    required Uint8List nonce,
  });

  /// Provides crypto_box_detached_afternm.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption#precalculation-interface
  DetachedCipherResult detached({
    required Uint8List message,
    required Uint8List nonce,
  });

  /// Provides crypto_box_open_detached_afternm.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption#precalculation-interface
  Uint8List openDetached({
    required Uint8List cipherText,
    required Uint8List mac,
    required Uint8List nonce,
  });

  /// Disposes the internally used shared key.
  ///
  /// This is the key that was created from [Box.precalculate] via
  /// crypto_box_beforenm.
  void dispose();
}

/// A meta class that provides access to all libsodium box APIs.
///
/// This class provides the dart interface for the crypto operations documented
/// in https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption
/// and https://libsodium.gitbook.io/doc/public-key_cryptography/sealed_boxes.
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

  /// Provides crypto_box_SEALBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/sealed_boxes#constants
  int get sealBytes;

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
    required Uint8List publicKey,
    required SecureKey secretKey,
  });

  /// Provides crypto_box_open_easy.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption#combined-mode
  Uint8List openEasy({
    required Uint8List cipherText,
    required Uint8List nonce,
    required Uint8List publicKey,
    required SecureKey secretKey,
  });

  /// Provides crypto_box_detached.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption#detached-mode
  DetachedCipherResult detached({
    required Uint8List message,
    required Uint8List nonce,
    required Uint8List publicKey,
    required SecureKey secretKey,
  });

  /// Provides crypto_box_open_detached.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption#detached-mode
  Uint8List openDetached({
    required Uint8List cipherText,
    required Uint8List mac,
    required Uint8List nonce,
    required Uint8List publicKey,
    required SecureKey secretKey,
  });

  /// Provides crypto_box_beforenm.
  ///
  /// To work with the precalculated shared key, use the methods defined on the
  /// returned [PrecalculatedBox].
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption#precalculation-interface
  PrecalculatedBox precalculate({
    required Uint8List publicKey,
    required SecureKey secretKey,
  });

  /// Provides crypto_box_seal.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/sealed_boxes#usage
  Uint8List seal({
    required Uint8List message,
    required Uint8List publicKey,
  });

  /// Provides crypto_box_seal_open.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/sealed_boxes#usage
  Uint8List sealOpen({
    required Uint8List cipherText,
    required Uint8List publicKey,
    required SecureKey secretKey,
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

  void validateSealCipherText(Uint8List cipherText) => Validations.checkAtLeast(
        cipherText.length,
        sealBytes,
        'cipherText',
      );
}
