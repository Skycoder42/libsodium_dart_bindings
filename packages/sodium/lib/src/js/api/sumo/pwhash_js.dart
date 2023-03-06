import 'dart:math';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../api/secure_key.dart';
import '../../../api/string_x.dart';
import '../../../api/sumo/pwhash.dart';
import '../../bindings/js_error.dart';
import '../../bindings/sodium.js.dart';
import '../../bindings/to_safe_int.dart';
import '../secure_key_js.dart';

/// @nodoc
@visibleForTesting
extension CrypoPwhashAlgorithmJS on CryptoPwhashAlgorithm {
  /// @nodoc
  int getValue(LibSodiumJS sodium) {
    switch (this) {
      case CryptoPwhashAlgorithm.defaultAlg:
        return sodium.crypto_pwhash_ALG_DEFAULT.toSafeUInt32();
      case CryptoPwhashAlgorithm.argon2i13:
        return sodium.crypto_pwhash_ALG_ARGON2I13.toSafeUInt32();
      case CryptoPwhashAlgorithm.argon2id13:
        return sodium.crypto_pwhash_ALG_ARGON2ID13.toSafeUInt32();
    }
  }
}

/// @nodoc
@internal
class PwhashJS with PwHashValidations implements Pwhash {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  PwhashJS(this.sodium);

  @override
  int get bytesMin => sodium.crypto_pwhash_BYTES_MIN.toSafeUInt32();
  @override
  int get bytesMax => sodium.crypto_pwhash_BYTES_MAX.toSafeUInt32();

  @override
  int get memLimitMin => sodium.crypto_pwhash_MEMLIMIT_MIN.toSafeUInt64();
  @override
  int get memLimitInteractive =>
      sodium.crypto_pwhash_MEMLIMIT_INTERACTIVE.toSafeUInt64();
  @override
  int get memLimitModerate =>
      sodium.crypto_pwhash_MEMLIMIT_MODERATE.toSafeUInt64();
  @override
  int get memLimitSensitive =>
      sodium.crypto_pwhash_MEMLIMIT_SENSITIVE.toSafeUInt64();
  @override
  int get memLimitMax => min(
        sodium.crypto_pwhash_MEMLIMIT_MAX.toSafeUInt64(),
        4398046510080, // as -1 is returned, the actual max is not right
      );

  @override
  int get opsLimitMin => sodium.crypto_pwhash_OPSLIMIT_MIN.toSafeUInt32();
  @override
  int get opsLimitInteractive =>
      sodium.crypto_pwhash_OPSLIMIT_INTERACTIVE.toSafeUInt32();
  @override
  int get opsLimitModerate =>
      sodium.crypto_pwhash_OPSLIMIT_MODERATE.toSafeUInt32();
  @override
  int get opsLimitSensitive =>
      sodium.crypto_pwhash_OPSLIMIT_SENSITIVE.toSafeUInt32();
  @override
  int get opsLimitMax => sodium.crypto_pwhash_OPSLIMIT_MAX.toSafeUInt32();

  @override
  int get passwdMin => sodium.crypto_pwhash_PASSWD_MIN.toSafeUInt32();
  @override
  int get passwdMax => sodium.crypto_pwhash_PASSWD_MAX.toSafeUInt32();

  @override
  int get saltBytes => sodium.crypto_pwhash_SALTBYTES.toSafeUInt32();

  @override
  int get strBytes => sodium.crypto_pwhash_STRBYTES.toSafeUInt32();

  @override
  SecureKey call({
    required int outLen,
    required Int8List password,
    required Uint8List salt,
    required int opsLimit,
    required int memLimit,
    CryptoPwhashAlgorithm alg = CryptoPwhashAlgorithm.defaultAlg,
  }) {
    validateOutLen(outLen);
    validatePassword(password);
    validateSalt(salt);
    validateOpsLimit(opsLimit);
    validateMemLimit(memLimit);

    final result = jsErrorWrap(
      () => sodium.crypto_pwhash(
        outLen,
        Uint8List.view(password.buffer),
        salt,
        opsLimit,
        memLimit,
        alg.getValue(sodium),
      ),
    );
    return SecureKeyJS(sodium, result);
  }

  @override
  String str({
    required String password,
    required int opsLimit,
    required int memLimit,
  }) {
    final passwordChars = password.toCharArray();
    validatePassword(passwordChars);
    validateOpsLimit(opsLimit);
    validateMemLimit(memLimit);

    final result = jsErrorWrap(
      () => sodium.crypto_pwhash_str(
        passwordChars.unsignedView(),
        opsLimit,
        memLimit,
      ),
    );
    return result;
  }

  @override
  bool strVerify({
    required String passwordHash,
    required String password,
  }) {
    final passwordChars = password.toCharArray();
    validatePasswordHashStr(passwordHash);
    validatePassword(passwordChars);

    return jsErrorWrap(
      () => sodium.crypto_pwhash_str_verify(
        passwordHash,
        passwordChars.unsignedView(),
      ),
    );
  }

  @override
  bool strNeedsRehash({
    required String passwordHash,
    required int opsLimit,
    required int memLimit,
  }) {
    validatePasswordHashStr(passwordHash);
    validateOpsLimit(opsLimit);
    validateMemLimit(memLimit);

    return jsErrorWrap(
      () => sodium.crypto_pwhash_str_needs_rehash(
        passwordHash,
        opsLimit,
        memLimit,
      ),
    );
  }
}
