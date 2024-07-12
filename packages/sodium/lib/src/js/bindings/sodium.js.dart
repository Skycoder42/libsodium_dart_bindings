// ignore_for_file: non_constant_identifier_names, public_member_api_docs

@JS()
library sodium.js;

import 'dart:typed_data';

import 'package:js/js.dart';

import 'js_big_int.dart';

typedef SecretstreamXchacha20poly1305State = num;

typedef SignState = num;

typedef GenerichashState = num;

typedef HashSha256State = num;

typedef HashSha512State = num;

typedef OnetimeauthState = num;

typedef AuthHmacsha256State = num;

typedef AuthHmacsha512State = num;

typedef AuthHmacsha512256State = num;

@JS()
@anonymous
class CryptoBox {
  external Uint8List get ciphertext;
  external Uint8List get mac;

  external factory CryptoBox({
    required Uint8List ciphertext,
    required Uint8List mac,
  });
}

@JS()
@anonymous
class CryptoKX {
  external Uint8List get sharedRx;
  external Uint8List get sharedTx;

  external factory CryptoKX({
    required Uint8List sharedRx,
    required Uint8List sharedTx,
  });
}

@JS()
@anonymous
class KeyPair {
  external String get keyType;
  external Uint8List get privateKey;
  external Uint8List get publicKey;

  external factory KeyPair({
    required String keyType,
    required Uint8List privateKey,
    required Uint8List publicKey,
  });
}

@JS()
@anonymous
class SecretBox {
  external Uint8List get cipher;
  external Uint8List get mac;

  external factory SecretBox({
    required Uint8List cipher,
    required Uint8List mac,
  });
}

@JS()
@anonymous
class SecretStreamInitPush {
  external num get state;
  external Uint8List get header;

  external factory SecretStreamInitPush({
    required num state,
    required Uint8List header,
  });
}

@JS()
@anonymous
class SecretStreamPull {
  external Uint8List get message;
  external num get tag;

  external factory SecretStreamPull({
    required Uint8List message,
    required num tag,
  });
}

@JS()
@anonymous
class LibSodiumJS {
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

  external Uint8List crypto_aead_aegis128l_decrypt(
    Uint8List? secret_nonce,
    Uint8List ciphertext,
    Uint8List? additional_data,
    Uint8List public_nonce,
    Uint8List key,
  );

  external Uint8List crypto_aead_aegis128l_decrypt_detached(
    Uint8List? secret_nonce,
    Uint8List ciphertext,
    Uint8List mac,
    Uint8List? additional_data,
    Uint8List public_nonce,
    Uint8List key,
  );

  external Uint8List crypto_aead_aegis128l_encrypt(
    Uint8List message,
    Uint8List? additional_data,
    Uint8List? secret_nonce,
    Uint8List public_nonce,
    Uint8List key,
  );

  external CryptoBox crypto_aead_aegis128l_encrypt_detached(
    Uint8List message,
    Uint8List? additional_data,
    Uint8List? secret_nonce,
    Uint8List public_nonce,
    Uint8List key,
  );

  external Uint8List crypto_aead_aegis128l_keygen();

  external Uint8List crypto_aead_aegis256_decrypt(
    Uint8List? secret_nonce,
    Uint8List ciphertext,
    Uint8List? additional_data,
    Uint8List public_nonce,
    Uint8List key,
  );

  external Uint8List crypto_aead_aegis256_decrypt_detached(
    Uint8List? secret_nonce,
    Uint8List ciphertext,
    Uint8List mac,
    Uint8List? additional_data,
    Uint8List public_nonce,
    Uint8List key,
  );

  external Uint8List crypto_aead_aegis256_encrypt(
    Uint8List message,
    Uint8List? additional_data,
    Uint8List? secret_nonce,
    Uint8List public_nonce,
    Uint8List key,
  );

  external CryptoBox crypto_aead_aegis256_encrypt_detached(
    Uint8List message,
    Uint8List? additional_data,
    Uint8List? secret_nonce,
    Uint8List public_nonce,
    Uint8List key,
  );

  external Uint8List crypto_aead_aegis256_keygen();

  external Uint8List crypto_aead_chacha20poly1305_decrypt(
    Uint8List? secret_nonce,
    Uint8List ciphertext,
    Uint8List? additional_data,
    Uint8List public_nonce,
    Uint8List key,
  );

