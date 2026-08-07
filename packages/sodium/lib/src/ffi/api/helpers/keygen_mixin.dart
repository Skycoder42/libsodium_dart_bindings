import 'dart:ffi';

import 'package:meta/meta.dart';

import '../../../api/key_pair.dart';
import '../../../api/secure_key.dart';
import '../../../api/sodium_exception.dart';
import '../../bindings/libsodium.ffi.wrapper.dart';
import '../../bindings/secure_key_native.dart';
import '../../bindings/sodium_scope.dart';

/// @nodoc
@internal
mixin KeygenMixin {
  /// @nodoc
  @protected
  SecureKey keygenImpl({
    required LibSodiumFFI sodium,
    required int keyBytes,
    required void Function(Pointer<UnsignedChar> k) implementation,
  }) => sodiumScope(sodium, (scope) {
    final key = scope.allocSecureKey(keyBytes)
      ..runUnlockedNative(
        (pointer) => implementation(pointer.ptr),
        writable: true,
      );
    return scope.takeSecureKey(key);
  });

  /// @nodoc
  @protected
  KeyPair keyPairImpl({
    required LibSodiumFFI sodium,
    required int secretKeyBytes,
    required int publicKeyBytes,
    required int Function(Pointer<UnsignedChar> pk, Pointer<UnsignedChar> sk)
    implementation,
  }) => sodiumScope(sodium, (scope) {
    final secretKey = scope.allocSecureKey(secretKeyBytes);
    final publicKeyPtr = scope.alloc<UnsignedChar>(publicKeyBytes);

    final result = secretKey.runUnlockedNative(
      (secretKeyPtr) => implementation(publicKeyPtr.ptr, secretKeyPtr.ptr),
      writable: true,
    );
    SodiumException.checkSucceededInt(result);

    return KeyPair(
      secretKey: scope.takeSecureKey(secretKey),
      publicKey: scope.takeBytes(publicKeyPtr),
    );
  });

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
  }) => sodiumScope(sodium, (scope) {
    final secretKey = scope.allocSecureKey(secretKeyBytes);
    final publicKeyPtr = scope.alloc<UnsignedChar>(publicKeyBytes);

    final result = secretKey.runUnlockedNative(
      (secretKeyPtr) => seed.runUnlockedNative(
        sodium,
        (seedPtr) =>
            implementation(publicKeyPtr.ptr, secretKeyPtr.ptr, seedPtr.ptr),
      ),
      writable: true,
    );
    SodiumException.checkSucceededInt(result);

    return KeyPair(
      secretKey: scope.takeSecureKey(secretKey),
      publicKey: scope.takeBytes(publicKeyPtr),
    );
  });
}
