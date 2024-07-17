// ignore_for_file: non_constant_identifier_names, public_member_api_docs

import 'dart:js_interop';

typedef SecretstreamXchacha20poly1305State = JSNumber;

typedef SignState = JSNumber;

typedef GenerichashState = JSNumber;

typedef HashSha256State = JSNumber;

typedef HashSha512State = JSNumber;

typedef OnetimeauthState = JSNumber;

typedef AuthHmacsha256State = JSNumber;

typedef AuthHmacsha512State = JSNumber;

typedef AuthHmacsha512256State = JSNumber;

extension type CryptoBox._(JSObject _) implements JSObject {
  external JSUint8Array get ciphertext;
  external JSUint8Array get mac;

  external CryptoBox({
    required JSUint8Array ciphertext,
    required JSUint8Array mac,
  });
}

extension type CryptoKX._(JSObject _) implements JSObject {
  external JSUint8Array get sharedRx;
  external JSUint8Array get sharedTx;

  external CryptoKX({
    required JSUint8Array sharedRx,
    required JSUint8Array sharedTx,
  });
}

extension type KeyPair._(JSObject _) implements JSObject {
  external String get keyType;
  external JSUint8Array get privateKey;
  external JSUint8Array get publicKey;

  external KeyPair({
    required String keyType,
    required JSUint8Array privateKey,
    required JSUint8Array publicKey,
  });
}

extension type SecretBox._(JSObject _) implements JSObject {
  external JSUint8Array get cipher;
  external JSUint8Array get mac;

  external SecretBox({
    required JSUint8Array cipher,
    required JSUint8Array mac,
  });
}

extension type SecretStreamInitPush._(JSObject _) implements JSObject {
  external JSNumber get state;
  external JSUint8Array get header;

  external SecretStreamInitPush({
    required JSNumber state,
    required JSUint8Array header,
  });
}

extension type SecretStreamPull._(JSObject _) implements JSObject {
  external JSUint8Array get message;
  external JSNumber get tag;

  external SecretStreamPull({
    required JSUint8Array message,
    required JSNumber tag,
  });
}

extension type LibSodiumJS._(JSObject _) implements JSObject {
  external num SODIUM_LIBRARY_VERSION_MAJOR;

  external num SODIUM_LIBRARY_VERSION_MINOR;

  external String SODIUM_VERSION_STRING;

  external num crypto_aead_aegis128l_ABYTES;

  external num crypto_aead_aegis128l_KEYBYTES;

  external num crypto_aead_aegis128l_MESSAGEBYTES_MAX;

  external num crypto_aead_aegis128l_NPUBBYTES;

  external num crypto_aead_aegis128l_NSECBYTES;

  external num crypto_aead_aegis256_ABYTES;

  external num crypto_aead_aegis256_KEYBYTES;

  external num crypto_aead_aegis256_MESSAGEBYTES_MAX;

  external num crypto_aead_aegis256_NPUBBYTES;

  external num crypto_aead_aegis256_NSECBYTES;

  external num crypto_aead_aes256gcm_ABYTES;

  external num crypto_aead_aes256gcm_KEYBYTES;

  external num crypto_aead_aes256gcm_MESSAGEBYTES_MAX;

  external num crypto_aead_aes256gcm_NPUBBYTES;

  external num crypto_aead_aes256gcm_NSECBYTES;

  external num crypto_aead_chacha20poly1305_ABYTES;

  external num crypto_aead_chacha20poly1305_IETF_ABYTES;

  external num crypto_aead_chacha20poly1305_IETF_KEYBYTES;

  external num crypto_aead_chacha20poly1305_IETF_MESSAGEBYTES_MAX;

  external num crypto_aead_chacha20poly1305_IETF_NPUBBYTES;

  external num crypto_aead_chacha20poly1305_IETF_NSECBYTES;

  external num crypto_aead_chacha20poly1305_KEYBYTES;

  external num crypto_aead_chacha20poly1305_MESSAGEBYTES_MAX;

  external num crypto_aead_chacha20poly1305_NPUBBYTES;

  external num crypto_aead_chacha20poly1305_NSECBYTES;

  external num crypto_aead_chacha20poly1305_ietf_ABYTES;

  external num crypto_aead_chacha20poly1305_ietf_KEYBYTES;

  external num crypto_aead_chacha20poly1305_ietf_MESSAGEBYTES_MAX;

  external num crypto_aead_chacha20poly1305_ietf_NPUBBYTES;

  external num crypto_aead_chacha20poly1305_ietf_NSECBYTES;

  external num crypto_aead_xchacha20poly1305_IETF_ABYTES;

  external num crypto_aead_xchacha20poly1305_IETF_KEYBYTES;

  external num crypto_aead_xchacha20poly1305_IETF_MESSAGEBYTES_MAX;

  external num crypto_aead_xchacha20poly1305_IETF_NPUBBYTES;

  external num crypto_aead_xchacha20poly1305_IETF_NSECBYTES;

  external num crypto_aead_xchacha20poly1305_ietf_ABYTES;

  external num crypto_aead_xchacha20poly1305_ietf_KEYBYTES;

  external num crypto_aead_xchacha20poly1305_ietf_MESSAGEBYTES_MAX;

  external num crypto_aead_xchacha20poly1305_ietf_NPUBBYTES;

  external num crypto_aead_xchacha20poly1305_ietf_NSECBYTES;

  external num crypto_auth_BYTES;

  external num crypto_auth_KEYBYTES;

  external num crypto_auth_hmacsha256_BYTES;

  external num crypto_auth_hmacsha256_KEYBYTES;

  external num crypto_auth_hmacsha512256_BYTES;

  external num crypto_auth_hmacsha512256_KEYBYTES;

  external num crypto_auth_hmacsha512_BYTES;

  external num crypto_auth_hmacsha512_KEYBYTES;

  external num crypto_box_BEFORENMBYTES;

  external num crypto_box_MACBYTES;

  external num crypto_box_MESSAGEBYTES_MAX;

  external num crypto_box_NONCEBYTES;

