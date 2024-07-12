import 'dart:convert';

import 'package:meta/meta.dart';

import 'helpers/validations.dart';
import 'secure_key.dart';

/// A meta class that provides access to all libsodium kdf APIs.
///
/// This class provides the dart interface for the crypto operations documented
/// in https://libsodium.gitbook.io/doc/key_derivation.
/// Please refer to that documentation for more details about these APIs.
abstract class Kdf {
  const Kdf._(); // coverage:ignore-line

  /// Provides crypto_kdf_BYTES_MIN.
  ///
  /// See https://libsodium.gitbook.io/doc/key_derivation#key-derivation-with-libsodium-greater-than-1-0-12
  int get bytesMin;

  /// Provides crypto_kdf_BYTES_MAX.
  ///
  /// See https://libsodium.gitbook.io/doc/key_derivation#key-derivation-with-libsodium-greater-than-1-0-12
  int get bytesMax;

  /// Provides crypto_kdf_CONTEXTBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/key_derivation#key-derivation-with-libsodium-greater-than-1-0-12
  int get contextBytes;

  /// Provides crypto_kdf_KEYBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/key_derivation#key-derivation-with-libsodium-greater-than-1-0-12
  int get keyBytes;

  /// Provides crypto_kdf_keygen.
  ///
  /// See https://libsodium.gitbook.io/doc/key_derivation#key-derivation-with-libsodium-greater-than-1-0-12
  SecureKey keygen();

  /// Provides crypto_kdf_derive_from_key.
  ///
  /// See https://libsodium.gitbook.io/doc/key_derivation#key-derivation-with-libsodium-greater-than-1-0-12
  SecureKey deriveFromKey({
    required SecureKey masterKey,
    required String context,
    required BigInt subkeyId,
    required int subkeyLen,
  });
}

@internal
mixin KdfValidations implements Kdf {
  void validateMasterKey(SecureKey masterKey) => Validations.checkIsSame(
        masterKey.length,
        keyBytes,
        'masterKey',
      );

  void validateContext(String context) => Validations.checkAtMost(
        utf8.encode(context).length,
        contextBytes,
        'context',
      );

  void validateSubkeyLen(int subkeyLen) => Validations.checkInRange(
        subkeyLen,
        bytesMin,
        bytesMax,
        'subkeyLen',
      );

  void validateSubkeyId(BigInt subkeyId) => Validations.checkIsUint64(
        subkeyId,
        'subkeyId',
      );
}
