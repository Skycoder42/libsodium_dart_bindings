import 'package:meta/meta.dart';

import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/to_safe_int.dart';
import 'aead_base_js.dart';
import 'secure_key_js.dart';

/// @nodoc
@internal
class AeadChaCha20Poly1305JS extends AeadBaseJS {
  /// @nodoc
  AeadChaCha20Poly1305JS(super.sodium);

  @override
  int get keyBytes =>
      sodium.crypto_aead_chacha20poly1305_KEYBYTES.toSafeUInt32();

  @override
  int get nonceBytes =>
      sodium.crypto_aead_chacha20poly1305_NPUBBYTES.toSafeUInt32();

  @override
  int get aBytes => sodium.crypto_aead_chacha20poly1305_ABYTES.toSafeUInt32();

  @override
  SecureKey keygen() => SecureKeyJS(
        sodium,
        jsErrorWrap(
          sodium.crypto_aead_chacha20poly1305_keygen,
        ),
      );

  @override
  InternalEncrypt get internalEncrypt =>
      sodium.crypto_aead_chacha20poly1305_encrypt;

  @override
  InternalDecrypt get internalDecrypt =>
      sodium.crypto_aead_chacha20poly1305_decrypt;

  @override
  InternalEncryptDetached get internalEncryptDetached =>
      sodium.crypto_aead_chacha20poly1305_encrypt_detached;

  @override
  InternalDecryptDetached get internalDecryptDetached =>
      sodium.crypto_aead_chacha20poly1305_decrypt_detached;
}