  external num crypto_box_PUBLICKEYBYTES;

  external num crypto_box_SEALBYTES;

  external num crypto_box_SECRETKEYBYTES;

  external num crypto_box_SEEDBYTES;

  external num crypto_box_curve25519xchacha20poly1305_BEFORENMBYTES;

  external num crypto_box_curve25519xchacha20poly1305_MACBYTES;

  external num crypto_box_curve25519xchacha20poly1305_MESSAGEBYTES_MAX;

  external num crypto_box_curve25519xchacha20poly1305_NONCEBYTES;

  external num crypto_box_curve25519xchacha20poly1305_PUBLICKEYBYTES;

  external num crypto_box_curve25519xchacha20poly1305_SEALBYTES;

  external num crypto_box_curve25519xchacha20poly1305_SECRETKEYBYTES;

  external num crypto_box_curve25519xchacha20poly1305_SEEDBYTES;

  external num crypto_box_curve25519xsalsa20poly1305_BEFORENMBYTES;

  external num crypto_box_curve25519xsalsa20poly1305_MACBYTES;

  external num crypto_box_curve25519xsalsa20poly1305_MESSAGEBYTES_MAX;

  external num crypto_box_curve25519xsalsa20poly1305_NONCEBYTES;

  external num crypto_box_curve25519xsalsa20poly1305_PUBLICKEYBYTES;

  external num crypto_box_curve25519xsalsa20poly1305_SECRETKEYBYTES;

  external num crypto_box_curve25519xsalsa20poly1305_SEEDBYTES;

  external num crypto_core_ed25519_BYTES;

  external num crypto_core_ed25519_HASHBYTES;

  external num crypto_core_ed25519_NONREDUCEDSCALARBYTES;

  external num crypto_core_ed25519_SCALARBYTES;

  external num crypto_core_ed25519_UNIFORMBYTES;

  external num crypto_core_hchacha20_CONSTBYTES;

  external num crypto_core_hchacha20_INPUTBYTES;

  external num crypto_core_hchacha20_KEYBYTES;

  external num crypto_core_hchacha20_OUTPUTBYTES;

  external num crypto_core_hsalsa20_CONSTBYTES;

  external num crypto_core_hsalsa20_INPUTBYTES;

  external num crypto_core_hsalsa20_KEYBYTES;

  external num crypto_core_hsalsa20_OUTPUTBYTES;

  external num crypto_core_ristretto255_BYTES;

  external num crypto_core_ristretto255_HASHBYTES;

  external num crypto_core_ristretto255_NONREDUCEDSCALARBYTES;

  external num crypto_core_ristretto255_SCALARBYTES;

  external num crypto_core_salsa2012_CONSTBYTES;

  external num crypto_core_salsa2012_INPUTBYTES;

  external num crypto_core_salsa2012_KEYBYTES;

  external num crypto_core_salsa2012_OUTPUTBYTES;

  external num crypto_core_salsa208_CONSTBYTES;

  external num crypto_core_salsa208_INPUTBYTES;

  external num crypto_core_salsa208_KEYBYTES;

  external num crypto_core_salsa208_OUTPUTBYTES;

  external num crypto_core_salsa20_CONSTBYTES;

  external num crypto_core_salsa20_INPUTBYTES;

  external num crypto_core_salsa20_KEYBYTES;

  external num crypto_core_salsa20_OUTPUTBYTES;

  external num crypto_generichash_BYTES;

  external num crypto_generichash_BYTES_MAX;

  external num crypto_generichash_BYTES_MIN;

  external num crypto_generichash_KEYBYTES;

  external num crypto_generichash_KEYBYTES_MAX;

  external num crypto_generichash_KEYBYTES_MIN;

  external num crypto_generichash_blake2b_BYTES;

  external num crypto_generichash_blake2b_BYTES_MAX;

  external num crypto_generichash_blake2b_BYTES_MIN;

  external num crypto_generichash_blake2b_KEYBYTES;

  external num crypto_generichash_blake2b_KEYBYTES_MAX;

  external num crypto_generichash_blake2b_KEYBYTES_MIN;

  external num crypto_generichash_blake2b_PERSONALBYTES;

  external num crypto_generichash_blake2b_SALTBYTES;

  external num crypto_hash_BYTES;

  external num crypto_hash_sha256_BYTES;

  external num crypto_hash_sha512_BYTES;

  external num crypto_kdf_BYTES_MAX;

  external num crypto_kdf_BYTES_MIN;

  external num crypto_kdf_CONTEXTBYTES;

  external num crypto_kdf_KEYBYTES;

  external num crypto_kdf_blake2b_BYTES_MAX;

  external num crypto_kdf_blake2b_BYTES_MIN;

  external num crypto_kdf_blake2b_CONTEXTBYTES;

  external num crypto_kdf_blake2b_KEYBYTES;

  external num crypto_kdf_hkdf_sha256_BYTES_MAX;

  external num crypto_kdf_hkdf_sha256_BYTES_MIN;

  external num crypto_kdf_hkdf_sha256_KEYBYTES;

  external num crypto_kdf_hkdf_sha512_BYTES_MAX;

  external num crypto_kdf_hkdf_sha512_BYTES_MIN;

  external num crypto_kdf_hkdf_sha512_KEYBYTES;

  external num crypto_kx_PUBLICKEYBYTES;

  external num crypto_kx_SECRETKEYBYTES;

  external num crypto_kx_SEEDBYTES;

  external num crypto_kx_SESSIONKEYBYTES;

  external num crypto_onetimeauth_BYTES;

  external num crypto_onetimeauth_KEYBYTES;

  external num crypto_onetimeauth_poly1305_BYTES;

  external num crypto_onetimeauth_poly1305_KEYBYTES;

  external num crypto_pwhash_ALG_ARGON2I13;

  external num crypto_pwhash_ALG_ARGON2ID13;

  external num crypto_pwhash_ALG_DEFAULT;

  external num crypto_pwhash_BYTES_MAX;

  external num crypto_pwhash_BYTES_MIN;

  external num crypto_pwhash_MEMLIMIT_INTERACTIVE;

