// ignore_for_file: non_constant_identifier_names

@JS()
library sodium.js;

import 'dart:typed_data';

import 'package:js/js.dart';

@JS()
@anonymous
class LibSodiumJS {
  external num SODIUM_LIBRARY_VERSION_MAJOR;

  external num SODIUM_LIBRARY_VERSION_MINOR;

  external String SODIUM_VERSION_STRING;

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

  external num crypto_pwhash_argon2i_SALTBYTES;

  external num crypto_pwhash_argon2i_STRBYTES;

  external num crypto_pwhash_argon2id_BYTES_MAX;

  external num crypto_pwhash_argon2id_BYTES_MIN;

  external num crypto_pwhash_argon2id_SALTBYTES;

  external num crypto_pwhash_argon2id_STRBYTES;

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

  external void crypto_sign_final_verify(
    Never state_address,
    Never signature,
    Never publicKey,
  );

  external Never crypto_scalarmult_ed25519(
    Never n,
    Never p,
  );

  external void randombytes_set_implementation(
    Never implementation,
  );

  external Never crypto_box_seed_keypair(
    Never seed,
  );

  external Never crypto_core_ristretto255_scalar_complement(
    Never s,
  );

  external Never randombytes_buf(
    num length,
  );

  external Never crypto_scalarmult_ed25519_noclamp(
    Never n,
    Never p,
  );

  external Never crypto_stream_xchacha20_xor(
    Never input_message,
    Never nonce,
    Never key,
  );

  external Never randombytes_buf_deterministic(
    num length,
    Never seed,
  );

  external Never crypto_sign_ed25519_sk_to_seed(
    Never privateKey,
  );

  external Never crypto_hash_sha256_init();

  external Never crypto_sign_ed25519_pk_to_curve25519(
    Never edPk,
  );

  external void randombytes_stir();

  external void crypto_pwhash_scryptsalsa208sha256_str_verify(
    String hashed_password,
    Never password,
  );

  external Never crypto_hash_sha256(
    Never message,
  );

  external Never crypto_kx_server_session_keys(
    Never serverPublicKey,
    Never serverSecretKey,
    Never clientPublicKey,
  );

  external Never crypto_kx_client_session_keys(
    Never clientPublicKey,
    Never clientSecretKey,
    Never serverPublicKey,
  );

  external Never crypto_auth_hmacsha512_keygen();

  external Never crypto_core_ristretto255_random();

  external void crypto_secretstream_xchacha20poly1305_rekey(
    Never state_address,
  );

  external Never crypto_box_keypair();

  external Never crypto_auth_hmacsha256_keygen();

  external Never crypto_sign_ed25519_sk_to_curve25519(
    Never edSk,
  );

  external Never crypto_scalarmult_ristretto255(
    Never scalar,
    Never element,
  );

  external Never crypto_core_ed25519_scalar_sub(
    Never x,
    Never y,
  );

  external Never crypto_sign_detached(
    Never message,
    Never privateKey,
  );

  external Never crypto_secretbox_detached(
    Never message,
    Never nonce,
    Never key,
  );

  external Never crypto_onetimeauth_keygen();

  external Never crypto_onetimeauth_init(
    Never key,
  );

  external Never crypto_aead_chacha20poly1305_encrypt_detached(
    Never message,
    Never additional_data,
    Never secret_nonce,
    Never public_nonce,
    Never key,
  );

  external Never crypto_stream_xchacha20_keygen();

  external Never crypto_box_beforenm(
    Never publicKey,
    Never privateKey,
  );

  external Never crypto_core_ed25519_sub(
    Never p,
    Never q,
  );

  external Never crypto_aead_chacha20poly1305_keygen();

  external Never crypto_auth_hmacsha512(
    Never message,
    Never key,
  );

  external Never crypto_core_ristretto255_scalar_random();

  external Never crypto_aead_chacha20poly1305_decrypt_detached(
    Never secret_nonce,
    Never ciphertext,
    Never mac,
    Never additional_data,
    Never public_nonce,
    Never key,
  );

