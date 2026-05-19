import 'dart:ffi';

import 'package:meta/meta.dart';

import 'ipcrypt_nd_base_ffi.dart';

/// @nodoc
@internal
class IpcryptNdxFFI extends IpcryptNdBaseFFI {
  /// @nodoc
  IpcryptNdxFFI(super.sodium);

  @override
  int get keyBytes => sodium.crypto_ipcrypt_ndx_keybytes();

  @override
  int get tweakBytes => sodium.crypto_ipcrypt_ndx_tweakbytes();

  @override
  int get inputBytes => sodium.crypto_ipcrypt_ndx_inputbytes();

  @override
  int get outputBytes => sodium.crypto_ipcrypt_ndx_outputbytes();

  @override
  void Function(Pointer<UnsignedChar> k) get internalKeygen =>
      sodium.crypto_ipcrypt_ndx_keygen;

  @override
  void Function(
    Pointer<UnsignedChar> out,
    Pointer<UnsignedChar> in$,
    Pointer<UnsignedChar> t,
    Pointer<UnsignedChar> k,
  )
  get internalEncrypt => sodium.crypto_ipcrypt_ndx_encrypt;

  @override
  void Function(
    Pointer<UnsignedChar> out,
    Pointer<UnsignedChar> in$,
    Pointer<UnsignedChar> k,
  )
  get internalDecrypt => sodium.crypto_ipcrypt_ndx_decrypt;
}