  external num crypto_pwhash_MEMLIMIT_MAX;

  external num crypto_pwhash_MEMLIMIT_MIN;

  external num crypto_pwhash_MEMLIMIT_MODERATE;

  external num crypto_pwhash_MEMLIMIT_SENSITIVE;

  external num crypto_pwhash_OPSLIMIT_INTERACTIVE;

  external num crypto_pwhash_OPSLIMIT_MAX;

  external num crypto_pwhash_OPSLIMIT_MIN;

  external num crypto_pwhash_OPSLIMIT_MODERATE;

  external num crypto_pwhash_OPSLIMIT_SENSITIVE;

  external num crypto_pwhash_PASSWD_MAX;

  external num crypto_pwhash_PASSWD_MIN;

  external num crypto_pwhash_SALTBYTES;

  external num crypto_pwhash_STRBYTES;

  external String crypto_pwhash_STRPREFIX;

  external num crypto_pwhash_argon2i_BYTES_MAX;

  external num crypto_pwhash_argon2i_BYTES_MIN;

  external num crypto_pwhash_argon2i_MEMLIMIT_INTERACTIVE;

  external num crypto_pwhash_argon2i_MEMLIMIT_MAX;

  external num crypto_pwhash_argon2i_MEMLIMIT_MIN;

  external num crypto_pwhash_argon2i_MEMLIMIT_MODERATE;

  external num crypto_pwhash_argon2i_MEMLIMIT_SENSITIVE;

  external num crypto_pwhash_argon2i_OPSLIMIT_INTERACTIVE;

  external num crypto_pwhash_argon2i_OPSLIMIT_MAX;

  external num crypto_pwhash_argon2i_OPSLIMIT_MIN;

  external num crypto_pwhash_argon2i_OPSLIMIT_MODERATE;

  external num crypto_pwhash_argon2i_OPSLIMIT_SENSITIVE;

  external num crypto_pwhash_argon2i_PASSWD_MAX;

  external num crypto_pwhash_argon2i_PASSWD_MIN;

  external num crypto_pwhash_argon2i_SALTBYTES;

  external num crypto_pwhash_argon2i_STRBYTES;

  external String crypto_pwhash_argon2i_STRPREFIX;

  external num crypto_pwhash_argon2id_BYTES_MAX;

  external num crypto_pwhash_argon2id_BYTES_MIN;

  external num crypto_pwhash_argon2id_MEMLIMIT_INTERACTIVE;

  external num crypto_pwhash_argon2id_MEMLIMIT_MAX;

  external num crypto_pwhash_argon2id_MEMLIMIT_MIN;

  external num crypto_pwhash_argon2id_MEMLIMIT_MODERATE;

  external num crypto_pwhash_argon2id_MEMLIMIT_SENSITIVE;

  external num crypto_pwhash_argon2id_OPSLIMIT_INTERACTIVE;

  external num crypto_pwhash_argon2id_OPSLIMIT_MAX;

  external num crypto_pwhash_argon2id_OPSLIMIT_MIN;

  external num crypto_pwhash_argon2id_OPSLIMIT_MODERATE;

  external num crypto_pwhash_argon2id_OPSLIMIT_SENSITIVE;

  external num crypto_pwhash_argon2id_PASSWD_MAX;

  external num crypto_pwhash_argon2id_PASSWD_MIN;

  external num crypto_pwhash_argon2id_SALTBYTES;

  external num crypto_pwhash_argon2id_STRBYTES;

  external String crypto_pwhash_argon2id_STRPREFIX;

  external num crypto_pwhash_scryptsalsa208sha256_BYTES_MAX;

  external num crypto_pwhash_scryptsalsa208sha256_BYTES_MIN;

  external num crypto_pwhash_scryptsalsa208sha256_MEMLIMIT_INTERACTIVE;

  external num crypto_pwhash_scryptsalsa208sha256_MEMLIMIT_MAX;

  external num crypto_pwhash_scryptsalsa208sha256_MEMLIMIT_MIN;

  external num crypto_pwhash_scryptsalsa208sha256_MEMLIMIT_SENSITIVE;

  external num crypto_pwhash_scryptsalsa208sha256_OPSLIMIT_INTERACTIVE;

  external num crypto_pwhash_scryptsalsa208sha256_OPSLIMIT_MAX;

  external num crypto_pwhash_scryptsalsa208sha256_OPSLIMIT_MIN;

  external num crypto_pwhash_scryptsalsa208sha256_OPSLIMIT_SENSITIVE;

  external num crypto_pwhash_scryptsalsa208sha256_PASSWD_MAX;

  external num crypto_pwhash_scryptsalsa208sha256_PASSWD_MIN;

  external num crypto_pwhash_scryptsalsa208sha256_SALTBYTES;

  external num crypto_pwhash_scryptsalsa208sha256_STRBYTES;

  external String crypto_pwhash_scryptsalsa208sha256_STRPREFIX;

  external num crypto_scalarmult_BYTES;

  external num crypto_scalarmult_SCALARBYTES;

  external num crypto_scalarmult_curve25519_BYTES;

  external num crypto_scalarmult_curve25519_SCALARBYTES;

  external num crypto_scalarmult_ed25519_BYTES;

  external num crypto_scalarmult_ed25519_SCALARBYTES;

  external num crypto_scalarmult_ristretto255_BYTES;

  external num crypto_scalarmult_ristretto255_SCALARBYTES;

  external num crypto_secretbox_KEYBYTES;

  external num crypto_secretbox_MACBYTES;

  external num crypto_secretbox_MESSAGEBYTES_MAX;

  external num crypto_secretbox_NONCEBYTES;

  external num crypto_secretbox_xchacha20poly1305_KEYBYTES;

  external num crypto_secretbox_xchacha20poly1305_MACBYTES;

  external num crypto_secretbox_xchacha20poly1305_MESSAGEBYTES_MAX;

  external num crypto_secretbox_xchacha20poly1305_NONCEBYTES;

  external num crypto_secretbox_xsalsa20poly1305_KEYBYTES;

