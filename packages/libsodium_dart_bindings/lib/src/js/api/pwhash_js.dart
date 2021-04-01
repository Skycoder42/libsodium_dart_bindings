import 'dart:js';
import 'dart:typed_data';

import 'package:libsodium_dart_bindings/src/api/pwhash.dart';
import 'package:libsodium_dart_bindings/src/api/secure_key.dart';
import 'package:libsodium_dart_bindings/src/api/sodium_exception.dart';
import 'package:libsodium_dart_bindings/src/api/string_x.dart';
import 'package:libsodium_dart_bindings/src/js/bindings/num_x.dart';
import 'package:libsodium_dart_bindings/src/js/api/secure_key_js.dart';

extension CrypoPwhashAlgorithmJS on CrypoPwhashAlgorithm {
  int getValue(JsObject sodium) {
    switch (this) {
      case CrypoPwhashAlgorithm.defaultAlg:
        return (sodium['crypto_pwhash_ALG_DEFAULT'] as num).toSafeInt();
      case CrypoPwhashAlgorithm.argon2i13:
        return (sodium['crypto_pwhash_ALG_ARGON2I13'] as num).toSafeInt();
      case CrypoPwhashAlgorithm.argon2id13:
        return (sodium['crypto_pwhash_ALG_ARGON2ID13'] as num).toSafeInt();
    }
  }
}

class PwhashJs with PwHashValidations implements Pwhash {
  final JsObject sodium;

  PwhashJs(this.sodium);

  @override
  int get bytesMin => (sodium['crypto_pwhash_BYTES_MIN'] as num).toSafeInt();
  @override
  int get bytesMax => (sodium['crypto_pwhash_BYTES_MAX'] as num).toSafeInt();

  @override
  int get memLimitMin =>
      (sodium['crypto_pwhash_MEMLIMIT_MIN'] as num).toSafeInt();
  @override
  int get memLimitSensitive =>
      (sodium['crypto_pwhash_MEMLIMIT_SENSITIVE'] as num).toSafeInt();
  @override
  int get memLimitModerate =>
      (sodium['crypto_pwhash_MEMLIMIT_MODERATE'] as num).toSafeInt();
  @override
  int get memLimitMax =>
      (sodium['crypto_pwhash_MEMLIMIT_MAX'] as num).toSafeInt();
  @override
  int get memLimitInteractive =>
      (sodium['crypto_pwhash_MEMLIMIT_INTERACTIVE'] as num).toSafeInt();

  @override
  int get opsLimitMin =>
      (sodium['crypto_pwhash_OPSLIMIT_MIN'] as num).toSafeInt();
  @override
  int get opsLimitSensitive =>
      (sodium['crypto_pwhash_OPSLIMIT_SENSITIVE'] as num).toSafeInt();
  @override
  int get opsLimitModerate =>
      (sodium['crypto_pwhash_OPSLIMIT_MODERATE'] as num).toSafeInt();
  @override
  int get opsLimitMax =>
      (sodium['crypto_pwhash_OPSLIMIT_MAX'] as num).toSafeInt();
  @override
  int get opsLimitInteractive =>
      (sodium['crypto_pwhash_OPSLIMIT_INTERACTIVE'] as num).toSafeInt();

  @override
  int get passwdMin => (sodium['crypto_pwhash_PASSWD_MIN'] as num).toSafeInt();
  @override
  int get passwdMax => (sodium['crypto_pwhash_PASSWD_MAX'] as num).toSafeInt();

  @override
  int get saltBytes => (sodium['crypto_pwhash_SALTBYTES'] as num).toSafeInt();

  @override
  int get strBytes => (sodium['crypto_pwhash_STRBYTES'] as num).toSafeInt();

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

    final result = sodium.callMethod('crypto_pwhash', <dynamic>[
      outLen,
      Uint8List.view(password.buffer),
      salt,
      opsLimit,
      memLimit,
      alg.getValue(sodium),
      'uint8array',
    ]) as Uint8List?;
    return SecureKeyJs(sodium, SodiumException.checkSucceededObject(result));
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
    final result = sodium.callMethod('crypto_pwhash_str', <dynamic>[
      passwordBytes,
      opsLimit,
      memLimit,
    ]) as String?;
    return SodiumException.checkSucceededObject(result);
  }

  @override
  void strVerify(
    String password,
    String passwordHash,
  ) {
    final passwordBytes = Uint8List.view(password.toCharArray().buffer);
    final result = sodium.callMethod('crypto_pwhash_str_verify', <dynamic>[
      passwordHash,
      passwordBytes,
    ]) as bool;
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
