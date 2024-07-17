// ignore_for_file: unnecessary_lambdas

import 'dart:js_interop';

import 'package:meta/meta.dart';

import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart';
import '../bindings/to_safe_int.dart';
import 'aead_base_js.dart';
import 'secure_key_js.dart';

/// @nodoc
@internal
class AeadXChaCha20Poly1305IEFTJS extends AeadBaseJS {
  /// @nodoc
  AeadXChaCha20Poly1305IEFTJS(super.sodium);

  @override
  int get keyBytes =>
      sodium.crypto_aead_xchacha20poly1305_ietf_KEYBYTES.toSafeUInt32();

  @override
  int get nonceBytes =>
      sodium.crypto_aead_xchacha20poly1305_ietf_NPUBBYTES.toSafeUInt32();

  @override
  int get aBytes =>
      sodium.crypto_aead_xchacha20poly1305_ietf_ABYTES.toSafeUInt32();

  @override
  SecureKey keygen() => SecureKeyJS(
        sodium,
        jsErrorWrap(() => sodium.crypto_aead_xchacha20poly1305_ietf_keygen()),
      );

  @override
  JSUint8Array internalEncrypt(
    JSUint8Array message,
    JSUint8Array? additionalData,
    JSUint8Array? secretNonce,
    JSUint8Array publicNonce,
    JSUint8Array key,
  ) =>
      sodium.crypto_aead_xchacha20poly1305_ietf_encrypt(
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
      sodium.crypto_aead_xchacha20poly1305_ietf_decrypt(
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
      sodium.crypto_aead_xchacha20poly1305_ietf_encrypt_detached(
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
      sodium.crypto_aead_xchacha20poly1305_ietf_decrypt_detached(
        secretNonce,
        ciphertext,
        mac,
        additionalData,
        publicNonce,
        key,
      );
}
