import 'package:meta/meta.dart';

import '../../api/secure_key.dart';
import 'aead_base_ffi.dart';

/// @nodoc
@internal
class AeadChacha20Poly1305FFI extends AeadBaseFFI {
  /// @nodoc
  AeadChacha20Poly1305FFI(super.sodium);

  @override
  int get keyBytes => sodium.crypto_aead_chacha20poly1305_keybytes();

  @override
  int get nonceBytes => sodium.crypto_aead_chacha20poly1305_npubbytes();

  @override
  int get aBytes => sodium.crypto_aead_chacha20poly1305_abytes();

  @override
  SecureKey keygen() => keygenImpl(
    sodium: sodium,
    keyBytes: keyBytes,
    implementation: sodium.crypto_aead_chacha20poly1305_keygen,
  );

  @override
  InternalEncrypt get internalEncrypt =>
      sodium.crypto_aead_chacha20poly1305_encrypt;

  @override
  InternalDecrypt get internalDecrypt =>
      sodium.crypto_aead_chacha20poly1305_decrypt;

  @override
  InternalDecryptDetached get internalDecryptDetached =>
      sodium.crypto_aead_chacha20poly1305_decrypt_detached;

  @override
  InternalEncryptDetached get internalEncryptDetached =>
      sodium.crypto_aead_chacha20poly1305_encrypt_detached;
}
