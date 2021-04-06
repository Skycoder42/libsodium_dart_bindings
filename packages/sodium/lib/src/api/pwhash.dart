import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'secure_key.dart';

enum CrypoPwhashAlgorithm {
  defaultAlg,
  argon2i13,
  argon2id13,
}

abstract class Pwhash {
  const Pwhash._();

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

  SecureKey call(
    int outLen,
    Int8List password,
    Uint8List salt,
    int opsLimit,
    int memLimit,
    CrypoPwhashAlgorithm alg,
  );

  String str(
    String password,
    int opsLimit,
    int memLimit,
  );

  void strVerify(
    String password,
    String passwordHash,
  );

  bool strNeedsRehash(
    String passwordHash,
    int opsLimit,
    int memLimit,
  );
}

@internal
mixin PwHashValidations implements Pwhash {
  void validateOutLen(int outLen) => RangeError.checkValueInInterval(
        outLen,
        bytesMin,
        bytesMax,
        'outLen',
      );

  void validatepasswordHash(Int8List passwordHash) =>
      RangeError.checkValueInInterval(
        passwordHash.length,
        strBytes,
        strBytes,
        'outLen',
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
