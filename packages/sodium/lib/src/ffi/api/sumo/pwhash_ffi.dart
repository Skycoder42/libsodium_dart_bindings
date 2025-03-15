import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../api/secure_key.dart';
import '../../../api/sodium_exception.dart';
import '../../../api/sumo/pwhash.dart';
import '../../bindings/libsodium.ffi.dart';
import '../../bindings/memory_protection.dart';
import '../../bindings/sodium_pointer.dart';
import '../secure_key_ffi.dart';

/// @nodoc
@internal
class PwhashFFI with PwHashValidations implements Pwhash {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  PwhashFFI(this.sodium);

  @override
  int get bytesMin => sodium.crypto_pwhash_bytes_min();
  @override
  int get bytesMax => sodium.crypto_pwhash_bytes_max();

  @override
  int get memLimitMin => sodium.crypto_pwhash_memlimit_min();
  @override
  int get memLimitInteractive => sodium.crypto_pwhash_memlimit_interactive();
  @override
  int get memLimitModerate => sodium.crypto_pwhash_memlimit_moderate();
  @override
  int get memLimitSensitive => sodium.crypto_pwhash_memlimit_sensitive();
  @override
  int get memLimitMax => sodium.crypto_pwhash_memlimit_max();

  @override
  int get opsLimitMin => sodium.crypto_pwhash_opslimit_min();
  @override
  int get opsLimitInteractive => sodium.crypto_pwhash_opslimit_interactive();
  @override
  int get opsLimitModerate => sodium.crypto_pwhash_opslimit_moderate();
  @override
  int get opsLimitSensitive => sodium.crypto_pwhash_opslimit_sensitive();
  @override
  int get opsLimitMax => sodium.crypto_pwhash_opslimit_max();

  @override
  int get passwdMin => sodium.crypto_pwhash_passwd_min();
  @override
  int get passwdMax => sodium.crypto_pwhash_passwd_max();

  @override
  int get saltBytes => sodium.crypto_pwhash_saltbytes();

  @override
  int get strBytes => sodium.crypto_pwhash_strbytes();

  @override
  @pragma('vm:entry-point')
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

    SodiumPointer<Char>? passwordPtr;
    SodiumPointer<UnsignedChar>? saltPtr;
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

    SodiumPointer<Char>? passwordPtr;
    SodiumPointer<Char>? passwordHashPtr;

    try {
      passwordPtr = password.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      validatePassword(passwordPtr.asListView());

      passwordHashPtr = SodiumPointer<Char>.alloc(
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

      return passwordHashPtr.toDartString(zeroTerminated: true);
    } finally {
      passwordPtr?.dispose();
      passwordHashPtr?.dispose();
    }
  }

  @override
  bool strVerify({required String passwordHash, required String password}) {
    SodiumPointer<Char>? passwordPtr;
    SodiumPointer<Char>? passwordHashPtr;
    try {
      passwordPtr = password.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      validatePassword(passwordPtr.asListView());

      passwordHashPtr = passwordHash.toSodiumPointer(
        sodium,
        memoryWidth: strBytes,
        memoryProtection: MemoryProtection.readOnly,
      );
      validatePasswordHash(passwordHashPtr.asListView());

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

    SodiumPointer<Char>? passwordHashPtr;
    try {
      passwordHashPtr = passwordHash.toSodiumPointer(
        sodium,
        memoryWidth: strBytes,
        memoryProtection: MemoryProtection.readOnly,
      );
      validatePasswordHash(passwordHashPtr.asListView());

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

/// @nodoc
@visibleForTesting
extension CryptoPwhashAlgorithmFFI on CryptoPwhashAlgorithm {
  /// @nodoc
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
