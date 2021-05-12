import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/box.dart';
import '../../api/detached_cipher_result.dart';
import '../../api/key_pair.dart';
import '../../api/secure_key.dart';
import '../../api/sodium_exception.dart';
import '../bindings/libsodium.ffi.dart';
import '../bindings/memory_protection.dart';
import '../bindings/secure_key_native.dart';
import '../bindings/sodium_pointer.dart';
import 'secure_key_ffi.dart';

@internal
class BoxFFI with BoxValidations implements Box {
  final LibSodiumFFI sodium;

  BoxFFI(this.sodium);

  @override
  int get publicKeyBytes => sodium.crypto_box_publickeybytes();

  @override
  int get secretKeyBytes => sodium.crypto_box_secretkeybytes();

  @override
  int get macBytes => sodium.crypto_box_macbytes();

  @override
  int get nonceBytes => sodium.crypto_box_noncebytes();

  @override
  int get seedBytes => sodium.crypto_box_seedbytes();

  @override
  KeyPair keyPair() {
    SecureKeyFFI? secretKey;
    SodiumPointer<Uint8>? publicKeyPtr;
    try {
      secretKey = SecureKeyFFI.alloc(sodium, secretKeyBytes);
      publicKeyPtr = SodiumPointer.alloc(sodium, count: publicKeyBytes);

      final result = secretKey.runUnlockedNative(
        (secretKeyPtr) => sodium.crypto_box_keypair(
          publicKeyPtr!.ptr,
          secretKeyPtr.ptr,
        ),
        writable: true,
      );
      SodiumException.checkSucceededInt(result);

      return KeyPair(
        secretKey: secretKey,
        publicKey: publicKeyPtr.copyAsList(),
      );
    } catch (e) {
      secretKey?.dispose();
      rethrow;
    } finally {
      publicKeyPtr?.dispose();
    }
  }

  @override
  KeyPair seedKeyPair(SecureKey seed) {
    validateSeed(seed);

    SecureKeyFFI? secretKey;
    SodiumPointer<Uint8>? publicKeyPtr;
    try {
      secretKey = SecureKeyFFI.alloc(sodium, secretKeyBytes);
      publicKeyPtr = SodiumPointer.alloc(sodium, count: publicKeyBytes);

      final result = secretKey.runUnlockedNative(
        (secretKeyPtr) => seed.runUnlockedNative(
          sodium,
          (seedPtr) => sodium.crypto_box_seed_keypair(
            publicKeyPtr!.ptr,
            secretKeyPtr.ptr,
            seedPtr.ptr,
          ),
        ),
        writable: true,
      );
      SodiumException.checkSucceededInt(result);

      return KeyPair(
        secretKey: secretKey,
        publicKey: publicKeyPtr.copyAsList(),
      );
    } catch (e) {
      secretKey?.dispose();
      rethrow;
    } finally {
      publicKeyPtr?.dispose();
    }
  }

