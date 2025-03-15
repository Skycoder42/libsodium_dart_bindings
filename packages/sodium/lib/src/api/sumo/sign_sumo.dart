import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../helpers/validations.dart';
import '../secure_key.dart';
import '../sign.dart';

/// A meta class that provides access to all libsodium sumo sign APIs.
///
/// This class provides the dart interface for the crypto operations documented
/// in https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures.
/// Please refer to that documentation for more details about these APIs.
abstract class SignSumo implements Sign {
  const SignSumo._(); // coverage:ignore-line

  /// Provides crypto_sign_ed25519_sk_to_seed.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures#extracting-the-seed-and-the-public-key-from-the-secret-key
  SecureKey skToSeed(SecureKey secretKey);

  /// Provides crypto_sign_ed25519_sk_to_pk.
  ///
  /// See https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures#extracting-the-seed-and-the-public-key-from-the-secret-key
  Uint8List skToPk(SecureKey secretKey);

  /// Provides crypto_sign_ed25519_pk_to_curve25519.
  ///
  /// See https://libsodium.gitbook.io/doc/advanced/ed25519-curve25519
  Uint8List pkToCurve25519(Uint8List publicKey);

  /// Provides crypto_sign_ed25519_sk_to_curve25519.
  ///
  /// See https://libsodium.gitbook.io/doc/advanced/ed25519-curve25519
  SecureKey skToCurve25519(SecureKey secretKey);
}

/// @nodoc
@internal
mixin SignSumoValidations on SignValidations implements Sign {
  /// @nodoc
  void validateSecretKeyOrSeed(SecureKey secretKeyOrSeed) =>
      Validations.checkIsAny(secretKeyOrSeed.length, [
        secretKeyBytes,
        seedBytes,
      ], 'secretKey');
}
