// ignore_for_file: unnecessary_lambdas

import 'dart:js_interop';

import 'package:meta/meta.dart';

import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart';
import 'aead_base_js.dart';
import 'secure_key_js.dart';

/// @nodoc
@internal
class AeadChaCha20Poly1305JS extends AeadBaseJS {
  /// @nodoc
  AeadChaCha20Poly1305JS(super.sodium);

  @override
  int get keyBytes => sodium.crypto_aead_chacha20poly1305_KEYBYTES;

  @override
  int get nonceBytes => sodium.crypto_aead_chacha20poly1305_NPUBBYTES;

  @override
  int get aBytes => sodium.crypto_aead_chacha20poly1305_ABYTES;

  @override
  SecureKey keygen() => SecureKeyJS(
        sodium,
        jsErrorWrap(() => sodium.crypto_aead_chacha20poly1305_keygen()),
      );

  @override
  JSUint8Array internalEncrypt(
    JSUint8Array message,
    JSUint8Array? additionalData,
    JSUint8Array? secretNonce,
    JSUint8Array publicNonce,
    JSUint8Array key,
  ) =>
      sodium.crypto_aead_chacha20poly1305_encrypt(
        message,
        additionalData,
        secretNonce,
        publicNonce,
        key,
      );

  @override
  JSUint8Array internalDecrypt(
    JSUint8Array? secretNonce,
    JSUint8Array ciphertext,
    JSUint8Array? additionalData,
    JSUint8Array publicNonce,
    JSUint8Array key,
  ) =>
      sodium.crypto_aead_chacha20poly1305_decrypt(
        secretNonce,
        ciphertext,
        additionalData,
        publicNonce,
        key,
      );

  @override
  CryptoBox internalEncryptDetached(
    JSUint8Array message,
    JSUint8Array? additionalData,
    JSUint8Array? secretNonce,
    JSUint8Array publicNonce,
    JSUint8Array key,
  ) =>
      sodium.crypto_aead_chacha20poly1305_encrypt_detached(
        message,
        additionalData,
        secretNonce,
        publicNonce,
        key,
      );

  @override
  JSUint8Array internalDecryptDetached(
    JSUint8Array? secretNonce,
    JSUint8Array ciphertext,
    JSUint8Array mac,
    JSUint8Array? additionalData,
    JSUint8Array publicNonce,
    JSUint8Array key,
  ) =>
      sodium.crypto_aead_chacha20poly1305_decrypt_detached(
        secretNonce,
        ciphertext,
        mac,
        additionalData,
        publicNonce,
        key,
      );
}