  external Uint8List crypto_aead_chacha20poly1305_decrypt_detached(
    Uint8List? secret_nonce,
    Uint8List ciphertext,
    Uint8List mac,
    Uint8List? additional_data,
    Uint8List public_nonce,
    Uint8List key,
  );

  external Uint8List crypto_aead_chacha20poly1305_encrypt(
    Uint8List message,
    Uint8List? additional_data,
    Uint8List? secret_nonce,
    Uint8List public_nonce,
    Uint8List key,
  );

  external CryptoBox crypto_aead_chacha20poly1305_encrypt_detached(
    Uint8List message,
    Uint8List? additional_data,
    Uint8List? secret_nonce,
    Uint8List public_nonce,
    Uint8List key,
  );

  external Uint8List crypto_aead_chacha20poly1305_ietf_decrypt(
    Uint8List? secret_nonce,
    Uint8List ciphertext,
    Uint8List? additional_data,
    Uint8List public_nonce,
    Uint8List key,
  );

  external Uint8List crypto_aead_chacha20poly1305_ietf_decrypt_detached(
    Uint8List? secret_nonce,
    Uint8List ciphertext,
    Uint8List mac,
    Uint8List? additional_data,
    Uint8List public_nonce,
    Uint8List key,
  );

  external Uint8List crypto_aead_chacha20poly1305_ietf_encrypt(
    Uint8List message,
    Uint8List? additional_data,
    Uint8List? secret_nonce,
    Uint8List public_nonce,
    Uint8List key,
  );

  external CryptoBox crypto_aead_chacha20poly1305_ietf_encrypt_detached(
    Uint8List message,
    Uint8List? additional_data,
    Uint8List? secret_nonce,
    Uint8List public_nonce,
    Uint8List key,
  );

  external Uint8List crypto_aead_chacha20poly1305_ietf_keygen();

  external Uint8List crypto_aead_chacha20poly1305_keygen();

  external Uint8List crypto_aead_xchacha20poly1305_ietf_decrypt(
    Uint8List? secret_nonce,
    Uint8List ciphertext,
    Uint8List? additional_data,
    Uint8List public_nonce,
    Uint8List key,
  );

  external Uint8List crypto_aead_xchacha20poly1305_ietf_decrypt_detached(
    Uint8List? secret_nonce,
    Uint8List ciphertext,
    Uint8List mac,
    Uint8List? additional_data,
    Uint8List public_nonce,
    Uint8List key,
  );

  external Uint8List crypto_aead_xchacha20poly1305_ietf_encrypt(
    Uint8List message,
    Uint8List? additional_data,
    Uint8List? secret_nonce,
    Uint8List public_nonce,
    Uint8List key,
  );

  external CryptoBox crypto_aead_xchacha20poly1305_ietf_encrypt_detached(
    Uint8List message,
    Uint8List? additional_data,
    Uint8List? secret_nonce,
    Uint8List public_nonce,
    Uint8List key,
  );

  external Uint8List crypto_aead_xchacha20poly1305_ietf_keygen();

  external Uint8List crypto_auth(
    Uint8List message,
    Uint8List key,
  );

  external Uint8List crypto_auth_hmacsha256(
    Uint8List message,
    Uint8List key,
  );

  external Uint8List crypto_auth_hmacsha256_final(
    AuthHmacsha256State state_address,
  );

  external AuthHmacsha256State crypto_auth_hmacsha256_init(
    Uint8List? key,
  );

  external Uint8List crypto_auth_hmacsha256_keygen();

  external void crypto_auth_hmacsha256_update(
    AuthHmacsha256State state_address,
    Uint8List message_chunk,
  );

  external bool crypto_auth_hmacsha256_verify(
    Uint8List tag,
    Uint8List message,
    Uint8List key,
  );

  external Uint8List crypto_auth_hmacsha512(
    Uint8List message,
    Uint8List key,
  );

  external Uint8List crypto_auth_hmacsha512256(
    Uint8List message,
    Uint8List key,
  );

  external Uint8List crypto_auth_hmacsha512256_final(
    AuthHmacsha512256State state_address,
  );

  external AuthHmacsha512256State crypto_auth_hmacsha512256_init(
    Uint8List? key,
  );

  external Uint8List crypto_auth_hmacsha512256_keygen();