  external num crypto_secretbox_xsalsa20poly1305_MACBYTES;

  external num crypto_secretbox_xsalsa20poly1305_MESSAGEBYTES_MAX;

  external num crypto_secretbox_xsalsa20poly1305_NONCEBYTES;

  external num crypto_secretstream_xchacha20poly1305_ABYTES;

  external num crypto_secretstream_xchacha20poly1305_HEADERBYTES;

  external num crypto_secretstream_xchacha20poly1305_KEYBYTES;

  external num crypto_secretstream_xchacha20poly1305_MESSAGEBYTES_MAX;

  external num crypto_secretstream_xchacha20poly1305_TAG_FINAL;

  external num crypto_secretstream_xchacha20poly1305_TAG_MESSAGE;

  external num crypto_secretstream_xchacha20poly1305_TAG_PUSH;

  external num crypto_secretstream_xchacha20poly1305_TAG_REKEY;

  external num crypto_shorthash_BYTES;

  external num crypto_shorthash_KEYBYTES;

  external num crypto_shorthash_siphash24_BYTES;

  external num crypto_shorthash_siphash24_KEYBYTES;

  external num crypto_shorthash_siphashx24_BYTES;

  external num crypto_shorthash_siphashx24_KEYBYTES;

  external num crypto_sign_BYTES;

  external num crypto_sign_MESSAGEBYTES_MAX;

  external num crypto_sign_PUBLICKEYBYTES;

  external num crypto_sign_SECRETKEYBYTES;

  external num crypto_sign_SEEDBYTES;

  external num crypto_sign_ed25519_BYTES;

  external num crypto_sign_ed25519_MESSAGEBYTES_MAX;

  external num crypto_sign_ed25519_PUBLICKEYBYTES;

  external num crypto_sign_ed25519_SECRETKEYBYTES;

  external num crypto_sign_ed25519_SEEDBYTES;

  external num crypto_stream_KEYBYTES;

  external num crypto_stream_MESSAGEBYTES_MAX;

  external num crypto_stream_NONCEBYTES;

  external num crypto_stream_chacha20_IETF_KEYBYTES;

  external num crypto_stream_chacha20_IETF_MESSAGEBYTES_MAX;

  external num crypto_stream_chacha20_IETF_NONCEBYTES;

  external num crypto_stream_chacha20_KEYBYTES;

  external num crypto_stream_chacha20_MESSAGEBYTES_MAX;

  external num crypto_stream_chacha20_NONCEBYTES;

  external num crypto_stream_chacha20_ietf_KEYBYTES;

  external num crypto_stream_chacha20_ietf_MESSAGEBYTES_MAX;

  external num crypto_stream_chacha20_ietf_NONCEBYTES;

  external num crypto_stream_salsa2012_KEYBYTES;

  external num crypto_stream_salsa2012_MESSAGEBYTES_MAX;

  external num crypto_stream_salsa2012_NONCEBYTES;

  external num crypto_stream_salsa208_KEYBYTES;

  external num crypto_stream_salsa208_MESSAGEBYTES_MAX;

  external num crypto_stream_salsa208_NONCEBYTES;

  external num crypto_stream_salsa20_KEYBYTES;

  external num crypto_stream_salsa20_MESSAGEBYTES_MAX;

  external num crypto_stream_salsa20_NONCEBYTES;

  external num crypto_stream_xchacha20_KEYBYTES;

  external num crypto_stream_xchacha20_MESSAGEBYTES_MAX;

  external num crypto_stream_xchacha20_NONCEBYTES;

  external num crypto_stream_xsalsa20_KEYBYTES;

  external num crypto_stream_xsalsa20_MESSAGEBYTES_MAX;

  external num crypto_stream_xsalsa20_NONCEBYTES;

  external num crypto_verify_16_BYTES;

  external num crypto_verify_32_BYTES;

  external num crypto_verify_64_BYTES;

  external JSUint8Array crypto_aead_aegis128l_decrypt(
    JSUint8Array? secret_nonce,
    JSUint8Array ciphertext,
    JSUint8Array? additional_data,
    JSUint8Array public_nonce,
    JSUint8Array key,
  );

  external JSUint8Array crypto_aead_aegis128l_decrypt_detached(
    JSUint8Array? secret_nonce,
    JSUint8Array ciphertext,
    JSUint8Array mac,
    JSUint8Array? additional_data,
    JSUint8Array public_nonce,
    JSUint8Array key,
  );

  external JSUint8Array crypto_aead_aegis128l_encrypt(
    JSUint8Array message,
    JSUint8Array? additional_data,
    JSUint8Array? secret_nonce,
    JSUint8Array public_nonce,
    JSUint8Array key,
  );

  external CryptoBox crypto_aead_aegis128l_encrypt_detached(
    JSUint8Array message,
    JSUint8Array? additional_data,
    JSUint8Array? secret_nonce,
    JSUint8Array public_nonce,
    JSUint8Array key,
  );

  external JSUint8Array crypto_aead_aegis128l_keygen();

  external JSUint8Array crypto_aead_aegis256_decrypt(
    JSUint8Array? secret_nonce,
    JSUint8Array ciphertext,
    JSUint8Array? additional_data,
    JSUint8Array public_nonce,
    JSUint8Array key,
  );

  external JSUint8Array crypto_aead_aegis256_decrypt_detached(
    JSUint8Array? secret_nonce,
    JSUint8Array ciphertext,
    JSUint8Array mac,
    JSUint8Array? additional_data,
    JSUint8Array public_nonce,
    JSUint8Array key,
  );

  external JSUint8Array crypto_aead_aegis256_encrypt(
    JSUint8Array message,
    JSUint8Array? additional_data,
    JSUint8Array? secret_nonce,
    JSUint8Array public_nonce,
    JSUint8Array key,
  );

  external CryptoBox crypto_aead_aegis256_encrypt_detached(
    JSUint8Array message,
    JSUint8Array? additional_data,
    JSUint8Array? secret_nonce,
    JSUint8Array public_nonce,
    JSUint8Array key,
  );

