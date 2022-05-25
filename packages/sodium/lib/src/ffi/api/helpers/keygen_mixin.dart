import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../../api/key_pair.dart';
import '../../../api/secure_key.dart';
import '../../../api/sodium_exception.dart';
import '../../bindings/libsodium.ffi.dart';
import '../../bindings/secure_key_native.dart';
import '../../bindings/sodium_pointer.dart';
import '../secure_key_ffi.dart';

/// @nodoc
@internal
mixin KeygenMixin {
  /// @nodoc
  @protected
  SecureKey keygenImpl({
    required LibSodiumFFI sodium,
    required int keyBytes,
    required void Function(Pointer<UnsignedChar> k) implementation,
  }) {
    final key = SecureKeyFFI.alloc(sodium, keyBytes);
    try {
      return key
        ..runUnlockedNative(
          (pointer) => implementation(pointer.ptr),
          writable: true,
        );
    } catch (e) {
      key.dispose();
      rethrow;
    }
  }

  /// @nodoc
  @protected
  KeyPair keyPairImpl({
    required LibSodiumFFI sodium,
    required int secretKeyBytes,
    required int publicKeyBytes,
    required int Function(Pointer<UnsignedChar> pk, Pointer<UnsignedChar> sk)
        implementation,
  }) {
    SecureKeyFFI? secretKey;
    SodiumPointer<UnsignedChar>? publicKeyPtr;
    try {
      secretKey = SecureKeyFFI.alloc(sodium, secretKeyBytes);
      publicKeyPtr = SodiumPointer.alloc(sodium, count: publicKeyBytes);

      final result = secretKey.runUnlockedNative(
        (secretKeyPtr) => implementation(
          publicKeyPtr!.ptr,
          secretKeyPtr.ptr,
        ),
        writable: true,
      );
      SodiumException.checkSucceededInt(result);

      return KeyPair(
        secretKey: secretKey,
        publicKey: Uint8List.fromList(publicKeyPtr.asListView()),
      );
    } catch (e) {
      secretKey?.dispose();
      rethrow;
    } finally {
      publicKeyPtr?.dispose();
    }
  }

  /// @nodoc
  @protected
  KeyPair seedKeyPairImpl({
    required LibSodiumFFI sodium,
    required SecureKey seed,
    required int secretKeyBytes,
    required int publicKeyBytes,
    required int Function(
      Pointer<UnsignedChar> pk,
      Pointer<UnsignedChar> sk,
      Pointer<UnsignedChar> seed,
    )
        implementation,
  }) {
    SecureKeyFFI? secretKey;
    SodiumPointer<UnsignedChar>? publicKeyPtr;
    try {
      secretKey = SecureKeyFFI.alloc(sodium, secretKeyBytes);
      publicKeyPtr = SodiumPointer.alloc(sodium, count: publicKeyBytes);

      final result = secretKey.runUnlockedNative(
        (secretKeyPtr) => seed.runUnlockedNative(
          sodium,
          (seedPtr) => implementation(
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
        publicKey: Uint8List.fromList(publicKeyPtr.asListView()),
      );
    } catch (e) {
      secretKey?.dispose();
      rethrow;
    } finally {
      publicKeyPtr?.dispose();
    }
  }
}