  external void crypto_auth_hmacsha512256_update(
    AuthHmacsha512256State state_address,
    Uint8List message_chunk,
  );

  external bool crypto_auth_hmacsha512256_verify(
    Uint8List tag,
    Uint8List message,
    Uint8List key,
  );

  external Uint8List crypto_auth_hmacsha512_final(
    AuthHmacsha512State state_address,
  );

  external AuthHmacsha512State crypto_auth_hmacsha512_init(
    Uint8List? key,
  );

  external Uint8List crypto_auth_hmacsha512_keygen();

  external void crypto_auth_hmacsha512_update(
    AuthHmacsha512State state_address,
    Uint8List message_chunk,
  );

  external bool crypto_auth_hmacsha512_verify(
    Uint8List tag,
    Uint8List message,
    Uint8List key,
  );

  external Uint8List crypto_auth_keygen();

  external bool crypto_auth_verify(
    Uint8List tag,
    Uint8List message,
    Uint8List key,
  );

  external Uint8List crypto_box_beforenm(
    Uint8List publicKey,
    Uint8List privateKey,
  );

  external Uint8List crypto_box_curve25519xchacha20poly1305_beforenm(
    Uint8List publicKey,
    Uint8List privateKey,
  );

  external CryptoBox crypto_box_curve25519xchacha20poly1305_detached(
    Uint8List message,
    Uint8List nonce,
    Uint8List publicKey,
    Uint8List privateKey,
  );

  external CryptoBox crypto_box_curve25519xchacha20poly1305_detached_afternm(
    Uint8List message,
    Uint8List nonce,
    Uint8List sharedKey,
  );

  external Uint8List crypto_box_curve25519xchacha20poly1305_easy(
    Uint8List message,
    Uint8List nonce,
    Uint8List publicKey,
    Uint8List privateKey,
  );

  external Uint8List crypto_box_curve25519xchacha20poly1305_easy_afternm(
    Uint8List message,
    Uint8List nonce,
    Uint8List sharedKey,
  );

  external KeyPair crypto_box_curve25519xchacha20poly1305_keypair();

  external Uint8List crypto_box_curve25519xchacha20poly1305_open_detached(
    Uint8List ciphertext,
    Uint8List mac,
    Uint8List nonce,
    Uint8List publicKey,
    Uint8List privateKey,
  );

  external Uint8List
      crypto_box_curve25519xchacha20poly1305_open_detached_afternm(
    Uint8List ciphertext,
    Uint8List mac,
    Uint8List nonce,
    Uint8List sharedKey,
  );

  external Uint8List crypto_box_curve25519xchacha20poly1305_open_easy(
    Uint8List ciphertext,
    Uint8List nonce,
    Uint8List publicKey,
    Uint8List privateKey,
  );

  external Uint8List crypto_box_curve25519xchacha20poly1305_open_easy_afternm(
    Uint8List ciphertext,
    Uint8List nonce,
    Uint8List sharedKey,
  );

  external Uint8List crypto_box_curve25519xchacha20poly1305_seal(
    Uint8List message,
    Uint8List publicKey,
  );

  external Uint8List crypto_box_curve25519xchacha20poly1305_seal_open(
    Uint8List ciphertext,
    Uint8List publicKey,
    Uint8List secretKey,
  );

  external KeyPair crypto_box_curve25519xchacha20poly1305_seed_keypair(
    Uint8List seed,
  );

  external CryptoBox crypto_box_detached(
    Uint8List message,
    Uint8List nonce,
    Uint8List publicKey,
    Uint8List privateKey,
  );

  external Uint8List crypto_box_easy(
    Uint8List message,
    Uint8List nonce,
    Uint8List publicKey,
    Uint8List privateKey,
  );

  external Uint8List crypto_box_easy_afternm(
    Uint8List message,
    Uint8List nonce,
    Uint8List sharedKey,
  );

  external KeyPair crypto_box_keypair();

  external Uint8List crypto_box_open_detached(
    Uint8List ciphertext,
    Uint8List mac,
    Uint8List nonce,
    Uint8List publicKey,
    Uint8List privateKey,
  );

  external Uint8List crypto_box_open_easy(
    Uint8List ciphertext,
    Uint8List nonce,
    Uint8List publicKey,
    Uint8List privateKey,
  );

