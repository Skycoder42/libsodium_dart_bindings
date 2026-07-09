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
abstract class IpcryptNdBaseJS with IpcryptNdValidations implements IpcryptNd {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  IpcryptNdBaseJS(this.sodium);

  /// @nodoc
  @protected
  JSUint8Array internalKeygen();

  /// @nodoc
  @protected
  JSUint8Array internalEncrypt(
    JSUint8Array input,
    JSUint8Array tweak,
    JSUint8Array key,
  );

  /// @nodoc
  @protected
  JSUint8Array internalDecrypt(JSUint8Array input, JSUint8Array key);

  @override
  SecureKey keygen() => SecureKeyJS(sodium, jsErrorWrap(internalKeygen));

  @override
  Uint8List encrypt({
    required covariant IpAddressJS input,
    required Uint8List tweak,
    required SecureKey key,
  }) {
    validateInput(input.bytes);
    validateTweak(tweak);
    validateKey(key);

    return jsErrorWrap(
      () => key.runUnlockedSync(
        (keyData) =>
            internalEncrypt(input.rawBytes, tweak.toJS, keyData.toJS).toDart,
      ),
    );
  }

  @override
  IpAddress decrypt({required Uint8List ciphertext, required SecureKey key}) {
    validateCiphertext(ciphertext);
    validateKey(key);

    final result = jsErrorWrap(
      () => key.runUnlockedSync(
        (keyData) => internalDecrypt(ciphertext.toJS, keyData.toJS),
      ),
    );

    return IpAddressJS.fromJsBytes(sodium, result);
  }
}
