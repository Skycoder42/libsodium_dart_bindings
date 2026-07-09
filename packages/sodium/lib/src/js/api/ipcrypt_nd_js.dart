import 'dart:js_interop';

import 'package:meta/meta.dart';

import 'ipcrypt_nd_base_js.dart';

/// @nodoc
@internal
class IpcryptNdJS extends IpcryptNdBaseJS {
  /// @nodoc
  IpcryptNdJS(super.sodium);

  @override
  int get keyBytes => sodium.crypto_ipcrypt_ND_KEYBYTES;

  @override
  int get tweakBytes => sodium.crypto_ipcrypt_ND_TWEAKBYTES;

  @override
  int get inputBytes => sodium.crypto_ipcrypt_ND_INPUTBYTES;

  @override
  int get outputBytes => sodium.crypto_ipcrypt_ND_OUTPUTBYTES;

  @override
  JSUint8Array internalKeygen() => sodium.crypto_ipcrypt_nd_keygen();

  @override
  JSUint8Array internalEncrypt(
    JSUint8Array input,
    JSUint8Array tweak,
    JSUint8Array key,
  ) => sodium.crypto_ipcrypt_nd_encrypt(input, tweak, key);

  @override
  JSUint8Array internalDecrypt(JSUint8Array input, JSUint8Array key) =>
      sodium.crypto_ipcrypt_nd_decrypt(input, key);
}