  external JSUint8Array crypto_aead_aegis256_keygen();

  external JSUint8Array crypto_aead_chacha20poly1305_decrypt(
    JSUint8Array? secret_nonce,
    JSUint8Array ciphertext,
    JSUint8Array? additional_data,
    JSUint8Array public_nonce,
    JSUint8Array key,
  );

  external JSUint8Array crypto_aead_chacha20poly1305_decrypt_detached(
    JSUint8Array? secret_nonce,
    JSUint8Array ciphertext,
    JSUint8Array mac,
    JSUint8Array? additional_data,
    JSUint8Array public_nonce,
    JSUint8Array key,
  );

  external JSUint8Array crypto_aead_chacha20poly1305_encrypt(
    JSUint8Array message,
    JSUint8Array? additional_data,
    JSUint8Array? secret_nonce,
    JSUint8Array public_nonce,
    JSUint8Array key,
  );

  external CryptoBox crypto_aead_chacha20poly1305_encrypt_detached(
    JSUint8Array message,
    JSUint8Array? additional_data,
    JSUint8Array? secret_nonce,
    JSUint8Array public_nonce,
    JSUint8Array key,
  );

  external JSUint8Array crypto_aead_chacha20poly1305_ietf_decrypt(
    JSUint8Array? secret_nonce,
    JSUint8Array ciphertext,
    JSUint8Array? additional_data,
    JSUint8Array public_nonce,
    JSUint8Array key,
  );

  external JSUint8Array crypto_aead_chacha20poly1305_ietf_decrypt_detached(
    JSUint8Array? secret_nonce,
    JSUint8Array ciphertext,
    JSUint8Array mac,
    JSUint8Array? additional_data,
    JSUint8Array public_nonce,
    JSUint8Array key,
  );

  external JSUint8Array crypto_aead_chacha20poly1305_ietf_encrypt(
    JSUint8Array message,
    JSUint8Array? additional_data,
    JSUint8Array? secret_nonce,
    JSUint8Array public_nonce,
    JSUint8Array key,
  );

  external CryptoBox crypto_aead_chacha20poly1305_ietf_encrypt_detached(
    JSUint8Array message,
    JSUint8Array? additional_data,
    JSUint8Array? secret_nonce,
    JSUint8Array public_nonce,
    JSUint8Array key,
  );

  external JSUint8Array crypto_aead_chacha20poly1305_ietf_keygen();

  external JSUint8Array crypto_aead_chacha20poly1305_keygen();

  external JSUint8Array crypto_aead_xchacha20poly1305_ietf_decrypt(
    JSUint8Array? secret_nonce,
    JSUint8Array ciphertext,
    JSUint8Array? additional_data,
    JSUint8Array public_nonce,
    JSUint8Array key,
  );

  external JSUint8Array crypto_aead_xchacha20poly1305_ietf_decrypt_detached(
    JSUint8Array? secret_nonce,
    JSUint8Array ciphertext,
    JSUint8Array mac,
    JSUint8Array? additional_data,
    JSUint8Array public_nonce,
    JSUint8Array key,
  );

  external JSUint8Array crypto_aead_xchacha20poly1305_ietf_encrypt(
    JSUint8Array message,
    JSUint8Array? additional_data,
    JSUint8Array? secret_nonce,
    JSUint8Array public_nonce,
    JSUint8Array key,
  );

  external CryptoBox crypto_aead_xchacha20poly1305_ietf_encrypt_detached(
    JSUint8Array message,
    JSUint8Array? additional_data,
    JSUint8Array? secret_nonce,
    JSUint8Array public_nonce,
    JSUint8Array key,
  );

  external JSUint8Array crypto_aead_xchacha20poly1305_ietf_keygen();

  external JSUint8Array crypto_auth(
    JSUint8Array message,
    JSUint8Array key,
  );

  external JSUint8Array crypto_auth_hmacsha256(
    JSUint8Array message,
    JSUint8Array key,
  );

  external JSUint8Array crypto_auth_hmacsha256_final(
    AuthHmacsha256State state_address,
  );

  external AuthHmacsha256State crypto_auth_hmacsha256_init(
    JSUint8Array? key,
  );

  external JSUint8Array crypto_auth_hmacsha256_keygen();

  external void crypto_auth_hmacsha256_update(
    AuthHmacsha256State state_address,
    JSUint8Array message_chunk,
  );

  external bool crypto_auth_hmacsha256_verify(
    JSUint8Array tag,
    JSUint8Array message,
    JSUint8Array key,
  );

  external JSUint8Array crypto_auth_hmacsha512(
    JSUint8Array message,
    JSUint8Array key,
  );

  external JSUint8Array crypto_auth_hmacsha512256(
    JSUint8Array message,
    JSUint8Array key,
  );

  external JSUint8Array crypto_auth_hmacsha512256_final(
    AuthHmacsha512256State state_address,
  );

  external AuthHmacsha512256State crypto_auth_hmacsha512256_init(
    JSUint8Array? key,
  );

  external JSUint8Array crypto_auth_hmacsha512256_keygen();

  external void crypto_auth_hmacsha512256_update(
    AuthHmacsha512256State state_address,
    JSUint8Array message_chunk,
  );

  external bool crypto_auth_hmacsha512256_verify(
    JSUint8Array tag,
    JSUint8Array message,
    JSUint8Array key,
  );

  external JSUint8Array crypto_auth_hmacsha512_final(
    AuthHmacsha512State state_address,
  );

  external AuthHmacsha512State crypto_auth_hmacsha512_init(
    JSUint8Array? key,
  );

  external JSUint8Array crypto_auth_hmacsha512_keygen();

  external void crypto_auth_hmacsha512_update(
    AuthHmacsha512State state_address,
    JSUint8Array message_chunk,
  );

  external bool crypto_auth_hmacsha512_verify(
    JSUint8Array tag,
    JSUint8Array message,
    JSUint8Array key,
  );

  external JSUint8Array crypto_auth_keygen();

  external bool crypto_auth_verify(
    JSUint8Array tag,
    JSUint8Array message,
    JSUint8Array key,
  );