  external Never crypto_generichash_keygen();

  external Never crypto_kdf_keygen();

  external Never crypto_shorthash_keygen();

  external Never crypto_sign_keypair();

  external Never crypto_hash_sha256_final(
    Never state_address,
  );

  external Never crypto_box_curve25519xchacha20poly1305_keypair();

  external Never crypto_shorthash_siphashx24(
    Never message,
    Never key,
  );

  external Never crypto_sign_open(
    Never signedMessage,
    Never publicKey,
  );

  external void crypto_sign_update(
    Never state_address,
    Never message_chunk,
  );

  external Never crypto_kx_seed_keypair(
    Never seed,
  );

  external Never crypto_box_open_detached(
    Never ciphertext,
    Never mac,
    Never nonce,
    Never publicKey,
    Never privateKey,
  );

  external Never crypto_hash_sha512_final(
    Never state_address,
  );

  external Never crypto_generichash(
    num hash_length,
    Never message,
    Never key,
  );

  external void crypto_auth_verify(
    Never tag,
    Never message,
    Never key,
  );

  external void crypto_auth_hmacsha256_verify(
    Never tag,
    Never message,
    Never key,
  );

  external Never crypto_pwhash_scryptsalsa208sha256_ll(
    Never password,
    Never salt,
    num opsLimit,
    num r,
    num p,
    num keyLength,
  );

  external void crypto_core_ed25519_is_valid_point(
    Never repr,
  );

  external void sodium_version_string();

  external void crypto_onetimeauth_update(
    Never state_address,
    Never message_chunk,
  );

  external Never crypto_stream_keygen();

  external Never crypto_aead_xchacha20poly1305_ietf_decrypt_detached(
    Never secret_nonce,
    Never ciphertext,
    Never mac,
    Never additional_data,
    Never public_nonce,
    Never key,
  );

  external Never crypto_core_ristretto255_scalar_mul(
    Never x,
    Never y,
  );

  external Never crypto_core_ristretto255_scalar_negate(
    Never s,
  );

  external Never crypto_box_seal_open(
    Never ciphertext,
    Never publicKey,
    Never privateKey,
  );

  external Never crypto_kdf_derive_from_key(
    num subkey_len,
    num subkey_id,
    String ctx,
    Never key,
  );

  external Never crypto_box_seal(
    Never message,
    Never publicKey,
  );

  external Never crypto_pwhash(
    num keyLength,
    Never password,
    Never salt,
    num opsLimit,
    num memLimit,
    num algorithm,
  );

  external void crypto_pwhash_str_needs_rehash(
    String hashed_password,
    num opsLimit,
    num memLimit,
  );

  external Never crypto_box_easy(
    Never message,
    Never nonce,
    Never publicKey,
    Never privateKey,
  );

  external Never crypto_aead_chacha20poly1305_ietf_keygen();

  external Never crypto_core_ristretto255_scalar_sub(
    Never x,
    Never y,
  );

  external Never crypto_stream_chacha20(
    num outLength,
    Never key,
    Never nonce,
  );

  external void crypto_onetimeauth_verify(
    Never hash,
    Never message,
    Never key,
  );

  external Never crypto_core_ed25519_scalar_add(
    Never x,
    Never y,
  );

  external Never crypto_aead_xchacha20poly1305_ietf_encrypt(
    Never message,
    Never additional_data,
    Never secret_nonce,
    Never public_nonce,
    Never key,
  );

  external Never crypto_sign_ed25519_sk_to_pk(
    Never privateKey,
  );

  external Never crypto_secretstream_xchacha20poly1305_keygen();

  external Never crypto_secretstream_xchacha20poly1305_pull(
    Never state_address,
    Never cipher,
    Never ad,
  );

  external Never crypto_scalarmult_ristretto255_base(
    Never scalar,
  );

  external Never crypto_core_ed25519_scalar_mul(
    Never x,
    Never y,
  );