  @override
  Uint8List easy({
    required Uint8List message,
    required Uint8List nonce,
    required Uint8List recipientPublicKey,
    required SecureKey senderSecretKey,
  }) {
    validateNonce(nonce);
    validatePublicKey(recipientPublicKey);
    validateSecretKey(senderSecretKey);

    SodiumPointer<Uint8>? dataPtr;
    SodiumPointer<Uint8>? noncePtr;
    SodiumPointer<Uint8>? publicKeyPtr;
    try {
      dataPtr = SodiumPointer.alloc(
        sodium,
        count: message.length + macBytes,
      )
        ..fill(List<int>.filled(macBytes, 0))
        ..fill(message, offset: macBytes);
      noncePtr = nonce.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      publicKeyPtr = recipientPublicKey.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = senderSecretKey.runUnlockedNative(
        sodium,
        (secretKeyPtr) => sodium.crypto_box_easy(
          dataPtr!.ptr,
          dataPtr.viewAt(macBytes).ptr,
          message.length,
          noncePtr!.ptr,
          publicKeyPtr!.ptr,
          secretKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return dataPtr.copyAsList();
    } finally {
      dataPtr?.dispose();
      noncePtr?.dispose();
      publicKeyPtr?.dispose();
    }
  }

  @override
  Uint8List openEasy({
    required Uint8List cipherText,
    required Uint8List nonce,
    required Uint8List senderPublicKey,
    required SecureKey recipientSecretKey,
  }) {
    validateEasyCipherText(cipherText);
    validateNonce(nonce);
    validatePublicKey(senderPublicKey);
    validateSecretKey(recipientSecretKey);

    SodiumPointer<Uint8>? dataPtr;
    SodiumPointer<Uint8>? noncePtr;
    SodiumPointer<Uint8>? publicKeyPtr;
    try {
      dataPtr = cipherText.toSodiumPointer(sodium);
      noncePtr = nonce.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      publicKeyPtr = senderPublicKey.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = recipientSecretKey.runUnlockedNative(
        sodium,
        (secretKeyPtr) => sodium.crypto_box_open_easy(
          dataPtr!.viewAt(macBytes).ptr,
          dataPtr.ptr,
          dataPtr.count,
          noncePtr!.ptr,
          publicKeyPtr!.ptr,
          secretKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return dataPtr.viewAt(macBytes).copyAsList();
    } finally {
      dataPtr?.dispose();
      noncePtr?.dispose();
      publicKeyPtr?.dispose();
    }
  }

  @override
  DetachedCipherResult detached({
    required Uint8List message,
    required Uint8List nonce,
    required Uint8List recipientPublicKey,
    required SecureKey senderSecretKey,
  }) {
    validateNonce(nonce);
    validatePublicKey(recipientPublicKey);
    validateSecretKey(senderSecretKey);

    SodiumPointer<Uint8>? dataPtr;
    SodiumPointer<Uint8>? noncePtr;
    SodiumPointer<Uint8>? publicKeyPtr;
    SodiumPointer<Uint8>? macPtr;
    try {
      dataPtr = message.toSodiumPointer(sodium);
      noncePtr = nonce.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      publicKeyPtr = recipientPublicKey.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      macPtr = SodiumPointer.alloc(sodium, count: macBytes);

      final result = senderSecretKey.runUnlockedNative(
        sodium,
        (secretKeyPtr) => sodium.crypto_box_detached(
          dataPtr!.ptr,
          macPtr!.ptr,
          dataPtr.ptr,
          dataPtr.count,
          noncePtr!.ptr,
          publicKeyPtr!.ptr,
          secretKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return DetachedCipherResult(
        cipherText: dataPtr.copyAsList(),
        mac: macPtr.copyAsList(),
      );
    } finally {
      dataPtr?.dispose();
      noncePtr?.dispose();
      publicKeyPtr?.dispose();
      macPtr?.dispose();
    }
  }

  @override
  Uint8List openDetached({
    required Uint8List cipherText,
    required Uint8List mac,
    required Uint8List nonce,
    required Uint8List senderPublicKey,
    required SecureKey recipientSecretKey,
  }) {
    validateMac(mac);
    validateNonce(nonce);
    validatePublicKey(senderPublicKey);
    validateSecretKey(recipientSecretKey);

    SodiumPointer<Uint8>? dataPtr;
    SodiumPointer<Uint8>? macPtr;
    SodiumPointer<Uint8>? noncePtr;
    SodiumPointer<Uint8>? publicKeyPtr;
    try {
      dataPtr = cipherText.toSodiumPointer(sodium);
      macPtr = mac.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      noncePtr = nonce.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      publicKeyPtr = senderPublicKey.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = recipientSecretKey.runUnlockedNative(
        sodium,
        (secretKeyPtr) => sodium.crypto_box_open_detached(
          dataPtr!.ptr,
          dataPtr.ptr,
          macPtr!.ptr,
          dataPtr.count,
          noncePtr!.ptr,
          publicKeyPtr!.ptr,
          secretKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return dataPtr.copyAsList();
    } finally {
      dataPtr?.dispose();
      macPtr?.dispose();
      noncePtr?.dispose();
      publicKeyPtr?.dispose();
    }
  }
}
