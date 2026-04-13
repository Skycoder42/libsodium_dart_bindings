import 'dart:typed_data';

import 'key_pair.dart';
import 'secure_key.dart';

/// The result of a [Kem.enc] operation.
///
/// Is made up out of the [ciphertext] to be sent ti the partner, as well as
/// the [sharedSecret] that is the result of the kem protocol.
typedef KemEncResult = ({Uint8List ciphertext, SecureKey sharedSecret});

/// A meta class that provides access to all libsodium kem APIs.
///
/// This class provides the dart interface for the crypto operations documented
/// in
/// https://libsodium.gitbook.io/doc/public-key_cryptography/key_encapsulation.
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
  KemEncResult enc(Uint8List publicKey);

  /// Provides crypto_kem_dec.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/key_encapsulation#usage
  SecureKey dec({required Uint8List ciphertext, required SecureKey secretKey});
}
