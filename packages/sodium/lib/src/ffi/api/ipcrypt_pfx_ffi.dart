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
class IpcryptPfxFFI
    with IpcryptPfxValidations, KeygenMixin
    implements IpcryptPfx {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  IpcryptPfxFFI(this.sodium);

  @override
  int get keyBytes => sodium.crypto_ipcrypt_pfx_keybytes();

  @override
  int get bytes => sodium.crypto_ipcrypt_pfx_bytes();

  @override
  SecureKey keygen() => keygenImpl(
    sodium: sodium,
    keyBytes: keyBytes,
    implementation: sodium.crypto_ipcrypt_pfx_keygen,
  );

  @override
  Uint8List encrypt({
    required covariant IpAddressFFI input,
    required SecureKey key,
  }) {
    validateInput(input.bytes);
    validateKey(key);

    final outPtr = SodiumPointer<UnsignedChar>.alloc(sodium, count: bytes);
    try {
      key.runUnlockedNative(
        sodium,
        (keyPtr) => sodium.crypto_ipcrypt_pfx_encrypt(
          outPtr.ptr,
          input.rawBytes.ptr,
          keyPtr.ptr,
        ),
      );

      return outPtr.asListView(owned: true);
    } catch (_) {
      outPtr.dispose();
      rethrow;
    }
  }

  @override
  IpAddressFFI decrypt({
    required Uint8List cipherText,
    required SecureKey key,
  }) {
    validateInput(cipherText);
    validateKey(key);

    SodiumPointer<UnsignedChar>? outPtr;
    SodiumPointer<UnsignedChar>? inPtr;
    try {
      outPtr = SodiumPointer.alloc(sodium, count: bytes);
      inPtr = cipherText.toSodiumPointer(sodium, memoryProtection: .readOnly);

      key.runUnlockedNative(
        sodium,
        (keyPtr) => sodium.crypto_ipcrypt_pfx_decrypt(
          outPtr!.ptr,
          inPtr!.ptr,
          keyPtr.ptr,
        ),
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
