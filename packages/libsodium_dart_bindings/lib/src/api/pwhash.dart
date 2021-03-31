import 'dart:typed_data';

import 'package:libsodium_dart_bindings/src/api/secure_key.dart';
import 'package:meta/meta.dart';

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
  int get memLimitSensitive;
  int get memLimitModerate;
  int get memLimitMax;
  int get memLimitInteractive;

  int get opsLimitMin;
  int get opsLimitSensitive;
  int get opsLimitModerate;
  int get opsLimitMax;
  int get opsLimitInteractive;

  int get passwdMin;
  int get passwdMax;

  int get saltBytes;

  SecureKey call(
    int outLen,
    Int8List password,
    Uint8List salt,
    int opsLimit,
    int memLimit,
    CrypoPwhashAlgorithm alg,
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
