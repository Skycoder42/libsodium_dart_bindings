import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'helpers/validations.dart';
import 'secure_key.dart';

/// A meta class that provides access to all libsodium auth APIs.
///
/// This class provides the dart interface for the crypto operations documented
/// in https://libsodium.gitbook.io/doc/secret-key_cryptography/secret-key_authentication.
/// Please refer to that documentation for more details about these APIs.
abstract class Auth {
  const Auth._(); // coverage:ignore-line

  /// Provides crypto_auth_BYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secret-key_authentication#constants
  int get bytes;

  /// Provides crypto_auth_KEYBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secret-key_authentication#constants
  int get keyBytes;

  /// Provides crypto_auth_keygen.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secret-key_authentication#usage
  SecureKey keygen();

  /// Provides crypto_auth.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secret-key_authentication#usage
  @pragma('vm:entry-point')
  Uint8List call({required Uint8List message, required SecureKey key});

  /// Provides crypto_auth_verify.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/secret-key_authentication#usage
  bool verify({
    required Uint8List tag,
    required Uint8List message,
    required SecureKey key,
  });
}

/// @nodoc
@internal
mixin AuthValidations implements Auth {
  /// @nodoc
  void validateTag(Uint8List tag) =>
      Validations.checkIsSame(tag.length, bytes, 'tag');

  /// @nodoc
  void validateKey(SecureKey key) =>
      Validations.checkIsSame(key.length, keyBytes, 'key');
}