  external JSUint8Array crypto_box_beforenm(
    JSUint8Array publicKey,
    JSUint8Array privateKey,
  );

  external JSUint8Array crypto_box_curve25519xchacha20poly1305_beforenm(
    JSUint8Array publicKey,
    JSUint8Array privateKey,
  );

  external CryptoBox crypto_box_curve25519xchacha20poly1305_detached(
    JSUint8Array message,
    JSUint8Array nonce,
    JSUint8Array publicKey,
    JSUint8Array privateKey,
  );

  external CryptoBox crypto_box_curve25519xchacha20poly1305_detached_afternm(
    JSUint8Array message,
    JSUint8Array nonce,
    JSUint8Array sharedKey,
  );

  external JSUint8Array crypto_box_curve25519xchacha20poly1305_easy(
    JSUint8Array message,
    JSUint8Array nonce,
    JSUint8Array publicKey,
    JSUint8Array privateKey,
  );

  external JSUint8Array crypto_box_curve25519xchacha20poly1305_easy_afternm(
    JSUint8Array message,
    JSUint8Array nonce,
    JSUint8Array sharedKey,
  );

  external KeyPair crypto_box_curve25519xchacha20poly1305_keypair();

  external JSUint8Array crypto_box_curve25519xchacha20poly1305_open_detached(
    JSUint8Array ciphertext,
    JSUint8Array mac,
    JSUint8Array nonce,
    JSUint8Array publicKey,
    JSUint8Array privateKey,
  );

  external JSUint8Array
      crypto_box_curve25519xchacha20poly1305_open_detached_afternm(
    JSUint8Array ciphertext,
    JSUint8Array mac,
    JSUint8Array nonce,
    JSUint8Array sharedKey,
  );

  external JSUint8Array crypto_box_curve25519xchacha20poly1305_open_easy(
    JSUint8Array ciphertext,
    JSUint8Array nonce,
    JSUint8Array publicKey,
    JSUint8Array privateKey,
  );

  external JSUint8Array
      crypto_box_curve25519xchacha20poly1305_open_easy_afternm(
    JSUint8Array ciphertext,
    JSUint8Array nonce,
    JSUint8Array sharedKey,
  );

  external JSUint8Array crypto_box_curve25519xchacha20poly1305_seal(
    JSUint8Array message,
    JSUint8Array publicKey,
  );

  external JSUint8Array crypto_box_curve25519xchacha20poly1305_seal_open(
    JSUint8Array ciphertext,
    JSUint8Array publicKey,
    JSUint8Array secretKey,
  );

  external KeyPair crypto_box_curve25519xchacha20poly1305_seed_keypair(
    JSUint8Array seed,
  );

  external CryptoBox crypto_box_detached(
    JSUint8Array message,
    JSUint8Array nonce,
    JSUint8Array publicKey,
    JSUint8Array privateKey,
  );

  external JSUint8Array crypto_box_easy(
    JSUint8Array message,
    JSUint8Array nonce,
    JSUint8Array publicKey,
    JSUint8Array privateKey,
  );

  external JSUint8Array crypto_box_easy_afternm(
    JSUint8Array message,
    JSUint8Array nonce,
    JSUint8Array sharedKey,
  );

  external KeyPair crypto_box_keypair();

  external JSUint8Array crypto_box_open_detached(
    JSUint8Array ciphertext,
    JSUint8Array mac,
    JSUint8Array nonce,
    JSUint8Array publicKey,
    JSUint8Array privateKey,
  );

  external JSUint8Array crypto_box_open_easy(
    JSUint8Array ciphertext,
    JSUint8Array nonce,
    JSUint8Array publicKey,
    JSUint8Array privateKey,
  );

  external JSUint8Array crypto_box_open_easy_afternm(
    JSUint8Array ciphertext,
    JSUint8Array nonce,
    JSUint8Array sharedKey,
  );

  external JSUint8Array crypto_box_seal(
    JSUint8Array message,
    JSUint8Array publicKey,
  );

  external JSUint8Array crypto_box_seal_open(
    JSUint8Array ciphertext,
    JSUint8Array publicKey,
    JSUint8Array privateKey,
  );

  external KeyPair crypto_box_seed_keypair(
    JSUint8Array seed,
  );

  external JSUint8Array crypto_core_ed25519_add(
    JSUint8Array p,
    JSUint8Array q,
  );

  external JSUint8Array crypto_core_ed25519_from_hash(
    JSUint8Array r,
  );

  external JSUint8Array crypto_core_ed25519_from_uniform(
    JSUint8Array r,
  );

  external bool crypto_core_ed25519_is_valid_point(
    JSUint8Array repr,
  );

  external JSUint8Array crypto_core_ed25519_random();

  external JSUint8Array crypto_core_ed25519_scalar_add(
    JSUint8Array x,
    JSUint8Array y,
  );

  external JSUint8Array crypto_core_ed25519_scalar_complement(
    JSUint8Array s,
  );

  external JSUint8Array crypto_core_ed25519_scalar_invert(
    JSUint8Array s,
  );

  external JSUint8Array crypto_core_ed25519_scalar_mul(
    JSUint8Array x,
    JSUint8Array y,
  );

  external JSUint8Array crypto_core_ed25519_scalar_negate(
    JSUint8Array s,
  );

  external JSUint8Array crypto_core_ed25519_scalar_random();

  external JSUint8Array crypto_core_ed25519_scalar_reduce(
    JSUint8Array sample,
  );

  external JSUint8Array crypto_core_ed25519_scalar_sub(
    JSUint8Array x,
    JSUint8Array y,
  );

  external JSUint8Array crypto_core_ed25519_sub(
    JSUint8Array p,
    JSUint8Array q,
  );

  external JSUint8Array crypto_core_hchacha20(
    JSUint8Array input,
    JSUint8Array privateKey,
    JSUint8Array? constant,
  );

  external JSUint8Array crypto_core_hsalsa20(
    JSUint8Array input,
    JSUint8Array privateKey,
    JSUint8Array? constant,
  );

