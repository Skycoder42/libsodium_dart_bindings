import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../helpers/validations.dart';
import '../secure_key.dart';

/// Enum type for the different hashing algorithms that can be used.
///
/// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#constants
enum CryptoPwhashAlgorithm {
  /// Provides crypto_pwhash_ALG_DEFAULT.
  ///
  /// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#constants
  defaultAlg,

  /// Provides crypto_pwhash_ALG_ARGON2I13.
  ///
  /// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#constants
  argon2i13,

  /// Provides crypto_pwhash_ALG_ARGON2ID13.
  ///
  /// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#constants
  argon2id13,
}

/// A meta class that provides access to all libsodium pwhash APIs.
///
/// This class provides the dart interface for the crypto operations documented
/// in https://libsodium.gitbook.io/doc/password_hashing/default_phf.
/// Please refer to that documentation for more details about these APIs.
abstract class Pwhash {
  const Pwhash._(); // coverage:ignore-line

  /// Provides crypto_pwhash_BYTES_MIN.
  ///
  /// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#constants
  int get bytesMin;

  /// Provides crypto_pwhash_BYTES_MAX.
  ///
  /// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#constants
  int get bytesMax;

  /// Provides crypto_pwhash_MEMLIMIT_MIN.
  ///
  /// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#constants
  int get memLimitMin;

  /// Provides crypto_pwhash_MEMLIMIT_INTERACTIVE.
  ///
  /// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#constants
  int get memLimitInteractive;

  /// Provides crypto_pwhash_MEMLIMIT_MODERATE.
  ///
  /// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#constants
  int get memLimitModerate;

  /// Provides crypto_pwhash_MEMLIMIT_SENSITIVE.
  ///
  /// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#constants
  int get memLimitSensitive;

  /// Provides crypto_pwhash_MEMLIMIT_MAX.
  ///
  /// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#constants
  int get memLimitMax;

  /// Provides crypto_pwhash_OPSLIMIT_MIN.
  ///
  /// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#constants
  int get opsLimitMin;

  /// Provides crypto_pwhash_OPSLIMIT_INTERACTIVE.
  ///
  /// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#constants
  int get opsLimitInteractive;

  /// Provides crypto_pwhash_OPSLIMIT_MODERATE.
  ///
  /// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#constants
  int get opsLimitModerate;

  /// Provides crypto_pwhash_OPSLIMIT_SENSITIVE.
  ///
  /// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#constants
  int get opsLimitSensitive;

  /// Provides crypto_pwhash_OPSLIMIT_MAX.
  ///
  /// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#constants
  int get opsLimitMax;

  /// Provides crypto_pwhash_PASSWD_MIN.
  ///
  /// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#constants
  int get passwdMin;

  /// Provides crypto_pwhash_PASSWD_MAX.
  ///
  /// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#constants
  int get passwdMax;

  /// Provides crypto_pwhash_SALTBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#constants
  int get saltBytes;

  /// Provides crypto_pwhash_STRBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#constants
  int get strBytes;

  /// Provides crypto_pwhash.
  ///
  /// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#key-derivation
  /// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#guidelines-for-choosing-the-parameters
  SecureKey call({
    required int outLen,
    required Int8List password,
    required Uint8List salt,
    required int opsLimit,
    required int memLimit,
    CryptoPwhashAlgorithm alg = CryptoPwhashAlgorithm.defaultAlg,
  });

  /// Provides crypto_pwhash_str.
  ///
  /// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#password-storage
  /// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#guidelines-for-choosing-the-parameters
  String str({
    required String password,
    required int opsLimit,
    required int memLimit,
  });

  /// Provides crypto_pwhash_str_verify.
  ///
  /// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#password-storage
  bool strVerify({required String passwordHash, required String password});

  /// Provides crypto_pwhash_str_needs_rehash.
  ///
  /// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#password-storage
  /// See https://libsodium.gitbook.io/doc/password_hashing/default_phf#guidelines-for-choosing-the-parameters
  bool strNeedsRehash({
    required String passwordHash,
    required int opsLimit,
    required int memLimit,
  });
}

/// @nodoc
@internal
mixin PwHashValidations implements Pwhash {
  /// @nodoc
  void validateOutLen(int outLen) =>
      Validations.checkInRange(outLen, bytesMin, bytesMax, 'outLen');

  /// @nodoc
  void validatePasswordHash(Int8List passwordHash) =>
      Validations.checkIsSame(passwordHash.length, strBytes, 'passwordHash');

  /// @nodoc
  void validatePasswordHashStr(String passwordHash) => Validations.checkInRange(
    passwordHash.length,
    1,
    strBytes,
    'passwordHash',
  );

  /// @nodoc
  void validatePassword(Int8List password) => Validations.checkInRange(
    password.length,
    passwdMin,
    passwdMax,
    'password',
  );

  /// @nodoc
  void validateSalt(Uint8List salt) =>
      Validations.checkIsSame(salt.length, saltBytes, 'salt');

  /// @nodoc
  void validateOpsLimit(int opsLimit) =>
      Validations.checkInRange(opsLimit, opsLimitMin, opsLimitMax, 'opsLimit');

  /// @nodoc
  void validateMemLimit(int memLimit) =>
      Validations.checkInRange(memLimit, memLimitMin, memLimitMax, 'memLimit');
}
