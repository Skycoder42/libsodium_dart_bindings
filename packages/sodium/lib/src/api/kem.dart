import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'helpers/validations.dart';
import 'key_pair.dart';
import 'secure_key.dart';

/// Result of a KEM encapsulation operation.
///
/// Contains the [ciphertext] to send to the other party and the derived
/// [sharedSecret].
typedef KemEncResult = ({Uint8List ciphertext, SecureKey sharedSecret});

/// A meta class that provides access to all libsodium kem APIs.
///
/// This class provides the dart interface for the crypto operations documented
/// in https://libsodium.gitbook.io/doc/public-key_cryptography/key_encapsulation
/// Please refer to that documentation for more details about these APIs.
abstract interface class Kem {
  /// Provides crypto_kem_PUBLICKEYBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/key_encapsulation#constants
  int get publicKeyBytes;

  /// Provides crypto_kem_SECRETKEYBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/key_encapsulation#constants
  int get secretKeyBytes;

  /// Provides crypto_kem_CIPHERTEXTBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/key_encapsulation#constants
  int get ciphertextBytes;

  /// Provides crypto_kem_SHAREDSECRETBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/key_encapsulation#constants
  int get sharedSecretBytes;

  /// Provides crypto_kem_SEEDBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/key_encapsulation#constants
  int get seedBytes;

  /// Provides crypto_kem_PRIMITIVE.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/key_encapsulation#constants
  String get primitive;

  /// Provides crypto_kem_keypair.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/key_encapsulation#usage
  KeyPair keyPair();

  /// Provides crypto_kem_seed_keypair.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/key_encapsulation#usage
  KeyPair seedKeyPair(SecureKey seed);

  /// Provides crypto_kem_enc.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/key_encapsulation#usage
  KemEncResult enc({required Uint8List publicKey});

  /// Provides crypto_kem_dec.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/key_encapsulation#usage
  SecureKey dec({required Uint8List ciphertext, required SecureKey secretKey});
}

/// @nodoc
@internal
mixin KemValidations implements Kem {
  /// @nodoc
  void validatePublicKey(Uint8List publicKey) =>
      Validations.checkIsSame(publicKey.length, publicKeyBytes, 'publicKey');

  /// @nodoc
  void validateSecretKey(SecureKey secretKey) =>
      Validations.checkIsSame(secretKey.length, secretKeyBytes, 'secretKey');

  /// @nodoc
  void validateCiphertext(Uint8List ciphertext) =>
      Validations.checkIsSame(ciphertext.length, ciphertextBytes, 'ciphertext');

  /// @nodoc
  void validateSeed(SecureKey seed) =>
      Validations.checkIsSame(seed.length, seedBytes, 'seed');
}
