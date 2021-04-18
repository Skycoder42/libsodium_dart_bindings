import 'dart:ffi';
import 'dart:typed_data';

import 'package:sodium/src/api/secure_key.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/secure_key_ffi.dart';
import 'package:sodium/src/ffi/bindings/sodium_pointer.dart';

import '../../api/secret_box.dart';
import '../bindings/libsodium.ffi.dart';

class SecretBoxFII with SecretBoxValidations implements SecretBox {
  final LibSodiumFFI sodium;

  SecretBoxFII(this.sodium);

  @override
  int get keyBytes => sodium.crypto_secretbox_keybytes();

  @override
  int get macBytes => sodium.crypto_secretbox_macbytes();

  @override
  int get nonceBytes => sodium.crypto_secretbox_noncebytes();

  @override
  SecureKey keygen() {
    final key = SecureKeyFFI.alloc(sodium, keyBytes);
    try {
      key.runUnlockedRaw(
        (pointer) => sodium.crypto_secretbox_keygen(pointer.ptr),
        writable: true,
      );
      return key;
    } catch (e) {
      key.dispose();
      rethrow;
    }
  }

  @override
  Uint8List easy({
    required Uint8List message,
    required Uint8List nonce,
    required SecureKey key,
  }) {
    validateNonce(nonce);
    validateKey(key);

    SodiumPointer<Uint8>? dataPtr;
    SodiumPointer<Uint8>? noncePtr;
    try {
      dataPtr = SodiumPointer.alloc(
        sodium,
        count: message.length + macBytes,
        zeroMemory: true,
      )..asList().setAll(macBytes, message);
      noncePtr = nonce.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      final result = key.safeCast().runUnlockedRaw(
            (keyPtr) => sodium.crypto_secretbox_easy(
              dataPtr!.ptr,
              dataPtr.ptr.elementAt(macBytes),
              message.length,
              noncePtr!.ptr,
              keyPtr.ptr,
            ),
          );
      SodiumException.checkSucceededInt(result);
      return dataPtr.copyAsList();
    } finally {
      dataPtr?.dispose();
      noncePtr?.dispose();
    }
  }

  @override
  Uint8List openEasy({
    required Uint8List ciphertext,
    required Uint8List nonce,
    required SecureKey key,
  }) {
    validateNonce(nonce);
    validateKey(key);

    SodiumPointer<Uint8>? dataPtr;
    SodiumPointer<Uint8>? noncePtr;
    try {
      dataPtr = ciphertext.toSodiumPointer(sodium);
      noncePtr = nonce.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      final result = key.safeCast().runUnlockedRaw(
            (keyPtr) => sodium.crypto_secretbox_open_easy(
              dataPtr!.ptr.elementAt(macBytes),
              dataPtr.ptr,
              dataPtr.count,
              noncePtr!.ptr,
              keyPtr.ptr,
            ),
          );
      SodiumException.checkSucceededInt(result);
      return Uint8List.fromList(
        dataPtr.ptr
            .elementAt(macBytes)
            .asTypedList(ciphertext.length - macBytes),
      );
    } finally {
      dataPtr?.dispose();
      noncePtr?.dispose();
    }
  }

  @override
  DetachedSecretBoxResult detached({
    required Uint8List message,
    required Uint8List nonce,
    required SecureKey key,
  }) {
    validateNonce(nonce);
    validateKey(key);

    SodiumPointer<Uint8>? messagePtr;
    SodiumPointer<Uint8>? noncePtr;
    SodiumPointer<Uint8>? cipherPtr;
    SodiumPointer<Uint8>? macPtr;
    try {
      messagePtr = message.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      noncePtr = nonce.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      cipherPtr = SodiumPointer.alloc(sodium, count: messagePtr.count);
      macPtr = SodiumPointer.alloc(sodium, count: macBytes);

      final result = key.safeCast().runUnlockedRaw(
            (keyPtr) => sodium.crypto_secretbox_detached(
              cipherPtr!.ptr,
              macPtr!.ptr,
              messagePtr!.ptr,
              messagePtr.count,
              noncePtr!.ptr,
              keyPtr.ptr,
            ),
          );
      SodiumException.checkSucceededInt(result);

      return DetachedSecretBoxResult(
        cipher: cipherPtr.copyAsList(),
        mac: macPtr.copyAsList(),
      );
    } finally {
      messagePtr?.dispose();
      noncePtr?.dispose();
      cipherPtr?.dispose();
      macPtr?.dispose();
    }
  }

  @override
  Uint8List openDetached({
    required Uint8List ciphertext,
    required Uint8List mac,
    required Uint8List nonce,
    required SecureKey key,
  }) {
    validateMac(mac);
    validateNonce(nonce);
    validateKey(key);

    SodiumPointer<Uint8>? cipherPtr;
    SodiumPointer<Uint8>? macPtr;
    SodiumPointer<Uint8>? noncePtr;
    SodiumPointer<Uint8>? messagePtr;
    try {
      cipherPtr = ciphertext.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      macPtr = mac.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      noncePtr = nonce.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      messagePtr = SodiumPointer.alloc(sodium, count: cipherPtr.count);

      final result = key.safeCast().runUnlockedRaw(
            (keyPtr) => sodium.crypto_secretbox_open_detached(
              messagePtr!.ptr,
              cipherPtr!.ptr,
              macPtr!.ptr,
              cipherPtr.count,
              noncePtr!.ptr,
              keyPtr.ptr,
            ),
          );
      SodiumException.checkSucceededInt(result);

      return messagePtr.copyAsList();
    } finally {
      cipherPtr?.dispose();
      macPtr?.dispose();
      noncePtr?.dispose();
      messagePtr?.dispose();
    }
  }
}
