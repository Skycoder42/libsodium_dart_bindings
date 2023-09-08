import 'package:meta/meta.dart';

import '../../api/secure_key.dart';
import 'aead_base_ffi.dart';

/// @nodoc
@internal
class AeadXChaCha20Poly1305IETFFFI extends AeadBaseFFI {
  /// @nodoc
  AeadXChaCha20Poly1305IETFFFI(super.sodium);

  @override
  int get keyBytes => sodium.crypto_aead_xchacha20poly1305_ietf_keybytes();

  @override
  int get nonceBytes => sodium.crypto_aead_xchacha20poly1305_ietf_npubbytes();

  @override
  int get aBytes => sodium.crypto_aead_xchacha20poly1305_ietf_abytes();

  @override
  SecureKey keygen() => keygenImpl(
        sodium: sodium,
        keyBytes: keyBytes,
        implementation: sodium.crypto_aead_xchacha20poly1305_ietf_keygen,
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
