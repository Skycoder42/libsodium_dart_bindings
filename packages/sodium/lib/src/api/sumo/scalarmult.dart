import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../helpers/validations.dart';
import '../secure_key.dart';

/// A meta class that provides access to all libsodium scalarmult APIs.
///
/// This class provides the dart interface for the crypto operations documented
/// in https://libsodium.gitbook.io/doc/advanced/scalar_multiplication.
/// Please refer to that documentation for more details about these APIs.
abstract class Scalarmult {
  const Scalarmult._(); // coverage:ignore-line

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
  Uint8List base({required SecureKey n});

  /// Provides crypto_scalarmult.
  ///
  /// See https://libsodium.gitbook.io/doc/advanced/scalar_multiplication#usage
  SecureKey call({required SecureKey n, required Uint8List p});
}

/// @nodoc
@internal
mixin ScalarmultValidations implements Scalarmult {
  /// @nodoc
  void validatePublicKey(Uint8List publicKey) =>
      Validations.checkIsSame(publicKey.length, bytes, 'publicKey');

  /// @nodoc
  void validateSecretKey(SecureKey secretKey) =>
      Validations.checkIsSame(secretKey.length, scalarBytes, 'secretKey');
}
