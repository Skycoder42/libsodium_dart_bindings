import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/auth.dart';
import '../../api/secure_key.dart';
import '../../api/sodium_exception.dart';
import '../bindings/libsodium.ffi.dart';
import '../bindings/memory_protection.dart';
import '../bindings/secure_key_native.dart';
import '../bindings/sodium_pointer.dart';
import 'secure_key_ffi.dart';

@internal
class AuthFFI with AuthValidations implements Auth {
  final LibSodiumFFI sodium;

  AuthFFI(this.sodium);

  @override
  int get bytes => sodium.crypto_auth_bytes();

  @override
  int get keyBytes => sodium.crypto_auth_keybytes();

  @override
  SecureKey keygen() {
    final key = SecureKeyFFI.alloc(sodium, keyBytes);
    try {
      return key
        ..runUnlockedNative(
          (pointer) => sodium.crypto_auth_keygen(pointer.ptr),
          writable: true,
        );
    } catch (e) {
      key.dispose();
      rethrow;
    }
  }

  @override
  Uint8List call({
    required Uint8List message,
    required SecureKey key,
  }) {
    validateKey(key);

    SodiumPointer<Uint8>? messagePtr;
    SodiumPointer<Uint8>? tagPtr;
    try {
      messagePtr = message.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      tagPtr = SodiumPointer.alloc(sodium, count: bytes);

      final result = key.runUnlockedNative(
        sodium,
        (keyPtr) => sodium.crypto_auth(
          tagPtr!.ptr,
          messagePtr!.ptr,
          messagePtr.count,
          keyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return tagPtr.copyAsList();
    } finally {
      messagePtr?.dispose();
      tagPtr?.dispose();
    }
  }

  @override
  bool verify({
    required Uint8List tag,
    required Uint8List message,
    required SecureKey key,
  }) {
    validateTag(tag);
    validateKey(key);

    SodiumPointer<Uint8>? messagePtr;
    SodiumPointer<Uint8>? tagPtr;
    try {
      messagePtr = message.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      tagPtr = tag.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = key.runUnlockedNative(
        sodium,
        (keyPtr) => sodium.crypto_auth_verify(
          tagPtr!.ptr,
          messagePtr!.ptr,
          messagePtr.count,
          keyPtr.ptr,
        ),
      );

      return result == 0;
    } finally {
      messagePtr?.dispose();
      tagPtr?.dispose();
    }
  }
}
