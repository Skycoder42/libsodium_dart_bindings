import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../helpers/validations.dart';
import '../secure_key.dart';

/// A meta class that provides access to all libsodium generichash APIs.
///
/// This class provides the dart interface for the crypto operations documented
/// in https://libsodium.gitbook.io/doc/hashing/generic_hashing.
/// Please refer to that documentation for more details about these APIs.
abstract class AdvancedScalarMult {
  const AdvancedScalarMult._(); // coverage:ignore-line

  /// Provides crypto_scalarmult_BYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/advanced/scalar_multiplication#constants
  int get bytes;

  /// Provides crypto_scalarmult_SCALARBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/advanced/scalar_multiplication#constants
  int get scalarBytes;

  /// Provides crypto_scalarmult_base.
  ///
  /// See https://libsodium.gitbook.io/doc/advanced/scalar_multiplication#usage
  Uint8List base({
    required SecureKey secretKey,
  });

  /// Provides crypto_scalarmult. Please read the warnings at the link below to
  /// undestand how easily this can be misused.
  ///
  /// See https://libsodium.gitbook.io/doc/advanced/scalar_multiplication#usage
  SecureKey call({
    required SecureKey secretKey,
    required Uint8List otherPublicKey,
  });
}

@internal
mixin AdvancedScalarMultValidations implements AdvancedScalarMult {
  void validatePublicKey(Uint8List publicKey) => Validations.checkIsSame(
        publicKey.length,
        bytes,
        'publicKey',
      );

  void validateSecretKey(SecureKey key) => Validations.checkIsSame(
        key.length,
        scalarBytes,
        'secretKey',
      );
}
