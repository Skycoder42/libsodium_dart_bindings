import 'dart:js_interop';

import 'package:meta/meta.dart';

import 'ipcrypt_nd_base_js.dart';

/// @nodoc
@internal
class IpcryptNdxJS extends IpcryptNdBaseJS {
  /// @nodoc
  IpcryptNdxJS(super.sodium);

  @override
  int get keyBytes => sodium.crypto_ipcrypt_NDX_KEYBYTES;

  @override
  int get tweakBytes => sodium.crypto_ipcrypt_NDX_TWEAKBYTES;

  @override
  int get inputBytes => sodium.crypto_ipcrypt_NDX_INPUTBYTES;

  @override
  int get outputBytes => sodium.crypto_ipcrypt_NDX_OUTPUTBYTES;

  @override
  JSUint8Array internalKeygen() => sodium.crypto_ipcrypt_ndx_keygen();

  @override
  JSUint8Array internalEncrypt(
    JSUint8Array input,
    JSUint8Array tweak,
    JSUint8Array key,
  ) => sodium.crypto_ipcrypt_ndx_encrypt(input, tweak, key);

  @override
  JSUint8Array internalDecrypt(JSUint8Array input, JSUint8Array key) =>
      sodium.crypto_ipcrypt_ndx_decrypt(input, key);
}
