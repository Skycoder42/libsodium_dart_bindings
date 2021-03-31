import 'dart:typed_data';

import 'package:libsodium_dart_bindings/src/api/pwhash.dart';
import 'package:libsodium_dart_bindings/src/api/secure_key.dart';
import 'package:libsodium_dart_bindings/src/js/api/secure_key_js.dart';
import 'package:libsodium_dart_bindings/src/js/node_modules/@types/libsodium-wrappers.dart';

extension CrypoPwhashAlgorithmJS on CrypoPwhashAlgorithm {
  int get value {
    switch (this) {
      case CrypoPwhashAlgorithm.defaultAlg:
        return crypto_pwhash_ALG_DEFAULT as int;
      case CrypoPwhashAlgorithm.argon2i13:
        return crypto_pwhash_ALG_ARGON2I13 as int;
      case CrypoPwhashAlgorithm.argon2id13:
        return crypto_pwhash_ALG_ARGON2ID13 as int;
    }
  }
}

class PwhashJs with PwHashValidations implements Pwhash {
  @override
  int get bytesMin => crypto_pwhash_BYTES_MIN as int;
  @override
  int get bytesMax => crypto_pwhash_BYTES_MAX as int;

  @override
  int get memLimitMin => crypto_pwhash_MEMLIMIT_MIN as int;
  @override
  int get memLimitSensitive => crypto_pwhash_MEMLIMIT_SENSITIVE as int;
  @override
  int get memLimitModerate => crypto_pwhash_MEMLIMIT_MODERATE as int;
  @override
  int get memLimitMax => crypto_pwhash_MEMLIMIT_MAX as int;
  @override
  int get memLimitInteractive => crypto_pwhash_MEMLIMIT_INTERACTIVE as int;

  @override
  int get opsLimitMin => crypto_pwhash_OPSLIMIT_MIN as int;
  @override
  int get opsLimitSensitive => crypto_pwhash_OPSLIMIT_SENSITIVE as int;
  @override
  int get opsLimitModerate => crypto_pwhash_OPSLIMIT_MODERATE as int;
  @override
  int get opsLimitMax => crypto_pwhash_OPSLIMIT_MAX as int;
  @override
  int get opsLimitInteractive => crypto_pwhash_OPSLIMIT_INTERACTIVE as int;

  @override
  int get passwdMin => crypto_pwhash_PASSWD_MIN as int;
  @override
  int get passwdMax => crypto_pwhash_PASSWD_MAX as int;

  @override
  int get saltBytes => crypto_pwhash_SALTBYTES as int;

  @override
  SecureKey call(
    int outLen,
    Int8List password,
    Uint8List salt,
    int opsLimit,
    int memLimit,
    CrypoPwhashAlgorithm alg,
  ) {
    validateOutLen(outLen);
    validatePassword(password);
    validateSalt(salt);
    validateOpsLimit(opsLimit);
    validateMemLimit(memLimit);

    final result = crypto_pwhash(
      outLen,
      password,
      salt,
      opsLimit,
      memLimit,
      alg.value,
      'Uint8Array',
    ) as Uint8List;
    return SecureKeyJs(result);
  }
}
