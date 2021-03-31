import 'dart:ffi';
import 'dart:typed_data';

import '../../api/pwhash.dart';
import '../../api/secure_key.dart';
import '../bindings/sodium.ffi.dart';
import '../bindings/sodium_pointer.dart';
import 'secure_key_ffi.dart';
import 'sodium_ffi_exception.dart';

extension CrypoPwhashAlgorithmFFI on CrypoPwhashAlgorithm {
  int toValue(SodiumFFI sodium) {
    switch (this) {
      case CrypoPwhashAlgorithm.defaultAlg:
        return sodium.crypto_pwhash_alg_default();
      case CrypoPwhashAlgorithm.argon2i13:
        return sodium.crypto_pwhash_alg_argon2i13();
      case CrypoPwhashAlgorithm.argon2id13:
        return sodium.crypto_pwhash_alg_argon2id13();
    }
  }
}

class PwhashFFI with PwHashValidations implements Pwhash {
  final SodiumFFI sodium;

  PwhashFFI(this.sodium);

  @override
  int get bytesMin => sodium.crypto_pwhash_bytes_min();
  @override
  int get bytesMax => sodium.crypto_pwhash_bytes_max();

  @override
  int get memLimitMin => sodium.crypto_pwhash_memlimit_min();
  @override
  int get memLimitSensitive => sodium.crypto_pwhash_memlimit_sensitive();
  @override
  int get memLimitModerate => sodium.crypto_pwhash_memlimit_moderate();
  @override
  int get memLimitMax => sodium.crypto_pwhash_memlimit_max();
  @override
  int get memLimitInteractive => sodium.crypto_pwhash_memlimit_interactive();

  @override
  int get opsLimitMin => sodium.crypto_pwhash_opslimit_min();
  @override
  int get opsLimitSensitive => sodium.crypto_pwhash_opslimit_sensitive();
  @override
  int get opsLimitModerate => sodium.crypto_pwhash_opslimit_moderate();
  @override
  int get opsLimitMax => sodium.crypto_pwhash_opslimit_max();
  @override
  int get opsLimitInteractive => sodium.crypto_pwhash_opslimit_interactive();

  @override
  int get passwdMin => sodium.crypto_pwhash_passwd_min();
  @override
  int get passwdMax => sodium.crypto_pwhash_passwd_max();

  @override
  int get saltBytes => sodium.crypto_pwhash_saltbytes();

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

    SodiumPointer<Int8>? passwordPtr;
    SodiumPointer<Uint8>? saltPtr;
    SecureKeyFFI? outKey;

    try {
      passwordPtr = SodiumPointer.fromList(sodium, password)
        ..memoryProtection = MemoryProtection.readOnly;

      saltPtr = SodiumPointer.fromList(sodium, salt)
        ..memoryProtection = MemoryProtection.readOnly;

      outKey = SecureKeyFFI.alloc(sodium, outLen);

      final result = outKey.runUnlockedRaw(
        (pointer) => sodium.crypto_pwhash(
          pointer.ptr,
          pointer.count,
          passwordPtr!.ptr,
          passwordPtr.count,
          saltPtr!.ptr,
          opsLimit,
          memLimit,
          alg.toValue(sodium),
        ),
      );
      SodiumFFIException.checkSucceeded(result);

      return outKey;
    } catch (e) {
      outKey?.dispose();
      rethrow;
    } finally {
      passwordPtr?.dispose();
      saltPtr?.dispose();
    }
  }
}
