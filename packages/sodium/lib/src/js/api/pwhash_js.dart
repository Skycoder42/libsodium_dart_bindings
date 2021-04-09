import 'dart:typed_data';

import '../../api/pwhash.dart';
import '../../api/secure_key.dart';
import '../../api/sodium_exception.dart';
import '../bindings/sodium.js.dart';
import '../bindings/to_safe_int.dart';
import 'secure_key_js.dart';

extension CrypoPwhashAlgorithmJS on CrypoPwhashAlgorithm {
  int getValue(LibSodiumJS sodium) {
    switch (this) {
      case CrypoPwhashAlgorithm.defaultAlg:
        return sodium.crypto_pwhash_ALG_DEFAULT;
      case CrypoPwhashAlgorithm.argon2i13:
        return sodium.crypto_pwhash_ALG_ARGON2I13;
      case CrypoPwhashAlgorithm.argon2id13:
        return sodium.crypto_pwhash_ALG_ARGON2ID13;
    }
  }
}

class PwhashJs with PwHashValidations implements Pwhash {
  final LibSodiumJS sodium;

  PwhashJs(this.sodium);

  @override
  int get bytesMin => sodium.crypto_pwhash_BYTES_MIN.toSafeUInt();
  @override
  int get bytesMax => sodium.crypto_pwhash_BYTES_MAX.toSafeUInt();

  @override
  int get memLimitMin => sodium.crypto_pwhash_MEMLIMIT_MIN.toSafeUInt();
  @override
  int get memLimitSensitive =>
      sodium.crypto_pwhash_MEMLIMIT_SENSITIVE.toSafeUInt();
  @override
  int get memLimitModerate =>
      sodium.crypto_pwhash_MEMLIMIT_MODERATE.toSafeUInt();
  @override
  int get memLimitMax => sodium.crypto_pwhash_MEMLIMIT_MAX.toSafeUInt();
  @override
  int get memLimitInteractive =>
      sodium.crypto_pwhash_MEMLIMIT_INTERACTIVE.toSafeUInt();

  @override
  int get opsLimitMin => sodium.crypto_pwhash_OPSLIMIT_MIN.toSafeUInt();
  @override
  int get opsLimitSensitive =>
      sodium.crypto_pwhash_OPSLIMIT_SENSITIVE.toSafeUInt();
  @override
  int get opsLimitModerate =>
      sodium.crypto_pwhash_OPSLIMIT_MODERATE.toSafeUInt();
  @override
  int get opsLimitMax => sodium.crypto_pwhash_OPSLIMIT_MAX.toSafeUInt();
  @override
  int get opsLimitInteractive =>
      sodium.crypto_pwhash_OPSLIMIT_INTERACTIVE.toSafeUInt();

  @override
  int get passwdMin => sodium.crypto_pwhash_PASSWD_MIN.toSafeUInt();
  @override
  int get passwdMax => sodium.crypto_pwhash_PASSWD_MAX.toSafeUInt();

  @override
  int get saltBytes => sodium.crypto_pwhash_SALTBYTES.toSafeUInt();

  @override
  int get strBytes => sodium.crypto_pwhash_STRBYTES.toSafeUInt();

  @override
  SecureKey call({
    required int outLen,
    required Int8List password,
    required Uint8List salt,
    required int opsLimit,
    required int memLimit,
    CrypoPwhashAlgorithm alg = CrypoPwhashAlgorithm.defaultAlg,
  }) {
    validateOutLen(outLen);
    validatePassword(password);
    validateSalt(salt);
    validateOpsLimit(opsLimit);
    validateMemLimit(memLimit);

    final result = sodium.crypto_pwhash(
      outLen,
      Uint8List.view(password.buffer),
      salt,
      opsLimit,
      memLimit,
      alg.getValue(sodium),
    );
    return SecureKeyJs(sodium, SodiumException.checkSucceededObject(result));
  }

  @override
  String str({
    required String password,
    required int opsLimit,
    required int memLimit,
  }) {
    validateOpsLimit(opsLimit);
    validateMemLimit(memLimit);

    final result = sodium.crypto_pwhash_str(
      password,
      opsLimit,
      memLimit,
    );
    return SodiumException.checkSucceededObject(result);
  }

  @override
  bool strVerify({
    required String passwordHash,
    required String password,
  }) =>
      sodium.crypto_pwhash_str_verify(
        passwordHash,
        password,
      );

  @override
  bool strNeedsRehash({
    required String passwordHash,
    required int opsLimit,
    required int memLimit,
  }) =>
      sodium.crypto_pwhash_str_needs_rehash(
        passwordHash,
        opsLimit,
        memLimit,
      );
}
