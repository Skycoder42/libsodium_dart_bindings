import 'dart:typed_data';

import 'package:libsodium_dart_bindings/src/api/pwhash.dart';
import 'package:libsodium_dart_bindings/src/api/secure_key.dart';
import 'package:libsodium_dart_bindings/src/api/sodium_exception.dart';
import 'package:libsodium_dart_bindings/src/api/string_x.dart';
import 'package:libsodium_dart_bindings/src/js/bindings/num_x.dart';
import 'package:libsodium_dart_bindings/src/js/api/secure_key_js.dart';
import 'package:libsodium_dart_bindings/src/js/bindings/node_modules/@types/libsodium-wrappers.dart';

extension CrypoPwhashAlgorithmJS on CrypoPwhashAlgorithm {
  int get value {
    switch (this) {
      case CrypoPwhashAlgorithm.defaultAlg:
        return crypto_pwhash_ALG_DEFAULT.toSafeInt();
      case CrypoPwhashAlgorithm.argon2i13:
        return crypto_pwhash_ALG_ARGON2I13.toSafeInt();
      case CrypoPwhashAlgorithm.argon2id13:
        return crypto_pwhash_ALG_ARGON2ID13.toSafeInt();
    }
  }
}

class PwhashJs with PwHashValidations implements Pwhash {
  @override
  int get bytesMin => crypto_pwhash_BYTES_MIN.toSafeInt();
  @override
  int get bytesMax => crypto_pwhash_BYTES_MAX.toSafeInt();

  @override
  int get memLimitMin => crypto_pwhash_MEMLIMIT_MIN.toSafeInt();
  @override
  int get memLimitSensitive => crypto_pwhash_MEMLIMIT_SENSITIVE.toSafeInt();
  @override
  int get memLimitModerate => crypto_pwhash_MEMLIMIT_MODERATE.toSafeInt();
  @override
  int get memLimitMax => crypto_pwhash_MEMLIMIT_MAX.toSafeInt();
  @override
  int get memLimitInteractive => crypto_pwhash_MEMLIMIT_INTERACTIVE.toSafeInt();

  @override
  int get opsLimitMin => crypto_pwhash_OPSLIMIT_MIN.toSafeInt();
  @override
  int get opsLimitSensitive => crypto_pwhash_OPSLIMIT_SENSITIVE.toSafeInt();
  @override
  int get opsLimitModerate => crypto_pwhash_OPSLIMIT_MODERATE.toSafeInt();
  @override
  int get opsLimitMax => crypto_pwhash_OPSLIMIT_MAX.toSafeInt();
  @override
  int get opsLimitInteractive => crypto_pwhash_OPSLIMIT_INTERACTIVE.toSafeInt();

  @override
  int get passwdMin => crypto_pwhash_PASSWD_MIN.toSafeInt();
  @override
  int get passwdMax => crypto_pwhash_PASSWD_MAX.toSafeInt();

  @override
  int get saltBytes => crypto_pwhash_SALTBYTES.toSafeInt();

  @override
  int get strBytes => crypto_pwhash_STRBYTES.toSafeInt();

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
      Uint8List.view(password.buffer),
      salt,
      opsLimit,
      memLimit,
      alg.value,
      'uint8array',
    ) as Uint8List?;
    return SecureKeyJs(SodiumException.checkSucceededObject(result));
  }

  @override
  String str(
    String password,
    int opsLimit,
    int memLimit,
  ) {
    validateOpsLimit(opsLimit);
    validateMemLimit(memLimit);

    final passwordBytes = Uint8List.view(password.toCharArray().buffer);
    final result = crypto_pwhash_str(passwordBytes, opsLimit, memLimit);
    return SodiumException.checkSucceededObject(result);
  }

  @override
  void strVerify(
    String password,
    String passwordHash,
  ) {
    final passwordBytes = Uint8List.view(password.toCharArray().buffer);
    final result = crypto_pwhash_str_verify(passwordHash, passwordBytes);
    SodiumException.checkSucceededBool(result);
  }

  @override
  bool strNeedsRehash(
    String passwordHash,
    int opsLimit,
    int memLimit,
  ) {
    // TODO try implement anyways
    throw UnsupportedError(
      'crypto_pwhash_str_needs_rehash is not available in web',
    );
  }
}