  external JSUint8Array crypto_core_ristretto255_add(
    JSUint8Array p,
    JSUint8Array q,
  );

  external JSUint8Array crypto_core_ristretto255_from_hash(
    JSUint8Array r,
  );

  external bool crypto_core_ristretto255_is_valid_point(
    JSUint8Array repr,
  );

  external JSUint8Array crypto_core_ristretto255_random();

  external JSUint8Array crypto_core_ristretto255_scalar_add(
    JSUint8Array x,
    JSUint8Array y,
  );

  external JSUint8Array crypto_core_ristretto255_scalar_complement(
    JSUint8Array s,
  );

  external JSUint8Array crypto_core_ristretto255_scalar_invert(
    JSUint8Array s,
  );

  external JSUint8Array crypto_core_ristretto255_scalar_mul(
    JSUint8Array x,
    JSUint8Array y,
  );

  external JSUint8Array crypto_core_ristretto255_scalar_negate(
    JSUint8Array s,
  );

  external JSUint8Array crypto_core_ristretto255_scalar_random();

  external JSUint8Array crypto_core_ristretto255_scalar_reduce(
    JSUint8Array sample,
  );

  external JSUint8Array crypto_core_ristretto255_scalar_sub(
    JSUint8Array x,
    JSUint8Array y,
  );

  external JSUint8Array crypto_core_ristretto255_sub(
    JSUint8Array p,
    JSUint8Array q,
  );

  external JSUint8Array crypto_generichash(
    num hash_length,
    JSUint8Array message,
    JSUint8Array? key,
  );

  external JSUint8Array crypto_generichash_blake2b_salt_personal(
    num subkey_len,
    JSUint8Array? key,
    JSUint8Array? id,
    JSUint8Array? ctx,
  );

  external JSUint8Array crypto_generichash_final(
    GenerichashState state_address,
    num hash_length,
  );

  external GenerichashState crypto_generichash_init(
    JSUint8Array? key,
    num hash_length,
  );

  external JSUint8Array crypto_generichash_keygen();

  external void crypto_generichash_update(
    GenerichashState state_address,
    JSUint8Array message_chunk,
  );

  external JSUint8Array crypto_hash(
    JSUint8Array message,
  );

  external JSUint8Array crypto_hash_sha256(
    JSUint8Array message,
  );

  external JSUint8Array crypto_hash_sha256_final(
    HashSha256State state_address,
  );

  external HashSha256State crypto_hash_sha256_init();

  external void crypto_hash_sha256_update(
    HashSha256State state_address,
    JSUint8Array message_chunk,
  );

  external JSUint8Array crypto_hash_sha512(
    JSUint8Array message,
  );

  external JSUint8Array crypto_hash_sha512_final(
    HashSha512State state_address,
  );

  external HashSha512State crypto_hash_sha512_init();

  external void crypto_hash_sha512_update(
    HashSha512State state_address,
    JSUint8Array message_chunk,
  );

  external JSUint8Array crypto_kdf_derive_from_key(
    num subkey_len,
    JSBigInt subkey_id,
    String ctx,
    JSUint8Array key,
  );

  external JSUint8Array crypto_kdf_keygen();

  external CryptoKX crypto_kx_client_session_keys(
    JSUint8Array clientPublicKey,
    JSUint8Array clientSecretKey,
    JSUint8Array serverPublicKey,
  );

  external KeyPair crypto_kx_keypair();

  external KeyPair crypto_kx_seed_keypair(
    JSUint8Array seed,
  );

  external CryptoKX crypto_kx_server_session_keys(
    JSUint8Array serverPublicKey,
    JSUint8Array serverSecretKey,
    JSUint8Array clientPublicKey,
  );

  external JSUint8Array crypto_onetimeauth(
    JSUint8Array message,
    JSUint8Array key,
  );

  external JSUint8Array crypto_onetimeauth_final(
    OnetimeauthState state_address,
  );

  external OnetimeauthState crypto_onetimeauth_init(
    JSUint8Array? key,
  );

  external JSUint8Array crypto_onetimeauth_keygen();

  external void crypto_onetimeauth_update(
    OnetimeauthState state_address,
    JSUint8Array message_chunk,
  );

  external bool crypto_onetimeauth_verify(
    JSUint8Array hash,
    JSUint8Array message,
    JSUint8Array key,
  );

  external JSUint8Array crypto_pwhash(
    num keyLength,
    JSUint8Array password,
    JSUint8Array salt,
    num opsLimit,
    num memLimit,
    num algorithm,
  );

  external JSUint8Array crypto_pwhash_scryptsalsa208sha256(
    num keyLength,
    JSUint8Array password,
    JSUint8Array salt,
    num opsLimit,
    num memLimit,
  );

  external JSUint8Array crypto_pwhash_scryptsalsa208sha256_ll(
    JSUint8Array password,
    JSUint8Array salt,
    num opsLimit,
    num r,
    num p,
    num keyLength,
  );

  external String crypto_pwhash_scryptsalsa208sha256_str(
    JSUint8Array password,
    num opsLimit,
    num memLimit,
  );

  external bool crypto_pwhash_scryptsalsa208sha256_str_verify(
    String hashed_password,
    JSUint8Array password,
  );

  external String crypto_pwhash_str(
    JSUint8Array password,
    num opsLimit,
    num memLimit,
  );

  external bool crypto_pwhash_str_needs_rehash(
    String hashed_password,
    num opsLimit,
    num memLimit,
  );

  external bool crypto_pwhash_str_verify(
    String hashed_password,
    JSUint8Array password,
  );

  external JSUint8Array crypto_scalarmult(
    JSUint8Array privateKey,
    JSUint8Array publicKey,
  );

  external JSUint8Array crypto_scalarmult_base(
    JSUint8Array privateKey,
  );

  external JSUint8Array crypto_scalarmult_ed25519(
    JSUint8Array n,
    JSUint8Array p,
  );

  external JSUint8Array crypto_scalarmult_ed25519_base(
    JSUint8Array scalar,
  );

