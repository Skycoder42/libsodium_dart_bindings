import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/detached_cipher_result.dart';
import '../../api/secret_box.dart';
import '../../api/secure_key.dart';
import '../../api/sodium_exception.dart';
import '../bindings/libsodium.ffi.dart';
import '../bindings/memory_protection.dart';
import '../bindings/secure_key_native.dart';
import '../bindings/sodium_pointer.dart';
import 'helpers/keygen_mixin.dart';

/// @nodoc
@internal
class SecretBoxFFI with SecretBoxValidations, KeygenMixin implements SecretBox {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  SecretBoxFFI(this.sodium);

  @override
  int get keyBytes => sodium.crypto_secretbox_keybytes();

  @override
  int get macBytes => sodium.crypto_secretbox_macbytes();

  @override
  int get nonceBytes => sodium.crypto_secretbox_noncebytes();

  @override
  SecureKey keygen() => keygenImpl(
    sodium: sodium,
    keyBytes: keyBytes,
    implementation: sodium.crypto_secretbox_keygen,
  );

  @override
  Uint8List easy({
    required Uint8List message,
    required Uint8List nonce,
    required SecureKey key,
  }) {
    validateNonce(nonce);
    validateKey(key);

    SodiumPointer<UnsignedChar>? dataPtr;
    SodiumPointer<UnsignedChar>? noncePtr;
    try {
      dataPtr = SodiumPointer.alloc(sodium, count: message.length + macBytes)
        ..fill(List<int>.filled(macBytes, 0))
        ..fill(message, offset: macBytes);
      noncePtr = nonce.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = key.runUnlockedNative(
        sodium,
        (keyPtr) => sodium.crypto_secretbox_easy(
          dataPtr!.ptr,
          dataPtr.viewAt(macBytes).ptr,
          message.length,
          noncePtr!.ptr,
          keyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return dataPtr.asListView(owned: true);
    } catch (_) {
      dataPtr?.dispose();
      rethrow;
    } finally {
      noncePtr?.dispose();
    }
  }

  @override
  Uint8List openEasy({
    required Uint8List cipherText,
    required Uint8List nonce,
    required SecureKey key,
  }) {
    validateEasyCipherText(cipherText);
    validateNonce(nonce);
    validateKey(key);

    SodiumPointer<UnsignedChar>? dataPtr;
    SodiumPointer<UnsignedChar>? noncePtr;
    try {
      dataPtr = cipherText.toSodiumPointer(sodium);
      noncePtr = nonce.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = key.runUnlockedNative(
        sodium,
        (keyPtr) => sodium.crypto_secretbox_open_easy(
          dataPtr!.viewAt(macBytes).ptr,
          dataPtr.ptr,
          dataPtr.count,
          noncePtr!.ptr,
          keyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return Uint8List.sublistView(
        dataPtr.asListView<Uint8List>(owned: true),
        macBytes,
      );
    } catch (_) {
      dataPtr?.dispose();
      rethrow;
    } finally {
      noncePtr?.dispose();
    }
  }

  @override
  DetachedCipherResult detached({
    required Uint8List message,
    required Uint8List nonce,
    required SecureKey key,
  }) {
    validateNonce(nonce);
    validateKey(key);

    SodiumPointer<UnsignedChar>? dataPtr;
    SodiumPointer<UnsignedChar>? noncePtr;
    SodiumPointer<UnsignedChar>? macPtr;
    try {
      dataPtr = message.toSodiumPointer(sodium);
      noncePtr = nonce.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      macPtr = SodiumPointer.alloc(sodium, count: macBytes);

      final result = key.runUnlockedNative(
        sodium,
        (keyPtr) => sodium.crypto_secretbox_detached(
          dataPtr!.ptr,
          macPtr!.ptr,
          dataPtr.ptr,
          dataPtr.count,
          noncePtr!.ptr,
          keyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return DetachedCipherResult(
        cipherText: dataPtr.asListView(owned: true),
        mac: macPtr.asListView(owned: true),
      );
    } catch (_) {
      dataPtr?.dispose();
      macPtr?.dispose();
      rethrow;
    } finally {
      noncePtr?.dispose();
    }
  }

  @override
  Uint8List openDetached({
    required Uint8List cipherText,
    required Uint8List mac,
    required Uint8List nonce,
    required SecureKey key,
  }) {
    validateMac(mac);
    validateNonce(nonce);
    validateKey(key);

    SodiumPointer<UnsignedChar>? dataPtr;
    SodiumPointer<UnsignedChar>? macPtr;
    SodiumPointer<UnsignedChar>? noncePtr;
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

      final result = key.runUnlockedNative(
        sodium,
        (keyPtr) => sodium.crypto_secretbox_open_detached(
          dataPtr!.ptr,
          dataPtr.ptr,
          macPtr!.ptr,
          dataPtr.count,
          noncePtr!.ptr,
          keyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return dataPtr.asListView(owned: true);
    } catch (_) {
      dataPtr?.dispose();
      rethrow;
    } finally {
      macPtr?.dispose();
      noncePtr?.dispose();
    }
  }
}
