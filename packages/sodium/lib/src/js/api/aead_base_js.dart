import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/aead.dart';
import '../../api/detached_cipher_result.dart';
import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart';

/// @nodoc
@internal
abstract class AeadBaseJS with AeadValidations implements Aead {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  AeadBaseJS(this.sodium);

  @override
  Uint8List encrypt({
    required Uint8List message,
    required Uint8List nonce,
    required SecureKey key,
    Uint8List? additionalData,
  }) {
    validateNonce(nonce);
    validateKey(key);

    return jsErrorWrap(
      () => key.runUnlockedSync(
        (keyData) => internalEncrypt(
          message.toJS,
          additionalData?.toJS,
          null,
          nonce.toJS,
          keyData.toJS,
        ).toDart,
      ),
    );
  }

  @override
  Uint8List decrypt({
    required Uint8List cipherText,
    required Uint8List nonce,
    required SecureKey key,
    Uint8List? additionalData,
  }) {
    validateEasyCipherText(cipherText);
    validateNonce(nonce);
    validateKey(key);

    return jsErrorWrap(
      () => key.runUnlockedSync(
        (keyData) => internalDecrypt(
          null,
          cipherText.toJS,
          additionalData?.toJS,
          nonce.toJS,
          keyData.toJS,
        ).toDart,
      ),
    );
  }

  @override
  DetachedCipherResult encryptDetached({
    required Uint8List message,
    required Uint8List nonce,
    required SecureKey key,
    Uint8List? additionalData,
  }) {
    validateNonce(nonce);
    validateKey(key);

    final cipher = jsErrorWrap(
      () => key.runUnlockedSync(
        (keyData) => internalEncryptDetached(
          message.toJS,
          additionalData?.toJS,
          null,
          nonce.toJS,
          keyData.toJS,
        ),
      ),
    );

    return DetachedCipherResult(
      cipherText: cipher.ciphertext.toDart,
      mac: cipher.mac.toDart,
    );
  }

  @override
  Uint8List decryptDetached({
    required Uint8List cipherText,
    required Uint8List mac,
    required Uint8List nonce,
    required SecureKey key,
    Uint8List? additionalData,
  }) {
    validateMac(mac);
    validateNonce(nonce);
    validateKey(key);

    return jsErrorWrap(
      () => key.runUnlockedSync(
        (keyData) => internalDecryptDetached(
          null,
          cipherText.toJS,
          mac.toJS,
          additionalData?.toJS,
          nonce.toJS,
          keyData.toJS,
        ).toDart,
      ),
    );
  }

  /// @nodoc
  @protected
  JSUint8Array internalEncrypt(
    JSUint8Array message,
    JSUint8Array? additionalData,
    JSUint8Array? secretNonce,
    JSUint8Array publicNonce,
    JSUint8Array key,
  );

  /// @nodoc
  @protected
  JSUint8Array internalDecrypt(
    JSUint8Array? secretNonce,
    JSUint8Array ciphertext,
    JSUint8Array? additionalData,
    JSUint8Array publicNonce,
    JSUint8Array key,
  );

  /// @nodoc
  @protected
  CryptoBox internalEncryptDetached(
    JSUint8Array message,
    JSUint8Array? additionalData,
    JSUint8Array? secretNonce,
    JSUint8Array publicNonce,
    JSUint8Array key,
  );

  /// @nodoc
  @protected
  JSUint8Array internalDecryptDetached(
    JSUint8Array? secretNonce,
    JSUint8Array ciphertext,
    JSUint8Array mac,
    JSUint8Array? additionalData,
    JSUint8Array publicNonce,
    JSUint8Array key,
  );
}
