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
import 'ipcrypt_nd_ffi.dart';
import 'ipcrypt_ndx_ffi.dart';
import 'ipcrypt_pfx_ffi.dart';

/// @nodoc
@internal
class IpcryptFFI with IpcryptValidations, KeygenMixin implements Ipcrypt {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  IpcryptFFI(this.sodium);

  @override
  int get bytes => sodium.crypto_ipcrypt_bytes();

  @override
  int get keyBytes => sodium.crypto_ipcrypt_keybytes();

  @override
  late final IpcryptNd nd = IpcryptNdFFI(sodium);

  @override
  late final IpcryptNd ndx = IpcryptNdxFFI(sodium);

  @override
  late final IpcryptPfx pfx = IpcryptPfxFFI(sodium);

  @override
  SecureKey keygen() => keygenImpl(
    sodium: sodium,
    keyBytes: keyBytes,
    implementation: sodium.crypto_ipcrypt_keygen,
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
        (keyPtr) => sodium.crypto_ipcrypt_encrypt(
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
  IpAddressFFI decrypt({required Uint8List input, required SecureKey key}) {
    validateInput(input);
    validateKey(key);

    SodiumPointer<UnsignedChar>? outPtr;
    SodiumPointer<UnsignedChar>? inPtr;
    try {
      outPtr = SodiumPointer.alloc(sodium, count: bytes);
      inPtr = input.toSodiumPointer(sodium, memoryProtection: .readOnly);

      key.runUnlockedNative(
        sodium,
        (keyPtr) =>
            sodium.crypto_ipcrypt_decrypt(outPtr!.ptr, inPtr!.ptr, keyPtr.ptr),
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
