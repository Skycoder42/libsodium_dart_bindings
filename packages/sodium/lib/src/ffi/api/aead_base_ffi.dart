import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/aead.dart';
import '../../api/detached_cipher_result.dart';
import '../../api/secure_key.dart';
import '../../api/sodium_exception.dart';
import '../bindings/libsodium.ffi.wrapper.dart';
import '../bindings/secure_key_native.dart';
import '../bindings/sodium_scope.dart';
import 'helpers/keygen_mixin.dart';

/// @nodoc
@internal
typedef InternalEncrypt = int Function(
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
typedef InternalDecrypt = int Function(
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
typedef InternalEncryptDetached = int Function(
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
typedef InternalDecryptDetached = int Function(
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
  new(this.sodium);

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

    return sodiumScope(sodium, (scope) {
      final dataPtr = scope.alloc<UnsignedChar>(message.length + aBytes)
        ..fill(message)
        ..fill(List<int>.filled(aBytes, 0), offset: message.length);
      final noncePtr = scope.copyList<UnsignedChar>(nonce);
      final adPtr = additionalData != null
          ? scope.copyList<UnsignedChar>(additionalData)
          : null;

      final result = key.runUnlockedNative(
        sodium,
        (keyPtr) => internalEncrypt(
          dataPtr.ptr,
          nullptr,
          dataPtr.ptr,
          message.length,
          adPtr?.ptr ?? nullptr,
          adPtr?.count ?? 0,
          nullptr,
          noncePtr.ptr,
          keyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return scope.takeBytes(dataPtr);
    });
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

    return sodiumScope(sodium, (scope) {
      final dataPtr = scope.copyList<UnsignedChar>(
        cipherText,
        memoryProtection: .readWrite,
      );
      final noncePtr = scope.copyList<UnsignedChar>(nonce);
      final adPtr = additionalData != null
          ? scope.copyList<UnsignedChar>(additionalData)
          : null;

      final result = key.runUnlockedNative(
        sodium,
        (keyPtr) => internalDecrypt(
          dataPtr.ptr,
          nullptr,
          nullptr,
          dataPtr.ptr,
          dataPtr.count,
          adPtr?.ptr ?? nullptr,
          adPtr?.count ?? 0,
          noncePtr.ptr,
          keyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      final messageLength = dataPtr.count - aBytes;
      return Uint8List.sublistView(
        scope.takeBytes<Uint8List>(dataPtr),
        0,
        messageLength,
      );
    });
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

    return sodiumScope(sodium, (scope) {
      final dataPtr = scope.copyList<UnsignedChar>(
        message,
        memoryProtection: .readWrite,
      );
      final noncePtr = scope.copyList<UnsignedChar>(nonce);
      final adPtr = additionalData != null
          ? scope.copyList<UnsignedChar>(additionalData)
          : null;
      final macPtr = scope.alloc<UnsignedChar>(aBytes);

      final result = key.runUnlockedNative(
        sodium,
        (keyPtr) => internalEncryptDetached(
          dataPtr.ptr,
          macPtr.ptr,
          nullptr,
          dataPtr.ptr,
          dataPtr.count,
          adPtr?.ptr ?? nullptr,
          adPtr?.count ?? 0,
          nullptr,
          noncePtr.ptr,
          keyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return DetachedCipherResult(
        cipherText: scope.takeBytes(dataPtr),
        mac: scope.takeBytes(macPtr),
      );
    });
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

    return sodiumScope(sodium, (scope) {
      final dataPtr = scope.copyList<UnsignedChar>(
        cipherText,
        memoryProtection: .readWrite,
      );
      final macPtr = scope.copyList<UnsignedChar>(mac);
      final noncePtr = scope.copyList<UnsignedChar>(nonce);
      final adPtr = additionalData != null
          ? scope.copyList<UnsignedChar>(additionalData)
          : null;

      final result = key.runUnlockedNative(
        sodium,
        (keyPtr) => internalDecryptDetached(
          dataPtr.ptr,
          nullptr,
          dataPtr.ptr,
          dataPtr.count,
          macPtr.ptr,
          adPtr?.ptr ?? nullptr,
          adPtr?.count ?? 0,
          noncePtr.ptr,
          keyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return scope.takeBytes(dataPtr);
    });
  }
}
