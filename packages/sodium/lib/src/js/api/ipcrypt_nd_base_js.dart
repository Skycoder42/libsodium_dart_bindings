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

@internal
// ignore: public_member_api_docs false positive
abstract class IpcryptNdBaseJS(final LibSodiumJS sodium)
    with IpcryptNdValidations
    implements IpcryptNd {
  @protected
  JSUint8Array internalKeygen();

  @protected
  JSUint8Array internalEncrypt(
    JSUint8Array input,
    JSUint8Array tweak,
    JSUint8Array key,
  );

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
  IpAddress decrypt({required Uint8List cipherText, required SecureKey key}) {
    validateCipherText(cipherText);
    validateKey(key);

    final result = jsErrorWrap(
      () => key.runUnlockedSync(
        (keyData) => internalDecrypt(cipherText.toJS, keyData.toJS),
      ),
    );

    return IpAddressJS.fromJsBytes(sodium, result);
  }
}
