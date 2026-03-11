import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/aead.dart';
import '../../api/detached_cipher_result.dart';
import '../../api/secure_key.dart';
import '../../api/sodium_exception.dart';
import '../bindings/libsodium.ffi.wrapper.dart';
import '../bindings/memory_protection.dart';
import '../bindings/secure_key_native.dart';
import '../bindings/sodium_pointer.dart';
import 'helpers/keygen_mixin.dart';

/// @nodoc
@internal
typedef InternalEncrypt =
    int Function(
      Pointer<UnsignedChar> c,
      Pointer<UnsignedLongLong> clenP,
      Pointer<UnsignedChar> m,
      int mlen,
      Pointer<UnsignedChar> ad,
      int adlen,
      Pointer<UnsignedChar> nsec,
      Pointer<UnsignedChar> npub,
      Pointer<UnsignedChar> k,
    );

/// @nodoc
@internal
typedef InternalDecrypt =
    int Function(
      Pointer<UnsignedChar> m,
      Pointer<UnsignedLongLong> mlenP,
      Pointer<UnsignedChar> nsec,
      Pointer<UnsignedChar> c,
      int clen,
      Pointer<UnsignedChar> ad,
      int adlen,
      Pointer<UnsignedChar> npub,
      Pointer<UnsignedChar> k,
    );

/// @nodoc
@internal
typedef InternalEncryptDetached =
    int Function(
      Pointer<UnsignedChar> c,
      Pointer<UnsignedChar> mac,
      Pointer<UnsignedLongLong> maclenP,
      Pointer<UnsignedChar> m,
      int mlen,
      Pointer<UnsignedChar> ad,
      int adlen,
      Pointer<UnsignedChar> nsec,
      Pointer<UnsignedChar> npub,
      Pointer<UnsignedChar> k,
    );

/// @nodoc
@internal
typedef InternalDecryptDetached =
    int Function(
      Pointer<UnsignedChar> m,
      Pointer<UnsignedChar> nsec,
      Pointer<UnsignedChar> c,
      int clen,
      Pointer<UnsignedChar> mac,
      Pointer<UnsignedChar> ad,
      int adlen,
      Pointer<UnsignedChar> npub,
      Pointer<UnsignedChar> k,
    );

/// @nodoc
@internal
abstract class AeadBaseFFI with AeadValidations, KeygenMixin implements Aead {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  AeadBaseFFI(this.sodium);

  /// @nodoc
  @protected
  InternalEncrypt get internalEncrypt;

  /// @nodoc
  @protected
  InternalDecrypt get internalDecrypt;

  /// @nodoc
  @protected
  InternalEncryptDetached get internalEncryptDetached;

  /// @nodoc
  @protected
  InternalDecryptDetached get internalDecryptDetached;

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
      dataPtr = SodiumPointer.alloc(sodium, count: message.length + aBytes)
        ..fill(message)
        ..fill(List<int>.filled(aBytes, 0), offset: message.length);
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
        (keyPtr) => internalEncrypt(
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

      return dataPtr.asListView(owned: true);
    } catch (_) {
      dataPtr?.dispose();
      rethrow;
    } finally {
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
        (keyPtr) => internalDecrypt(
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

      return Uint8List.sublistView(
        dataPtr.asListView<Uint8List>(owned: true),
        0,
        dataPtr.count - aBytes,
      );
    } catch (_) {
      dataPtr?.dispose();
      rethrow;
    } finally {
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
        (keyPtr) => internalEncryptDetached(
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
        cipherText: dataPtr.asListView(owned: true),
        mac: macPtr.asListView(owned: true),
      );
    } catch (_) {
      dataPtr?.dispose();
      macPtr?.dispose();
      rethrow;
    } finally {
      noncePtr?.dispose();
      adPtr?.dispose();
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
        (keyPtr) => internalDecryptDetached(
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

      return dataPtr.asListView(owned: true);
    } catch (_) {
      dataPtr?.dispose();
      rethrow;
    } finally {
      macPtr?.dispose();
      noncePtr?.dispose();
      adPtr?.dispose();
    }
  }
}
