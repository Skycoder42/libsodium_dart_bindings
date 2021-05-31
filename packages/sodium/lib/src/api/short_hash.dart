import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'helpers/validations.dart';
import 'secure_key.dart';

/// A meta class that provides access to all libsodium shorthash APIs.
///
/// This class provides the dart interface for the crypto operations documented
/// in https://libsodium.gitbook.io/doc/hashing/short-input_hashing.
/// Please refer to that documentation for more details about these APIs.
abstract class ShortHash {
  const ShortHash._(); // coverage:ignore-line

  /// Provides crypto_shorthash_BYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/hashing/short-input_hashing#constants
  int get bytes;

  /// Provides crypto_shorthash_KEYBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/hashing/short-input_hashing#constants
  int get keyBytes;

  /// Provides crypto_shorthash_keygen.
  ///
  /// See https://libsodium.gitbook.io/doc/hashing/short-input_hashing#usage
  SecureKey keygen();

  /// Provides crypto_shorthash.
  ///
  /// See https://libsodium.gitbook.io/doc/hashing/short-input_hashing#usage
  Uint8List call({
    required Uint8List message,
    required SecureKey key,
  });
}

@internal
mixin ShortHashValidations implements ShortHash {
  void validateKey(SecureKey key) => Validations.checkIsSame(
        key.length,
        keyBytes,
        'key',
      );
}