  external Uint8List crypto_box_open_easy_afternm(
    Uint8List ciphertext,
    Uint8List nonce,
    Uint8List sharedKey,
  );

  external Uint8List crypto_box_seal(
    Uint8List message,
    Uint8List publicKey,
  );

  external Uint8List crypto_box_seal_open(
    Uint8List ciphertext,
    Uint8List publicKey,
    Uint8List privateKey,
  );

  external KeyPair crypto_box_seed_keypair(
    Uint8List seed,
  );

  external Uint8List crypto_core_ed25519_add(
    Uint8List p,
    Uint8List q,
  );

  external Uint8List crypto_core_ed25519_from_hash(
    Uint8List r,
  );

  external Uint8List crypto_core_ed25519_from_uniform(
    Uint8List r,
  );

  external bool crypto_core_ed25519_is_valid_point(
    Uint8List repr,
  );

  external Uint8List crypto_core_ed25519_random();

  external Uint8List crypto_core_ed25519_scalar_add(
    Uint8List x,
    Uint8List y,
  );

  external Uint8List crypto_core_ed25519_scalar_complement(
    Uint8List s,
  );

  external Uint8List crypto_core_ed25519_scalar_invert(
    Uint8List s,
  );

  external Uint8List crypto_core_ed25519_scalar_mul(
    Uint8List x,
    Uint8List y,
  );

  external Uint8List crypto_core_ed25519_scalar_negate(
    Uint8List s,
  );

  external Uint8List crypto_core_ed25519_scalar_random();

  external Uint8List crypto_core_ed25519_scalar_reduce(
    Uint8List sample,
  );

  external Uint8List crypto_core_ed25519_scalar_sub(
    Uint8List x,
    Uint8List y,
  );

  external Uint8List crypto_core_ed25519_sub(
    Uint8List p,
    Uint8List q,
  );

  external Uint8List crypto_core_hchacha20(
    Uint8List input,
    Uint8List privateKey,
    Uint8List? constant,
  );

  external Uint8List crypto_core_hsalsa20(
    Uint8List input,
    Uint8List privateKey,
    Uint8List? constant,
  );

  external Uint8List crypto_core_ristretto255_add(
    Uint8List p,
    Uint8List q,
  );

  external Uint8List crypto_core_ristretto255_from_hash(
    Uint8List r,
  );

  external bool crypto_core_ristretto255_is_valid_point(
    Uint8List repr,
  );

  external Uint8List crypto_core_ristretto255_random();

  external Uint8List crypto_core_ristretto255_scalar_add(
    Uint8List x,
    Uint8List y,
  );

  external Uint8List crypto_core_ristretto255_scalar_complement(
    Uint8List s,
  );

  external Uint8List crypto_core_ristretto255_scalar_invert(
    Uint8List s,
  );

  external Uint8List crypto_core_ristretto255_scalar_mul(
    Uint8List x,
    Uint8List y,
  );

  external Uint8List crypto_core_ristretto255_scalar_negate(
    Uint8List s,
  );

  external Uint8List crypto_core_ristretto255_scalar_random();

  external Uint8List crypto_core_ristretto255_scalar_reduce(
    Uint8List sample,
  );

  external Uint8List crypto_core_ristretto255_scalar_sub(
    Uint8List x,
    Uint8List y,
  );

  external Uint8List crypto_core_ristretto255_sub(
    Uint8List p,
    Uint8List q,
  );

  external Uint8List crypto_generichash(
    num hash_length,
    Uint8List message,
    Uint8List? key,
  );

  external Uint8List crypto_generichash_blake2b_salt_personal(
    num subkey_len,
    Uint8List? key,
    Uint8List? id,
    Uint8List? ctx,
  );

  external Uint8List crypto_generichash_final(
    GenerichashState state_address,
    num hash_length,
  );

  external GenerichashState crypto_generichash_init(
    Uint8List? key,
    num hash_length,
  );

  external Uint8List crypto_generichash_keygen();

  external void crypto_generichash_update(
    GenerichashState state_address,
    Uint8List message_chunk,
  );

  external Uint8List crypto_hash(
    Uint8List message,
  );

  external Uint8List crypto_hash_sha256(
    Uint8List message,
  );

  external Uint8List crypto_hash_sha256_final(
    HashSha256State state_address,
  );

  external HashSha256State crypto_hash_sha256_init();

