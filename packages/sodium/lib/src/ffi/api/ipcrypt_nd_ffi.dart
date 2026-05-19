import 'dart:ffi';

import 'package:meta/meta.dart';

import 'ipcrypt_nd_base_ffi.dart';

/// @nodoc
@internal
class IpcryptNdFFI extends IpcryptNdBaseFFI {
  /// @nodoc
  IpcryptNdFFI(super.sodium);

  @override
  int get keyBytes => sodium.crypto_ipcrypt_nd_keybytes();

  @override
  int get tweakBytes => sodium.crypto_ipcrypt_nd_tweakbytes();

  @override
  int get inputBytes => sodium.crypto_ipcrypt_nd_inputbytes();

  @override
  int get outputBytes => sodium.crypto_ipcrypt_nd_outputbytes();

  @override
  void Function(Pointer<UnsignedChar> k) get internalKeygen =>
      sodium.crypto_ipcrypt_nd_keygen;

  @override
  void Function(
    Pointer<UnsignedChar> out,
    Pointer<UnsignedChar> in$,
    Pointer<UnsignedChar> t,
    Pointer<UnsignedChar> k,
  )
  get internalEncrypt => sodium.crypto_ipcrypt_nd_encrypt;

  @override
  void Function(
    Pointer<UnsignedChar> out,
    Pointer<UnsignedChar> in$,
    Pointer<UnsignedChar> k,
  )
  get internalDecrypt => sodium.crypto_ipcrypt_nd_decrypt;
}
