import 'package:meta/meta.dart';

import '../../api/secure_key.dart';
import 'aead_base_ffi.dart';

@internal
// ignore: public_member_api_docs false positive
class AeadAegis256FFI(super.sodium) extends AeadBaseFFI {
  @override
  int get keyBytes => sodium.crypto_aead_aegis256_keybytes();

  @override
  int get nonceBytes => sodium.crypto_aead_aegis256_npubbytes();

  @override
  int get aBytes => sodium.crypto_aead_aegis256_abytes();

  @override
  SecureKey keygen() => keygenImpl(
    sodium: sodium,
    keyBytes: keyBytes,
    implementation: sodium.crypto_aead_aegis256_keygen,
  );

  @override
  InternalEncrypt get internalEncrypt => sodium.crypto_aead_aegis256_encrypt;

  @override
  InternalDecrypt get internalDecrypt => sodium.crypto_aead_aegis256_decrypt;

  @override
  InternalDecryptDetached get internalDecryptDetached =>
      sodium.crypto_aead_aegis256_decrypt_detached;

  @override
  InternalEncryptDetached get internalEncryptDetached =>
      sodium.crypto_aead_aegis256_encrypt_detached;
}