  external void crypto_hash_sha256_update(
    HashSha256State state_address,
    Uint8List message_chunk,
  );

  external Uint8List crypto_hash_sha512(
    Uint8List message,
  );

  external Uint8List crypto_hash_sha512_final(
    HashSha512State state_address,
  );

  external HashSha512State crypto_hash_sha512_init();

  external void crypto_hash_sha512_update(
    HashSha512State state_address,
    Uint8List message_chunk,
  );

  external Uint8List crypto_kdf_derive_from_key(
    num subkey_len,
    JsBigInt subkey_id,
    String ctx,
    Uint8List key,
  );

  external Uint8List crypto_kdf_keygen();

  external CryptoKX crypto_kx_client_session_keys(
    Uint8List clientPublicKey,
    Uint8List clientSecretKey,
    Uint8List serverPublicKey,
  );

  external KeyPair crypto_kx_keypair();

  external KeyPair crypto_kx_seed_keypair(
    Uint8List seed,
  );

  external CryptoKX crypto_kx_server_session_keys(
    Uint8List serverPublicKey,
    Uint8List serverSecretKey,
    Uint8List clientPublicKey,
  );

  external Uint8List crypto_onetimeauth(
    Uint8List message,
    Uint8List key,
  );

  external Uint8List crypto_onetimeauth_final(
    OnetimeauthState state_address,
  );

  external OnetimeauthState crypto_onetimeauth_init(
    Uint8List? key,
  );

  external Uint8List crypto_onetimeauth_keygen();

  external void crypto_onetimeauth_update(
    OnetimeauthState state_address,
    Uint8List message_chunk,
  );

  external bool crypto_onetimeauth_verify(
    Uint8List hash,
    Uint8List message,
    Uint8List key,
  );

  external Uint8List crypto_pwhash(
    num keyLength,
    Uint8List password,
    Uint8List salt,
    num opsLimit,
    num memLimit,
    num algorithm,
  );

  external Uint8List crypto_pwhash_scryptsalsa208sha256(
    num keyLength,
    Uint8List password,
    Uint8List salt,
    num opsLimit,
    num memLimit,
  );

  external Uint8List crypto_pwhash_scryptsalsa208sha256_ll(
    Uint8List password,
    Uint8List salt,
    num opsLimit,
    num r,
    num p,
    num keyLength,
  );

  external String crypto_pwhash_scryptsalsa208sha256_str(
    Uint8List password,
    num opsLimit,
    num memLimit,
  );

  external bool crypto_pwhash_scryptsalsa208sha256_str_verify(
    String hashed_password,
    Uint8List password,
  );

  external String crypto_pwhash_str(
    Uint8List password,
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
    Uint8List password,
  );

  external Uint8List crypto_scalarmult(
    Uint8List privateKey,
    Uint8List publicKey,
  );

  external Uint8List crypto_scalarmult_base(
    Uint8List privateKey,
  );

  external Uint8List crypto_scalarmult_ed25519(
    Uint8List n,
    Uint8List p,
  );

  external Uint8List crypto_scalarmult_ed25519_base(
    Uint8List scalar,
  );

  external Uint8List crypto_scalarmult_ed25519_base_noclamp(
    Uint8List scalar,
  );

  external Uint8List crypto_scalarmult_ed25519_noclamp(
    Uint8List n,
    Uint8List p,
  );

  external Uint8List crypto_scalarmult_ristretto255(
    Uint8List scalar,
    Uint8List element,
  );

  external Uint8List crypto_scalarmult_ristretto255_base(
    Uint8List scalar,
  );

  external SecretBox crypto_secretbox_detached(
    Uint8List message,
    Uint8List nonce,
    Uint8List key,
  );

  external Uint8List crypto_secretbox_easy(
    Uint8List message,
    Uint8List nonce,
    Uint8List key,
  );

  external Uint8List crypto_secretbox_keygen();

  external Uint8List crypto_secretbox_open_detached(
    Uint8List ciphertext,
    Uint8List mac,
    Uint8List nonce,
    Uint8List key,
  );

  external Uint8List crypto_secretbox_open_easy(
    Uint8List ciphertext,
    Uint8List nonce,
    Uint8List key,
  );

  external SecretstreamXchacha20poly1305State
      crypto_secretstream_xchacha20poly1305_init_pull(
    Uint8List header,
    Uint8List key,
  );

