import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/pwhash.dart';
import '../../api/secure_key.dart';
import '../../api/sodium_exception.dart';
import '../../api/string_x.dart';
import '../bindings/libsodium.ffi.dart';
import '../bindings/memory_protection.dart';
import '../bindings/size_t_extension.dart';
import '../bindings/sodium_pointer.dart';
import 'secure_key_ffi.dart';

@internal
class PwhashFFI with PwHashValidations implements Pwhash {
  final LibSodiumFFI sodium;

  PwhashFFI(this.sodium);

  @override
  int get bytesMin => sodium.crypto_pwhash_bytes_min();
  @override
  int get bytesMax => sodium.crypto_pwhash_bytes_max().toSizeT();

  @override
  int get memLimitMin => sodium.crypto_pwhash_memlimit_min().toSizeT();
  @override
  int get memLimitInteractive =>
      sodium.crypto_pwhash_memlimit_interactive().toSizeT();
  @override
  int get memLimitModerate =>
      sodium.crypto_pwhash_memlimit_moderate().toSizeT();
  @override
  int get memLimitSensitive =>
      sodium.crypto_pwhash_memlimit_sensitive().toSizeT();
  @override
  int get memLimitMax => sodium.crypto_pwhash_memlimit_max().toSizeT();

  @override
  int get opsLimitMin => sodium.crypto_pwhash_opslimit_min().toSizeT();
  @override
  int get opsLimitInteractive =>
      sodium.crypto_pwhash_opslimit_interactive().toSizeT();
  @override
  int get opsLimitModerate =>
      sodium.crypto_pwhash_opslimit_moderate().toSizeT();
  @override
  int get opsLimitSensitive =>
      sodium.crypto_pwhash_opslimit_sensitive().toSizeT();
  @override
  int get opsLimitMax => sodium.crypto_pwhash_opslimit_max().toSizeT();

  @override
  int get passwdMin => sodium.crypto_pwhash_passwd_min().toSizeT();
  @override
  int get passwdMax => sodium.crypto_pwhash_passwd_max().toSizeT();

  @override
  int get saltBytes => sodium.crypto_pwhash_saltbytes().toSizeT();

  @override
  int get strBytes => sodium.crypto_pwhash_strbytes().toSizeT();

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

    SodiumPointer<Int8>? passwordPtr;
    SodiumPointer<Uint8>? saltPtr;
    SecureKeyFFI? outKey;

    try {
      passwordPtr = password.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      saltPtr = salt.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      outKey = SecureKeyFFI.alloc(sodium, outLen);

      final result = outKey.runUnlockedNative(
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
        writable: true,
      );
      SodiumException.checkSucceededInt(result);

      return outKey;
    } catch (e) {
      outKey?.dispose();
      rethrow;
    } finally {
      passwordPtr?.dispose();
      saltPtr?.dispose();
    }
  }

  @override
  String str({
    required String password,
    required int opsLimit,
    required int memLimit,
  }) {
    validateOpsLimit(opsLimit);
    validateMemLimit(memLimit);

    SodiumPointer<Int8>? passwordPtr;
    SodiumPointer<Int8>? passwordHashPtr;

    try {
      passwordPtr = password.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      validatePassword(passwordPtr.asList());

      passwordHashPtr = SodiumPointer<Int8>.alloc(
        sodium,
        count: strBytes,
        zeroMemory: true,
      );

      final result = sodium.crypto_pwhash_str(
        passwordHashPtr.ptr,
        passwordPtr.ptr,
        passwordPtr.count,
        opsLimit,
        memLimit,
      );
      SodiumException.checkSucceededInt(result);

      return passwordHashPtr.asList().toDartString(zeroTerminated: true);
    } finally {
      passwordPtr?.dispose();
      passwordHashPtr?.dispose();
    }
  }

  @override
  bool strVerify({
    required String passwordHash,
    required String password,
  }) {
    SodiumPointer<Int8>? passwordPtr;
    SodiumPointer<Int8>? passwordHashPtr;
    try {
      passwordPtr = password.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      validatePassword(passwordPtr.asList());

      passwordHashPtr = passwordHash.toSodiumPointer(
        sodium,
        memoryWidth: strBytes,
        memoryProtection: MemoryProtection.readOnly,
      );
      validatePasswordHash(passwordHashPtr.asList());

      final result = sodium.crypto_pwhash_str_verify(
        passwordHashPtr.ptr,
        passwordPtr.ptr,
        passwordPtr.count,
      );

      return result == 0;
    } finally {
      passwordPtr?.dispose();
      passwordHashPtr?.dispose();
    }
  }

  @override
  bool strNeedsRehash({
    required String passwordHash,
    required int opsLimit,
    required int memLimit,
  }) {
    validateOpsLimit(opsLimit);
    validateMemLimit(memLimit);

    SodiumPointer<Int8>? passwordHashPtr;
    try {
      passwordHashPtr = passwordHash.toSodiumPointer(
        sodium,
        memoryWidth: strBytes,
        memoryProtection: MemoryProtection.readOnly,
      );
      validatePasswordHash(passwordHashPtr.asList());

      final result = sodium.crypto_pwhash_str_needs_rehash(
        passwordHashPtr.ptr,
        opsLimit,
        memLimit,
      );

      switch (result) {
        case 0:
          return false;
        case 1:
          return true;
        default:
          throw SodiumException();
      }
    } finally {
      passwordHashPtr?.dispose();
    }
  }
}

@visibleForTesting
extension CryptoPwhashAlgorithmFFI on CryptoPwhashAlgorithm {
  int toValue(LibSodiumFFI sodium) {
    switch (this) {
      case CryptoPwhashAlgorithm.defaultAlg:
        return sodium.crypto_pwhash_alg_default();
      case CryptoPwhashAlgorithm.argon2i13:
        return sodium.crypto_pwhash_alg_argon2i13();
      case CryptoPwhashAlgorithm.argon2id13:
        return sodium.crypto_pwhash_alg_argon2id13();
    }
  }
}
