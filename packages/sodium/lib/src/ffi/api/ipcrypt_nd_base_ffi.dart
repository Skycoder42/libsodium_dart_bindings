import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/ipcrypt.dart';
import '../../api/secure_key.dart';
import '../bindings/libsodium.ffi.wrapper.dart';
import '../bindings/secure_key_native.dart';
import '../bindings/sodium_pointer.dart';
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
  IpcryptNdBaseFFI(this.sodium);

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

    SodiumPointer<UnsignedChar>? tweakPtr;
    SodiumPointer<UnsignedChar>? outPtr;
    try {
      tweakPtr = tweak.toSodiumPointer(sodium, memoryProtection: .readOnly);
      outPtr = SodiumPointer.alloc(sodium, count: outputBytes);

      key.runUnlockedNative(
        sodium,
        (keyPtr) => internalEncrypt(
          outPtr!.ptr,
          input.rawBytes.ptr,
          tweakPtr!.ptr,
          keyPtr.ptr,
        ),
      );

      return outPtr.asListView(owned: true);
    } catch (_) {
      outPtr?.dispose();
      rethrow;
    } finally {
      tweakPtr?.dispose();
    }
  }

  @override
  IpAddressFFI decrypt({
    required Uint8List cipherText,
    required SecureKey key,
  }) {
    validateCipherText(cipherText);
    validateKey(key);

    SodiumPointer<UnsignedChar>? outPtr;
    SodiumPointer<UnsignedChar>? inPtr;
    try {
      outPtr = SodiumPointer.alloc(sodium, count: inputBytes);
      inPtr = cipherText.toSodiumPointer(sodium, memoryProtection: .readOnly);

      key.runUnlockedNative(
        sodium,
        (keyPtr) => internalDecrypt(outPtr!.ptr, inPtr!.ptr, keyPtr.ptr),
      );

      return IpAddressFFI.fromPointer(sodium, outPtr);
    } catch (_) {
      outPtr?.dispose();
      rethrow;
    } finally {
      inPtr?.dispose();
    }
  }
}
