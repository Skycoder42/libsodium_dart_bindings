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

/// @nodoc
@internal
class AeadChacha20Poly1305FFI with AeadValidations, KeygenMixin implements Aead {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  AeadChacha20Poly1305FFI(this.sodium);

  @override
  int get keyBytes => sodium.crypto_aead_chacha20poly1305_keybytes();

  @override
  int get nonceBytes => sodium.crypto_aead_chacha20poly1305_ietf_npubbytes();

  @override
  int get aBytes => sodium.crypto_aead_chacha20poly1305_abytes();

  @override
  SecureKey keygen() => keygenImpl(
        sodium: sodium,
        keyBytes: keyBytes,
        implementation: sodium.crypto_aead_chacha20poly1305_keygen,
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

    SodiumPointer<UnsignedChar>? dataPtr;
    SodiumPointer<UnsignedChar>? noncePtr;
    SodiumPointer<UnsignedChar>? adPtr;
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
        (keyPtr) => sodium.crypto_aead_chacha20poly1305_encrypt(
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

      return Uint8List.fromList(dataPtr.asListView());
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

    SodiumPointer<UnsignedChar>? dataPtr;
    SodiumPointer<UnsignedChar>? noncePtr;
    SodiumPointer<UnsignedChar>? adPtr;
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
        (keyPtr) => sodium.crypto_aead_chacha20poly1305_decrypt(
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

      return Uint8List.fromList(
        dataPtr.viewAt(0, dataPtr.count - aBytes).asListView(),
      );
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

    SodiumPointer<UnsignedChar>? dataPtr;
    SodiumPointer<UnsignedChar>? noncePtr;
    SodiumPointer<UnsignedChar>? adPtr;
    SodiumPointer<UnsignedChar>? macPtr;
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
        (keyPtr) => sodium.crypto_aead_chacha20poly1305_encrypt_detached(
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
        cipherText: Uint8List.fromList(dataPtr.asListView()),
        mac: Uint8List.fromList(macPtr.asListView()),
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

    SodiumPointer<UnsignedChar>? dataPtr;
    SodiumPointer<UnsignedChar>? macPtr;
    SodiumPointer<UnsignedChar>? noncePtr;
    SodiumPointer<UnsignedChar>? adPtr;
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
        (keyPtr) => sodium.crypto_aead_chacha20poly1305_decrypt_detached(
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

      return Uint8List.fromList(dataPtr.asListView());
    } finally {
      dataPtr?.dispose();
      macPtr?.dispose();
      noncePtr?.dispose();
      adPtr?.dispose();
    }
  }
}
