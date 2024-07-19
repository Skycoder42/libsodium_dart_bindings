import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../api/secure_key.dart';
import '../../../api/string_x.dart';
import '../../../api/sumo/pwhash.dart';
import '../../bindings/int_helpers_x.dart';
import '../../bindings/js_error.dart';
import '../../bindings/sodium.js.dart';
import '../secure_key_js.dart';

/// @nodoc
@visibleForTesting
extension CrypoPwhashAlgorithmJS on CryptoPwhashAlgorithm {
  /// @nodoc
  int getValue(LibSodiumJS sodium) {
    switch (this) {
      case CryptoPwhashAlgorithm.defaultAlg:
        return sodium.crypto_pwhash_ALG_DEFAULT;
      case CryptoPwhashAlgorithm.argon2i13:
        return sodium.crypto_pwhash_ALG_ARGON2I13;
      case CryptoPwhashAlgorithm.argon2id13:
        return sodium.crypto_pwhash_ALG_ARGON2ID13;
    }
  }
}

/// @nodoc
@internal
class PwhashJS with PwHashValidations implements Pwhash {
  @visibleForTesting
  static const memLimitMaxFallback = 4398046510080;

  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  PwhashJS(this.sodium);

  @override
  int get bytesMin => sodium.crypto_pwhash_BYTES_MIN;
  @override
  int get bytesMax => sodium.crypto_pwhash_BYTES_MAX.safeUint32();

  @override
  int get memLimitMin => sodium.crypto_pwhash_MEMLIMIT_MIN;
  @override
  int get memLimitInteractive => sodium.crypto_pwhash_MEMLIMIT_INTERACTIVE;
  @override
  int get memLimitModerate => sodium.crypto_pwhash_MEMLIMIT_MODERATE;
  @override
  int get memLimitSensitive => sodium.crypto_pwhash_MEMLIMIT_SENSITIVE;
  @override
  int get memLimitMax =>
      sodium.crypto_pwhash_MEMLIMIT_MAX.safeUnsigned(memLimitMaxFallback);

  @override
  int get opsLimitMin => sodium.crypto_pwhash_OPSLIMIT_MIN;
  @override
  int get opsLimitInteractive => sodium.crypto_pwhash_OPSLIMIT_INTERACTIVE;
  @override
  int get opsLimitModerate => sodium.crypto_pwhash_OPSLIMIT_MODERATE;
  @override
  int get opsLimitSensitive => sodium.crypto_pwhash_OPSLIMIT_SENSITIVE;
  @override
  int get opsLimitMax => sodium.crypto_pwhash_OPSLIMIT_MAX.safeUint32();

  @override
  int get passwdMin => sodium.crypto_pwhash_PASSWD_MIN;
  @override
  int get passwdMax => sodium.crypto_pwhash_PASSWD_MAX.safeUint32();

  @override
  int get saltBytes => sodium.crypto_pwhash_SALTBYTES;

  @override
  int get strBytes => sodium.crypto_pwhash_STRBYTES;

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
        Uint8List.view(password.buffer).toJS,
        salt.toJS,
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
        passwordChars.unsignedView().toJS,
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
        passwordChars.unsignedView().toJS,
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
