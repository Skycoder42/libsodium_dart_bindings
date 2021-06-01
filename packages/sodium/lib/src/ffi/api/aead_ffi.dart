import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/aead.dart';
import '../../api/detached_cipher_result.dart';
import '../../api/secure_key.dart';
import '../../api/sodium_exception.dart';
import '../bindings/libsodium.ffi.dart';
import '../bindings/memory_protection.dart';
import '../bindings/secure_key_native.dart';
import '../bindings/sodium_pointer.dart';
import 'helpers/keygen_mixin.dart';

@internal
class AeadFFI with AeadValidations, KeygenMixin implements Aead {
  final LibSodiumFFI sodium;

  AeadFFI(this.sodium);

  @override
  int get keyBytes => sodium.crypto_aead_xchacha20poly1305_ietf_keybytes();

  @override
  int get nonceBytes => sodium.crypto_aead_xchacha20poly1305_ietf_npubbytes();

  @override
  int get aBytes => sodium.crypto_aead_xchacha20poly1305_ietf_abytes();

  @override
  SecureKey keygen() => keygenImpl(
        sodium: sodium,
        keyBytes: keyBytes,
        implementation: sodium.crypto_aead_xchacha20poly1305_ietf_keygen,
      );

  @override
  Uint8List encrypt({
    required Uint8List message,
    required Uint8List nonce,
    required SecureKey key,
    Uint8List? additionalData,
  }) {
    validateNonce(nonce);
    validateKey(key);

    SodiumPointer<Uint8>? dataPtr;
    SodiumPointer<Uint8>? noncePtr;
    SodiumPointer<Uint8>? adPtr;
    try {
      dataPtr = SodiumPointer.alloc(
        sodium,
        count: message.length + aBytes,
      )
        ..fill(message)
        ..fill(
          List<int>.filled(aBytes, 0),
          offset: message.length,
        );
      noncePtr = nonce.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      adPtr = additionalData?.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = key.runUnlockedNative(
        sodium,
        (keyPtr) => sodium.crypto_aead_xchacha20poly1305_ietf_encrypt(
          dataPtr!.ptr,
          nullptr,
          dataPtr.ptr,
          message.length,
          adPtr?.ptr ?? nullptr,
          adPtr?.count ?? 0,
          nullptr,
          noncePtr!.ptr,
          keyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return dataPtr.copyAsList();
    } finally {
      dataPtr?.dispose();
      noncePtr?.dispose();
      adPtr?.dispose();
    }
  }

  @override
  Uint8List decrypt({
    required Uint8List cipherText,
    required Uint8List nonce,
    required SecureKey key,
    Uint8List? additionalData,
  }) {
    validateEasyCipherText(cipherText);
    validateNonce(nonce);
    validateKey(key);

    SodiumPointer<Uint8>? dataPtr;
    SodiumPointer<Uint8>? noncePtr;
    SodiumPointer<Uint8>? adPtr;
    try {
      dataPtr = cipherText.toSodiumPointer(sodium);
      noncePtr = nonce.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      adPtr = additionalData?.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = key.runUnlockedNative(
        sodium,
        (keyPtr) => sodium.crypto_aead_xchacha20poly1305_ietf_decrypt(
          dataPtr!.ptr,
          nullptr,
          nullptr,
          dataPtr.ptr,
          dataPtr.count,
          adPtr?.ptr ?? nullptr,
          adPtr?.count ?? 0,
          noncePtr!.ptr,
          keyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return dataPtr.copyAsList(dataPtr.count - aBytes);
    } finally {
      dataPtr?.dispose();
      noncePtr?.dispose();
      adPtr?.dispose();
    }
  }

  @override
  DetachedCipherResult encryptDetached({
    required Uint8List message,
    required Uint8List nonce,
    required SecureKey key,
    Uint8List? additionalData,
  }) {
    validateNonce(nonce);
    validateKey(key);

    SodiumPointer<Uint8>? dataPtr;
    SodiumPointer<Uint8>? noncePtr;
    SodiumPointer<Uint8>? adPtr;
    SodiumPointer<Uint8>? macPtr;
    try {
      dataPtr = message.toSodiumPointer(sodium);
      noncePtr = nonce.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      adPtr = additionalData?.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      macPtr = SodiumPointer.alloc(sodium, count: aBytes);

      final result = key.runUnlockedNative(
        sodium,
        (keyPtr) => sodium.crypto_aead_xchacha20poly1305_ietf_encrypt_detached(
          dataPtr!.ptr,
          macPtr!.ptr,
          nullptr,
          dataPtr.ptr,
          dataPtr.count,
          adPtr?.ptr ?? nullptr,
          adPtr?.count ?? 0,
          nullptr,
          noncePtr!.ptr,
          keyPtr.ptr,
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
      adPtr?.dispose();
      macPtr?.dispose();
    }
  }

  @override
  Uint8List decryptDetached({
    required Uint8List cipherText,
    required Uint8List mac,
    required Uint8List nonce,
    required SecureKey key,
    Uint8List? additionalData,
  }) {
    validateMac(mac);
    validateNonce(nonce);
    validateKey(key);

    SodiumPointer<Uint8>? dataPtr;
    SodiumPointer<Uint8>? macPtr;
    SodiumPointer<Uint8>? noncePtr;
    SodiumPointer<Uint8>? adPtr;
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
      adPtr = additionalData?.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = key.runUnlockedNative(
        sodium,
        (keyPtr) => sodium.crypto_aead_xchacha20poly1305_ietf_decrypt_detached(
          dataPtr!.ptr,
          nullptr,
          dataPtr.ptr,
          dataPtr.count,
          macPtr!.ptr,
          adPtr?.ptr ?? nullptr,
          adPtr?.count ?? 0,
          noncePtr!.ptr,
          keyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return dataPtr.copyAsList();
    } finally {
      dataPtr?.dispose();
      macPtr?.dispose();
      noncePtr?.dispose();
      adPtr?.dispose();
    }
  }
}
