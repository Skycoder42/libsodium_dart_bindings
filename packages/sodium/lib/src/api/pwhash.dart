import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'secure_key.dart';

enum CrypoPwhashAlgorithm {
  defaultAlg,
  argon2i13,
  argon2id13,
}

abstract class Pwhash {
  const Pwhash._(); // coverage:ignore-line

  int get bytesMin;
  int get bytesMax;

  int get memLimitMin;
  int get memLimitInteractive;
  int get memLimitModerate;
  int get memLimitSensitive;
  int get memLimitMax;

  int get opsLimitMin;
  int get opsLimitInteractive;
  int get opsLimitModerate;
  int get opsLimitSensitive;
  int get opsLimitMax;

  int get passwdMin;
  int get passwdMax;

  int get saltBytes;

  int get strBytes;

  SecureKey call({
    required int outLen,
    required Int8List password,
    required Uint8List salt,
    required int opsLimit,
    required int memLimit,
    CrypoPwhashAlgorithm alg = CrypoPwhashAlgorithm.defaultAlg,
  });

  String str({
    required String password,
    required int opsLimit,
    required int memLimit,
  });

  bool strVerify({
    required String passwordHash,
    required String password,
  });

  bool strNeedsRehash({
    required String passwordHash,
    required int opsLimit,
    required int memLimit,
  });
}

@internal
mixin PwHashValidations implements Pwhash {
  void validateOutLen(int outLen) => RangeError.checkValueInInterval(
        outLen,
        bytesMin,
        bytesMax,
        'outLen',
      );

  void validatePasswordHash(Int8List passwordHash) =>
      RangeError.checkValueInInterval(
        passwordHash.length,
        strBytes,
        strBytes,
        'passwordHash',
      );

  void validatePasswordHashStr(String passwordHash) =>
      RangeError.checkValueInInterval(
        passwordHash.length,
        1,
        strBytes,
        'passwordHash',
      );

  void validatePassword(Int8List password) => RangeError.checkValueInInterval(
        password.length,
        passwdMin,
        passwdMax,
        'password',
      );

  void validateSalt(Uint8List salt) => RangeError.checkValueInInterval(
        salt.length,
        saltBytes,
        saltBytes,
        'salt',
      );

  void validateOpsLimit(int opsLimit) => RangeError.checkValueInInterval(
        opsLimit,
        opsLimitMin,
        opsLimitMax,
        'opsLimit',
      );

  void validateMemLimit(int memLimit) => RangeError.checkValueInInterval(
        memLimit,
        memLimitMin,
        memLimitMax,
        'memLimit',
      );
}
