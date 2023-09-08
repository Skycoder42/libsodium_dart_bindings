import 'package:meta/meta.dart';

import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
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
        jsErrorWrap(
          sodium.crypto_aead_xchacha20poly1305_ietf_keygen,
        ),
      );

  @override
  InternalEncrypt get internalEncrypt =>
      sodium.crypto_aead_xchacha20poly1305_ietf_encrypt;

  @override
  InternalDecrypt get internalDecrypt =>
      sodium.crypto_aead_xchacha20poly1305_ietf_decrypt;

  @override
  InternalEncryptDetached get internalEncryptDetached =>
      sodium.crypto_aead_xchacha20poly1305_ietf_encrypt_detached;

  @override
  InternalDecryptDetached get internalDecryptDetached =>
      sodium.crypto_aead_xchacha20poly1305_ietf_decrypt_detached;
}