  external Never crypto_generichash_init(
    Never key,
    num hash_length,
  );

  external Never crypto_core_ed25519_from_uniform(
    Never r,
  );

  external Never crypto_core_ristretto255_sub(
    Never p,
    Never q,
  );

  external Never crypto_core_ristretto255_add(
    Never p,
    Never q,
  );

  external Never crypto_secretbox_easy(
    Never message,
    Never nonce,
    Never key,
  );

  external Never crypto_aead_chacha20poly1305_decrypt(
    Never secret_nonce,
    Never ciphertext,
    Never additional_data,
    Never public_nonce,
    Never key,
  );

  external Never crypto_box_curve25519xchacha20poly1305_seal(
    Never message,
    Never publicKey,
  );

  external Never crypto_stream_xchacha20_xor_ic(
    Never input_message,
    Never nonce,
    num nonce_increment,
    Never key,
  );

  external void crypto_sign_verify_detached(
    Never signature,
    Never message,
    Never publicKey,
  );

  external Never crypto_core_ristretto255_scalar_add(
    Never x,
    Never y,
  );

  external Never crypto_scalarmult_base(
    Never privateKey,
  );

  external void randombytes_close();

  external Never crypto_onetimeauth_final(
    Never state_address,
  );

  external Never crypto_generichash_blake2b_salt_personal(
    num subkey_len,
    Never key,
    Never id,
    Never ctx,
  );

  external Never crypto_hash_sha512(
    Never message,
  );

  external Never crypto_core_ed25519_random();

  external Never crypto_aead_xchacha20poly1305_ietf_decrypt(
    Never secret_nonce,
    Never ciphertext,
    Never additional_data,
    Never public_nonce,
    Never key,
  );

  external Never crypto_core_ed25519_scalar_reduce(
    Never sample,
  );

  external void crypto_hash_sha256_update(
    Never state_address,
    Never message_chunk,
  );

  external Never crypto_stream_chacha20_ietf_xor_ic(
    Never input_message,
    Never nonce,
    num nonce_increment,
    Never key,
  );

  external Never crypto_aead_chacha20poly1305_ietf_encrypt_detached(
    Never message,
    Never additional_data,
    Never secret_nonce,
    Never public_nonce,
    Never key,
  );

  external Never crypto_box_detached(
    Never message,
    Never nonce,
    Never publicKey,
    Never privateKey,
  );

  external Never crypto_stream_chacha20_xor(
    Never input_message,
    Never nonce,
    Never key,
  );

  external Never crypto_scalarmult(
    Never privateKey,
    Never publicKey,
  );

  external Never crypto_core_ed25519_scalar_negate(
    Never s,
  );

  external Never crypto_scalarmult_ed25519_base_noclamp(
    Never scalar,
  );

  external Never crypto_stream_chacha20_keygen();

  external Never crypto_sign_init();

  external Never crypto_hash_sha512_init();

  external Never crypto_core_ed25519_scalar_random();

  external Never crypto_aead_chacha20poly1305_ietf_decrypt(
    Never secret_nonce,
    Never ciphertext,
    Never additional_data,
    Never public_nonce,
    Never key,
  );

  external Never crypto_aead_chacha20poly1305_ietf_encrypt(
    Never message,
    Never additional_data,
    Never secret_nonce,
    Never public_nonce,
    Never key,
  );

  external Never crypto_aead_chacha20poly1305_encrypt(
    Never message,
    Never additional_data,
    Never secret_nonce,
    Never public_nonce,
    Never key,
  );

  external Never crypto_auth(
    Never message,
    Never key,
  );

  external Never crypto_box_curve25519xchacha20poly1305_seal_open(
    Never ciphertext,
    Never publicKey,
    Never secretKey,
  );

  external Never crypto_secretstream_xchacha20poly1305_init_push(
    Never key,
  );

  external void randombytes_uniform(
    num upper_bound,
  );

