import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/ipcrypt.dart';
import '../../api/secure_key.dart';
import '../bindings/libsodium.ffi.wrapper.dart';
import '../bindings/secure_key_native.dart';
import '../bindings/sodium_scope.dart';
import 'helpers/keygen_mixin.dart';
import 'ip_address_ffi.dart';

/// @nodoc
@internal
abstract class IpcryptNdBaseFFI
    with IpcryptNdValidations, KeygenMixin
    implements IpcryptNd {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  new(this.sodium);

  /// @nodoc
  @protected
  void Function(Pointer<UnsignedChar> k) get internalKeygen;

  /// @nodoc
  @protected
  void Function(
    Pointer<UnsignedChar> out,
    Pointer<UnsignedChar> in$,
    Pointer<UnsignedChar> t,
    Pointer<UnsignedChar> k,
  )
  get internalEncrypt;

  /// @nodoc
  @protected
  void Function(
    Pointer<UnsignedChar> out,
    Pointer<UnsignedChar> in$,
    Pointer<UnsignedChar> k,
  )
  get internalDecrypt;

  @override
  SecureKey keygen() => keygenImpl(
    sodium: sodium,
    keyBytes: keyBytes,
    implementation: internalKeygen,
  );

  @override
  Uint8List encrypt({
    required covariant IpAddressFFI input,
    required Uint8List tweak,
    required SecureKey key,
  }) {
    validateInput(input.bytes);
    validateTweak(tweak);
    validateKey(key);

    return sodiumScope(sodium, (scope) {
      final tweakPtr = scope.copyList<UnsignedChar>(tweak);
      final outPtr = scope.alloc<UnsignedChar>(outputBytes);

      key.runUnlockedNative(
        sodium,
        (keyPtr) => internalEncrypt(
          outPtr.ptr,
          input.rawBytes.ptr,
          tweakPtr.ptr,
          keyPtr.ptr,
        ),
      );

      return scope.takeBytes(outPtr);
    });
  }

  @override
  IpAddressFFI decrypt({
    required Uint8List cipherText,
    required SecureKey key,
  }) {
    validateCipherText(cipherText);
    validateKey(key);

    return sodiumScope(sodium, (scope) {
      final outPtr = scope.alloc<UnsignedChar>(inputBytes);
      final inPtr = scope.copyList<UnsignedChar>(cipherText);

      key.runUnlockedNative(
        sodium,
        (keyPtr) => internalDecrypt(outPtr.ptr, inPtr.ptr, keyPtr.ptr),
      );

      return IpAddressFFI.fromPointer(sodium, scope.takePointer(outPtr));
    });
  }
}
