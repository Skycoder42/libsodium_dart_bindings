// ignore_for_file: unnecessary_lambdas to catch member access errors

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/ip_address.dart';
import '../../api/ipcrypt.dart';
import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart';
import 'ip_address_js.dart';
import 'ipcrypt_nd_js.dart';
import 'ipcrypt_ndx_js.dart';
import 'ipcrypt_pfx_js.dart';
import 'secure_key_js.dart';

/// @nodoc
@internal
class IpcryptJS with IpcryptValidations implements Ipcrypt {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  IpcryptJS(this.sodium);

  @override
  int get bytes => sodium.crypto_ipcrypt_BYTES;

  @override
  int get keyBytes => sodium.crypto_ipcrypt_KEYBYTES;

  @override
  late final IpcryptNd nd = IpcryptNdJS(sodium);

  @override
  late final IpcryptNd ndx = IpcryptNdxJS(sodium);

  @override
  late final IpcryptPfx pfx = IpcryptPfxJS(sodium);

  @override
  SecureKey keygen() =>
      SecureKeyJS(sodium, jsErrorWrap(() => sodium.crypto_ipcrypt_keygen()));

  @override
  Uint8List encrypt({
    required covariant IpAddressJS input,
    required SecureKey key,
  }) {
    validateInput(input.bytes);
    validateKey(key);

    return jsErrorWrap(
      () => key.runUnlockedSync(
        (keyData) =>
            sodium.crypto_ipcrypt_encrypt(input.rawBytes, keyData.toJS).toDart,
      ),
    );
  }

  @override
  IpAddress decrypt({required Uint8List cipherText, required SecureKey key}) {
    validateInput(cipherText);
    validateKey(key);

    final result = jsErrorWrap(
      () => key.runUnlockedSync(
        (keyData) =>
            sodium.crypto_ipcrypt_decrypt(cipherText.toJS, keyData.toJS),
      ),
    );

    return IpAddressJS.fromJsBytes(sodium, result);
  }
}