  external Never crypto_secretbox_keygen();

  external Never crypto_core_ristretto255_from_hash(
    Never r,
  );

  external Never crypto_shorthash(
    Never message,
    Never key,
  );

  external Never crypto_pwhash_str(
    Never password,
    num opsLimit,
    num memLimit,
  );

  external void crypto_hash_sha512_update(
    Never state_address,
    Never message_chunk,
  );

  external Never crypto_generichash_final(
    Never state_address,
    num hash_length,
  );

  external Never crypto_aead_xchacha20poly1305_ietf_encrypt_detached(
    Never message,
    Never additional_data,
    Never secret_nonce,
    Never public_nonce,
    Never key,
  );

  external Never crypto_pwhash_scryptsalsa208sha256(
    num keyLength,
    Never password,
    Never salt,
    num opsLimit,
    num memLimit,
  );

  external Never crypto_kx_keypair();

  external void crypto_pwhash_str_verify(
    String hashed_password,
    Never password,
  );

  external void crypto_core_ristretto255_is_valid_point(
    Never repr,
  );

  external Never crypto_aead_chacha20poly1305_ietf_decrypt_detached(
    Never secret_nonce,
    Never ciphertext,
    Never mac,
    Never additional_data,
    Never public_nonce,
    Never key,
  );

  external Never crypto_scalarmult_ed25519_base(
    Never scalar,
  );

  external Never crypto_core_ristretto255_scalar_reduce(
    Never sample,
  );

  external Never crypto_core_ed25519_add(
    Never p,
    Never q,
  );

  external void randombytes_random();

  external Never crypto_sign(
    Never message,
    Never privateKey,
  );

  external Never crypto_hash(
    Never message,
  );

  external void crypto_auth_hmacsha512_verify(
    Never tag,
    Never message,
    Never key,
  );

  external Never crypto_core_ed25519_from_hash(
    Never r,
  );

  external Never crypto_secretbox_open_easy(
    Never ciphertext,
    Never nonce,
    Never key,
  );

  external Never crypto_stream_chacha20_xor_ic(
    Never input_message,
    Never nonce,
    num nonce_increment,
    Never key,
  );

  external Never crypto_onetimeauth(
    Never message,
    Never key,
  );

  external Never crypto_sign_seed_keypair(
    Never seed,
  );

  external Never crypto_core_ed25519_scalar_invert(
    Never s,
  );

  external Never crypto_box_open_easy_afternm(
    Never ciphertext,
    Never nonce,
    Never sharedKey,
  );

  external Never crypto_secretbox_open_detached(
    Never ciphertext,
    Never mac,
    Never nonce,
    Never key,
  );

  external Never crypto_core_ed25519_scalar_complement(
    Never s,
  );

  external Never crypto_pwhash_scryptsalsa208sha256_str(
    Never password,
    num opsLimit,
    num memLimit,
  );

  external void crypto_generichash_update(
    Never state_address,
    Never message_chunk,
  );

  external Never crypto_secretstream_xchacha20poly1305_init_pull(
    Never header,
    Never key,
  );

  external Never crypto_box_open_easy(
    Never ciphertext,
    Never nonce,
    Never publicKey,
    Never privateKey,
  );

  external Never crypto_aead_xchacha20poly1305_ietf_keygen();

  external Never crypto_stream_chacha20_ietf_xor(
    Never input_message,
    Never nonce,
    Never key,
  );

  external Never crypto_auth_hmacsha256(
    Never message,
    Never key,
  );

  external Never crypto_core_ristretto255_scalar_invert(
    Never s,
  );

  external Never crypto_auth_keygen();

  external Never crypto_box_easy_afternm(
    Never message,
    Never nonce,
    Never sharedKey,
  );

  external Never crypto_secretstream_xchacha20poly1305_push(
    Never state_address,
    Never message_chunk,
    Never ad,
    num tag,
  );

  external Never crypto_sign_final_create(
    Never state_address,
    Never privateKey,
  );
}