  external SecretStreamInitPush crypto_secretstream_xchacha20poly1305_init_push(
    Uint8List key,
  );

  external Uint8List crypto_secretstream_xchacha20poly1305_keygen();

  external dynamic crypto_secretstream_xchacha20poly1305_pull(
    SecretstreamXchacha20poly1305State state_address,
    Uint8List cipher,
    Uint8List? ad,
  );

  external Uint8List crypto_secretstream_xchacha20poly1305_push(
    SecretstreamXchacha20poly1305State state_address,
    Uint8List message_chunk,
    Uint8List? ad,
    num tag,
  );

  external bool crypto_secretstream_xchacha20poly1305_rekey(
    SecretstreamXchacha20poly1305State state_address,
  );

  external Uint8List crypto_shorthash(
    Uint8List message,
    Uint8List key,
  );

  external Uint8List crypto_shorthash_keygen();

  external Uint8List crypto_shorthash_siphashx24(
    Uint8List message,
    Uint8List key,
  );

  external Uint8List crypto_sign(
    Uint8List message,
    Uint8List privateKey,
  );

  external Uint8List crypto_sign_detached(
    Uint8List message,
    Uint8List privateKey,
  );

  external Uint8List crypto_sign_ed25519_pk_to_curve25519(
    Uint8List edPk,
  );

  external Uint8List crypto_sign_ed25519_sk_to_curve25519(
    Uint8List edSk,
  );

  external Uint8List crypto_sign_ed25519_sk_to_pk(
    Uint8List privateKey,
  );

  external Uint8List crypto_sign_ed25519_sk_to_seed(
    Uint8List privateKey,
  );

  external Uint8List crypto_sign_final_create(
    SignState state_address,
    Uint8List privateKey,
  );

  external bool crypto_sign_final_verify(
    SignState state_address,
    Uint8List signature,
    Uint8List publicKey,
  );

  external SignState crypto_sign_init();

  external KeyPair crypto_sign_keypair();

  external Uint8List crypto_sign_open(
    Uint8List signedMessage,
    Uint8List publicKey,
  );

  external KeyPair crypto_sign_seed_keypair(
    Uint8List seed,
  );

  external void crypto_sign_update(
    SignState state_address,
    Uint8List message_chunk,
  );

  external bool crypto_sign_verify_detached(
    Uint8List signature,
    Uint8List message,
    Uint8List publicKey,
  );

  external Uint8List crypto_stream_chacha20(
    num outLength,
    Uint8List key,
    Uint8List nonce,
  );

  external Uint8List crypto_stream_chacha20_ietf_xor(
    Uint8List input_message,
    Uint8List nonce,
    Uint8List key,
  );

  external Uint8List crypto_stream_chacha20_ietf_xor_ic(
    Uint8List input_message,
    Uint8List nonce,
    num nonce_increment,
    Uint8List key,
  );

  external Uint8List crypto_stream_chacha20_keygen();

  external Uint8List crypto_stream_chacha20_xor(
    Uint8List input_message,
    Uint8List nonce,
    Uint8List key,
  );

  external Uint8List crypto_stream_chacha20_xor_ic(
    Uint8List input_message,
    Uint8List nonce,
    num nonce_increment,
    Uint8List key,
  );

  external Uint8List crypto_stream_keygen();

  external Uint8List crypto_stream_xchacha20_keygen();

  external Uint8List crypto_stream_xchacha20_xor(
    Uint8List input_message,
    Uint8List nonce,
    Uint8List key,
  );

  external Uint8List crypto_stream_xchacha20_xor_ic(
    Uint8List input_message,
    Uint8List nonce,
    num nonce_increment,
    Uint8List key,
  );

  external Uint8List randombytes_buf(
    num length,
  );

  external Uint8List randombytes_buf_deterministic(
    num length,
    Uint8List seed,
  );

  external void randombytes_close();

  external num randombytes_random();

  external void randombytes_set_implementation(
    Never implementation,
  );

  external void randombytes_stir();

  external num randombytes_uniform(
    num upper_bound,
  );

  external String sodium_version_string();

  external num randombytes_seedbytes();

  external void memzero(Uint8List bytes);

  external Uint8List pad(Uint8List buf, num blocksize);

  external Uint8List unpad(Uint8List buf, num blocksize);
}