  external JSUint8Array crypto_scalarmult_ed25519_base_noclamp(
    JSUint8Array scalar,
  );

  external JSUint8Array crypto_scalarmult_ed25519_noclamp(
    JSUint8Array n,
    JSUint8Array p,
  );

  external JSUint8Array crypto_scalarmult_ristretto255(
    JSUint8Array scalar,
    JSUint8Array element,
  );

  external JSUint8Array crypto_scalarmult_ristretto255_base(
    JSUint8Array scalar,
  );

  external SecretBox crypto_secretbox_detached(
    JSUint8Array message,
    JSUint8Array nonce,
    JSUint8Array key,
  );

  external JSUint8Array crypto_secretbox_easy(
    JSUint8Array message,
    JSUint8Array nonce,
    JSUint8Array key,
  );

  external JSUint8Array crypto_secretbox_keygen();

  external JSUint8Array crypto_secretbox_open_detached(
    JSUint8Array ciphertext,
    JSUint8Array mac,
    JSUint8Array nonce,
    JSUint8Array key,
  );

  external JSUint8Array crypto_secretbox_open_easy(
    JSUint8Array ciphertext,
    JSUint8Array nonce,
    JSUint8Array key,
  );

  external SecretstreamXchacha20poly1305State
      crypto_secretstream_xchacha20poly1305_init_pull(
    JSUint8Array header,
    JSUint8Array key,
  );

  external SecretStreamInitPush crypto_secretstream_xchacha20poly1305_init_push(
    JSUint8Array key,
  );

  external JSUint8Array crypto_secretstream_xchacha20poly1305_keygen();

  external JSAny crypto_secretstream_xchacha20poly1305_pull(
    SecretstreamXchacha20poly1305State state_address,
    JSUint8Array cipher,
    JSUint8Array? ad,
  );

  external JSUint8Array crypto_secretstream_xchacha20poly1305_push(
    SecretstreamXchacha20poly1305State state_address,
    JSUint8Array message_chunk,
    JSUint8Array? ad,
    num tag,
  );

  external bool crypto_secretstream_xchacha20poly1305_rekey(
    SecretstreamXchacha20poly1305State state_address,
  );

  external JSUint8Array crypto_shorthash(
    JSUint8Array message,
    JSUint8Array key,
  );

  external JSUint8Array crypto_shorthash_keygen();

  external JSUint8Array crypto_shorthash_siphashx24(
    JSUint8Array message,
    JSUint8Array key,
  );

  external JSUint8Array crypto_sign(
    JSUint8Array message,
    JSUint8Array privateKey,
  );

  external JSUint8Array crypto_sign_detached(
    JSUint8Array message,
    JSUint8Array privateKey,
  );

  external JSUint8Array crypto_sign_ed25519_pk_to_curve25519(
    JSUint8Array edPk,
  );

  external JSUint8Array crypto_sign_ed25519_sk_to_curve25519(
    JSUint8Array edSk,
  );

  external JSUint8Array crypto_sign_ed25519_sk_to_pk(
    JSUint8Array privateKey,
  );

  external JSUint8Array crypto_sign_ed25519_sk_to_seed(
    JSUint8Array privateKey,
  );

  external JSUint8Array crypto_sign_final_create(
    SignState state_address,
    JSUint8Array privateKey,
  );

  external bool crypto_sign_final_verify(
    SignState state_address,
    JSUint8Array signature,
    JSUint8Array publicKey,
  );

  external SignState crypto_sign_init();

  external KeyPair crypto_sign_keypair();

  external JSUint8Array crypto_sign_open(
    JSUint8Array signedMessage,
    JSUint8Array publicKey,
  );

  external KeyPair crypto_sign_seed_keypair(
    JSUint8Array seed,
  );

  external void crypto_sign_update(
    SignState state_address,
    JSUint8Array message_chunk,
  );

  external bool crypto_sign_verify_detached(
    JSUint8Array signature,
    JSUint8Array message,
    JSUint8Array publicKey,
  );

  external JSUint8Array crypto_stream_chacha20(
    num outLength,
    JSUint8Array key,
    JSUint8Array nonce,
  );

  external JSUint8Array crypto_stream_chacha20_ietf_xor(
    JSUint8Array input_message,
    JSUint8Array nonce,
    JSUint8Array key,
  );

  external JSUint8Array crypto_stream_chacha20_ietf_xor_ic(
    JSUint8Array input_message,
    JSUint8Array nonce,
    num nonce_increment,
    JSUint8Array key,
  );

  external JSUint8Array crypto_stream_chacha20_keygen();

  external JSUint8Array crypto_stream_chacha20_xor(
    JSUint8Array input_message,
    JSUint8Array nonce,
    JSUint8Array key,
  );

  external JSUint8Array crypto_stream_chacha20_xor_ic(
    JSUint8Array input_message,
    JSUint8Array nonce,
    num nonce_increment,
    JSUint8Array key,
  );

  external JSUint8Array crypto_stream_keygen();

  external JSUint8Array crypto_stream_xchacha20_keygen();

  external JSUint8Array crypto_stream_xchacha20_xor(
    JSUint8Array input_message,
    JSUint8Array nonce,
    JSUint8Array key,
  );

  external JSUint8Array crypto_stream_xchacha20_xor_ic(
    JSUint8Array input_message,
    JSUint8Array nonce,
    num nonce_increment,
    JSUint8Array key,
  );

  external JSUint8Array randombytes_buf(
    num length,
  );

  external JSUint8Array randombytes_buf_deterministic(
    num length,
    JSUint8Array seed,
  );

  external void randombytes_close();

  external int randombytes_random();

  external void randombytes_set_implementation(
    JSAny implementation,
  );

  external void randombytes_stir();

  external int randombytes_uniform(
    num upper_bound,
  );

  external String sodium_version_string();

  external num randombytes_seedbytes();

  external void memzero(JSUint8Array bytes);

  external JSUint8Array pad(JSUint8Array buf, num blocksize);

  external JSUint8Array unpad(JSUint8Array buf, num blocksize);
}
