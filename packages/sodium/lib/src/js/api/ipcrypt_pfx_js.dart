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
import 'secure_key_js.dart';

/// @nodoc
@internal
class IpcryptPfxJS with IpcryptPfxValidations implements IpcryptPfx {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  IpcryptPfxJS(this.sodium);

  @override
  int get keyBytes => sodium.crypto_ipcrypt_PFX_KEYBYTES;

  @override
  int get pfxBytes => sodium.crypto_ipcrypt_PFX_BYTES;

  @override
  SecureKey keygen() => SecureKeyJS(
    sodium,
    jsErrorWrap(() => sodium.crypto_ipcrypt_pfx_keygen()),
  );

  @override
  Uint8List encrypt({
    required covariant IpAddressJS input,
    required SecureKey key,
  }) {
    validateInput(input.bytes);
    validateKey(key);

    return jsErrorWrap(
      () => key.runUnlockedSync(
        (keyData) => sodium
            .crypto_ipcrypt_pfx_encrypt(input.rawBytes, keyData.toJS)
            .toDart,
      ),
    );
  }

  @override
  IpAddress decrypt({required Uint8List input, required SecureKey key}) {
    validateInput(input);
    validateKey(key);

    final result = jsErrorWrap(
      () => key.runUnlockedSync(
        (keyData) =>
            sodium.crypto_ipcrypt_pfx_decrypt(input.toJS, keyData.toJS),
      ),
    );

    return IpAddressJS.fromJsBytes(sodium, result);
  }
}
