// ignore_for_file: non_constant_identifier_names, public_member_api_docs

import 'dart:js_interop';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';

@JSExport()
abstract class _MockLibSodiumJS {
  int get SODIUM_LIBRARY_VERSION_MAJOR => throw UnimplementedError();

  int get SODIUM_LIBRARY_VERSION_MINOR => throw UnimplementedError();

  String get SODIUM_VERSION_STRING => throw UnimplementedError();

  int get crypto_aead_aegis128l_ABYTES => throw UnimplementedError();

  int get crypto_aead_aegis128l_KEYBYTES => throw UnimplementedError();

  int get crypto_aead_aegis128l_MESSAGEBYTES_MAX => throw UnimplementedError();

  int get crypto_aead_aegis128l_NPUBBYTES => throw UnimplementedError();

  int get crypto_aead_aegis128l_NSECBYTES => throw UnimplementedError();

  int get crypto_aead_aegis256_ABYTES => throw UnimplementedError();

  int get crypto_aead_aegis256_KEYBYTES => throw UnimplementedError();

  int get crypto_aead_aegis256_MESSAGEBYTES_MAX => throw UnimplementedError();

  int get crypto_aead_aegis256_NPUBBYTES => throw UnimplementedError();

  int get crypto_aead_aegis256_NSECBYTES => throw UnimplementedError();

  int get crypto_aead_aes256gcm_ABYTES => throw UnimplementedError();

  int get crypto_aead_aes256gcm_KEYBYTES => throw UnimplementedError();

  int get crypto_aead_aes256gcm_MESSAGEBYTES_MAX => throw UnimplementedError();

  int get crypto_aead_aes256gcm_NPUBBYTES => throw UnimplementedError();

  int get crypto_aead_aes256gcm_NSECBYTES => throw UnimplementedError();

  int get crypto_aead_chacha20poly1305_ABYTES => throw UnimplementedError();

  int get crypto_aead_chacha20poly1305_IETF_ABYTES =>
      throw UnimplementedError();

  int get crypto_aead_chacha20poly1305_IETF_KEYBYTES =>
      throw UnimplementedError();

  int get crypto_aead_chacha20poly1305_IETF_MESSAGEBYTES_MAX =>
      throw UnimplementedError();

  int get crypto_aead_chacha20poly1305_IETF_NPUBBYTES =>
      throw UnimplementedError();

  int get crypto_aead_chacha20poly1305_IETF_NSECBYTES =>
      throw UnimplementedError();

  int get crypto_aead_chacha20poly1305_KEYBYTES => throw UnimplementedError();

  int get crypto_aead_chacha20poly1305_MESSAGEBYTES_MAX =>
      throw UnimplementedError();

  int get crypto_aead_chacha20poly1305_NPUBBYTES => throw UnimplementedError();

  int get crypto_aead_chacha20poly1305_NSECBYTES => throw UnimplementedError();

  int get crypto_aead_chacha20poly1305_ietf_ABYTES =>
      throw UnimplementedError();

  int get crypto_aead_chacha20poly1305_ietf_KEYBYTES =>
      throw UnimplementedError();

  int get crypto_aead_chacha20poly1305_ietf_MESSAGEBYTES_MAX =>
      throw UnimplementedError();

  int get crypto_aead_chacha20poly1305_ietf_NPUBBYTES =>
      throw UnimplementedError();

  int get crypto_aead_chacha20poly1305_ietf_NSECBYTES =>
      throw UnimplementedError();

  int get crypto_aead_xchacha20poly1305_IETF_ABYTES =>
      throw UnimplementedError();

  int get crypto_aead_xchacha20poly1305_IETF_KEYBYTES =>
      throw UnimplementedError();

  int get crypto_aead_xchacha20poly1305_IETF_MESSAGEBYTES_MAX =>
      throw UnimplementedError();

  int get crypto_aead_xchacha20poly1305_IETF_NPUBBYTES =>
      throw UnimplementedError();

  int get crypto_aead_xchacha20poly1305_IETF_NSECBYTES =>
      throw UnimplementedError();

  int get crypto_aead_xchacha20poly1305_ietf_ABYTES =>
      throw UnimplementedError();

  int get crypto_aead_xchacha20poly1305_ietf_KEYBYTES =>
      throw UnimplementedError();

  int get crypto_aead_xchacha20poly1305_ietf_MESSAGEBYTES_MAX =>
      throw UnimplementedError();

  int get crypto_aead_xchacha20poly1305_ietf_NPUBBYTES =>
      throw UnimplementedError();

  int get crypto_aead_xchacha20poly1305_ietf_NSECBYTES =>
      throw UnimplementedError();

  int get crypto_auth_BYTES => throw UnimplementedError();

  int get crypto_auth_KEYBYTES => throw UnimplementedError();

  int get crypto_auth_hmacsha256_BYTES => throw UnimplementedError();

  int get crypto_auth_hmacsha256_KEYBYTES => throw UnimplementedError();

  int get crypto_auth_hmacsha512256_BYTES => throw UnimplementedError();

  int get crypto_auth_hmacsha512256_KEYBYTES => throw UnimplementedError();

  int get crypto_auth_hmacsha512_BYTES => throw UnimplementedError();

  int get crypto_auth_hmacsha512_KEYBYTES => throw UnimplementedError();

  int get crypto_box_BEFORENMBYTES => throw UnimplementedError();

  int get crypto_box_MACBYTES => throw UnimplementedError();

  int get crypto_box_MESSAGEBYTES_MAX => throw UnimplementedError();

  int get crypto_box_NONCEBYTES => throw UnimplementedError();

  int get crypto_box_PUBLICKEYBYTES => throw UnimplementedError();

  int get crypto_box_SEALBYTES => throw UnimplementedError();

  int get crypto_box_SECRETKEYBYTES => throw UnimplementedError();

  int get crypto_box_SEEDBYTES => throw UnimplementedError();

  int get crypto_box_curve25519xchacha20poly1305_BEFORENMBYTES =>
      throw UnimplementedError();

  int get crypto_box_curve25519xchacha20poly1305_MACBYTES =>
      throw UnimplementedError();

  int get crypto_box_curve25519xchacha20poly1305_MESSAGEBYTES_MAX =>
      throw UnimplementedError();

  int get crypto_box_curve25519xchacha20poly1305_NONCEBYTES =>
      throw UnimplementedError();

  int get crypto_box_curve25519xchacha20poly1305_PUBLICKEYBYTES =>
      throw UnimplementedError();

  int get crypto_box_curve25519xchacha20poly1305_SEALBYTES =>
      throw UnimplementedError();

  int get crypto_box_curve25519xchacha20poly1305_SECRETKEYBYTES =>
      throw UnimplementedError();

  int get crypto_box_curve25519xchacha20poly1305_SEEDBYTES =>
      throw UnimplementedError();

  int get crypto_box_curve25519xsalsa20poly1305_BEFORENMBYTES =>
      throw UnimplementedError();

  int get crypto_box_curve25519xsalsa20poly1305_MACBYTES =>
      throw UnimplementedError();

  int get crypto_box_curve25519xsalsa20poly1305_MESSAGEBYTES_MAX =>
      throw UnimplementedError();

  int get crypto_box_curve25519xsalsa20poly1305_NONCEBYTES =>
      throw UnimplementedError();

  int get crypto_box_curve25519xsalsa20poly1305_PUBLICKEYBYTES =>
      throw UnimplementedError();

  int get crypto_box_curve25519xsalsa20poly1305_SECRETKEYBYTES =>
      throw UnimplementedError();

  int get crypto_box_curve25519xsalsa20poly1305_SEEDBYTES =>
      throw UnimplementedError();

  int get crypto_core_ed25519_BYTES => throw UnimplementedError();

  int get crypto_core_ed25519_HASHBYTES => throw UnimplementedError();

  int get crypto_core_ed25519_NONREDUCEDSCALARBYTES =>
      throw UnimplementedError();

  int get crypto_core_ed25519_SCALARBYTES => throw UnimplementedError();

  int get crypto_core_ed25519_UNIFORMBYTES => throw UnimplementedError();

  int get crypto_core_hchacha20_CONSTBYTES => throw UnimplementedError();

  int get crypto_core_hchacha20_INPUTBYTES => throw UnimplementedError();

  int get crypto_core_hchacha20_KEYBYTES => throw UnimplementedError();

  int get crypto_core_hchacha20_OUTPUTBYTES => throw UnimplementedError();

  int get crypto_core_hsalsa20_CONSTBYTES => throw UnimplementedError();

  int get crypto_core_hsalsa20_INPUTBYTES => throw UnimplementedError();

  int get crypto_core_hsalsa20_KEYBYTES => throw UnimplementedError();

  int get crypto_core_hsalsa20_OUTPUTBYTES => throw UnimplementedError();

  int get crypto_core_ristretto255_BYTES => throw UnimplementedError();

  int get crypto_core_ristretto255_HASHBYTES => throw UnimplementedError();

  int get crypto_core_ristretto255_NONREDUCEDSCALARBYTES =>
      throw UnimplementedError();

  int get crypto_core_ristretto255_SCALARBYTES => throw UnimplementedError();

  int get crypto_core_salsa2012_CONSTBYTES => throw UnimplementedError();

  int get crypto_core_salsa2012_INPUTBYTES => throw UnimplementedError();

  int get crypto_core_salsa2012_KEYBYTES => throw UnimplementedError();

  int get crypto_core_salsa2012_OUTPUTBYTES => throw UnimplementedError();

  int get crypto_core_salsa208_CONSTBYTES => throw UnimplementedError();

  int get crypto_core_salsa208_INPUTBYTES => throw UnimplementedError();

  int get crypto_core_salsa208_KEYBYTES => throw UnimplementedError();

  int get crypto_core_salsa208_OUTPUTBYTES => throw UnimplementedError();

  int get crypto_core_salsa20_CONSTBYTES => throw UnimplementedError();

  int get crypto_core_salsa20_INPUTBYTES => throw UnimplementedError();

  int get crypto_core_salsa20_KEYBYTES => throw UnimplementedError();

  int get crypto_core_salsa20_OUTPUTBYTES => throw UnimplementedError();

  int get crypto_generichash_BYTES => throw UnimplementedError();

  int get crypto_generichash_BYTES_MAX => throw UnimplementedError();

  int get crypto_generichash_BYTES_MIN => throw UnimplementedError();

  int get crypto_generichash_KEYBYTES => throw UnimplementedError();

  int get crypto_generichash_KEYBYTES_MAX => throw UnimplementedError();

  int get crypto_generichash_KEYBYTES_MIN => throw UnimplementedError();

  int get crypto_generichash_blake2b_BYTES => throw UnimplementedError();

  int get crypto_generichash_blake2b_BYTES_MAX => throw UnimplementedError();

  int get crypto_generichash_blake2b_BYTES_MIN => throw UnimplementedError();

  int get crypto_generichash_blake2b_KEYBYTES => throw UnimplementedError();

  int get crypto_generichash_blake2b_KEYBYTES_MAX => throw UnimplementedError();

  int get crypto_generichash_blake2b_KEYBYTES_MIN => throw UnimplementedError();

  int get crypto_generichash_blake2b_PERSONALBYTES =>
      throw UnimplementedError();

  int get crypto_generichash_blake2b_SALTBYTES => throw UnimplementedError();

  int get crypto_hash_BYTES => throw UnimplementedError();

  int get crypto_hash_sha256_BYTES => throw UnimplementedError();

  int get crypto_hash_sha512_BYTES => throw UnimplementedError();

  int get crypto_kdf_BYTES_MAX => throw UnimplementedError();

  int get crypto_kdf_BYTES_MIN => throw UnimplementedError();

  int get crypto_kdf_CONTEXTBYTES => throw UnimplementedError();

  int get crypto_kdf_KEYBYTES => throw UnimplementedError();

  int get crypto_kdf_blake2b_BYTES_MAX => throw UnimplementedError();

  int get crypto_kdf_blake2b_BYTES_MIN => throw UnimplementedError();

  int get crypto_kdf_blake2b_CONTEXTBYTES => throw UnimplementedError();

  int get crypto_kdf_blake2b_KEYBYTES => throw UnimplementedError();

  int get crypto_kdf_hkdf_sha256_BYTES_MAX => throw UnimplementedError();

  int get crypto_kdf_hkdf_sha256_BYTES_MIN => throw UnimplementedError();

  int get crypto_kdf_hkdf_sha256_KEYBYTES => throw UnimplementedError();

  int get crypto_kdf_hkdf_sha512_BYTES_MAX => throw UnimplementedError();

  int get crypto_kdf_hkdf_sha512_BYTES_MIN => throw UnimplementedError();

  int get crypto_kdf_hkdf_sha512_KEYBYTES => throw UnimplementedError();

  int get crypto_kx_PUBLICKEYBYTES => throw UnimplementedError();

  int get crypto_kx_SECRETKEYBYTES => throw UnimplementedError();

  int get crypto_kx_SEEDBYTES => throw UnimplementedError();

  int get crypto_kx_SESSIONKEYBYTES => throw UnimplementedError();

  int get crypto_onetimeauth_BYTES => throw UnimplementedError();

  int get crypto_onetimeauth_KEYBYTES => throw UnimplementedError();

  int get crypto_onetimeauth_poly1305_BYTES => throw UnimplementedError();

  int get crypto_onetimeauth_poly1305_KEYBYTES => throw UnimplementedError();

  int get crypto_pwhash_ALG_ARGON2I13 => throw UnimplementedError();

  int get crypto_pwhash_ALG_ARGON2ID13 => throw UnimplementedError();

  int get crypto_pwhash_ALG_DEFAULT => throw UnimplementedError();

  int get crypto_pwhash_BYTES_MAX => throw UnimplementedError();

  int get crypto_pwhash_BYTES_MIN => throw UnimplementedError();

  int get crypto_pwhash_MEMLIMIT_INTERACTIVE => throw UnimplementedError();

  int get crypto_pwhash_MEMLIMIT_MAX => throw UnimplementedError();

  int get crypto_pwhash_MEMLIMIT_MIN => throw UnimplementedError();

  int get crypto_pwhash_MEMLIMIT_MODERATE => throw UnimplementedError();

  int get crypto_pwhash_MEMLIMIT_SENSITIVE => throw UnimplementedError();

  int get crypto_pwhash_OPSLIMIT_INTERACTIVE => throw UnimplementedError();

  int get crypto_pwhash_OPSLIMIT_MAX => throw UnimplementedError();

  int get crypto_pwhash_OPSLIMIT_MIN => throw UnimplementedError();

  int get crypto_pwhash_OPSLIMIT_MODERATE => throw UnimplementedError();

  int get crypto_pwhash_OPSLIMIT_SENSITIVE => throw UnimplementedError();

  int get crypto_pwhash_PASSWD_MAX => throw UnimplementedError();

  int get crypto_pwhash_PASSWD_MIN => throw UnimplementedError();

  int get crypto_pwhash_SALTBYTES => throw UnimplementedError();

  int get crypto_pwhash_STRBYTES => throw UnimplementedError();

  String get crypto_pwhash_STRPREFIX => throw UnimplementedError();

  int get crypto_pwhash_argon2i_BYTES_MAX => throw UnimplementedError();

  int get crypto_pwhash_argon2i_BYTES_MIN => throw UnimplementedError();

  int get crypto_pwhash_argon2i_MEMLIMIT_INTERACTIVE =>
      throw UnimplementedError();

  int get crypto_pwhash_argon2i_MEMLIMIT_MAX => throw UnimplementedError();

  int get crypto_pwhash_argon2i_MEMLIMIT_MIN => throw UnimplementedError();

  int get crypto_pwhash_argon2i_MEMLIMIT_MODERATE => throw UnimplementedError();

  int get crypto_pwhash_argon2i_MEMLIMIT_SENSITIVE =>
      throw UnimplementedError();

  int get crypto_pwhash_argon2i_OPSLIMIT_INTERACTIVE =>
      throw UnimplementedError();

  int get crypto_pwhash_argon2i_OPSLIMIT_MAX => throw UnimplementedError();

  int get crypto_pwhash_argon2i_OPSLIMIT_MIN => throw UnimplementedError();

  int get crypto_pwhash_argon2i_OPSLIMIT_MODERATE => throw UnimplementedError();

  int get crypto_pwhash_argon2i_OPSLIMIT_SENSITIVE =>
      throw UnimplementedError();

  int get crypto_pwhash_argon2i_PASSWD_MAX => throw UnimplementedError();

  int get crypto_pwhash_argon2i_PASSWD_MIN => throw UnimplementedError();

  int get crypto_pwhash_argon2i_SALTBYTES => throw UnimplementedError();

  int get crypto_pwhash_argon2i_STRBYTES => throw UnimplementedError();

  String get crypto_pwhash_argon2i_STRPREFIX => throw UnimplementedError();

  int get crypto_pwhash_argon2id_BYTES_MAX => throw UnimplementedError();

  int get crypto_pwhash_argon2id_BYTES_MIN => throw UnimplementedError();

  int get crypto_pwhash_argon2id_MEMLIMIT_INTERACTIVE =>
      throw UnimplementedError();

  int get crypto_pwhash_argon2id_MEMLIMIT_MAX => throw UnimplementedError();

  int get crypto_pwhash_argon2id_MEMLIMIT_MIN => throw UnimplementedError();

  int get crypto_pwhash_argon2id_MEMLIMIT_MODERATE =>
      throw UnimplementedError();

  int get crypto_pwhash_argon2id_MEMLIMIT_SENSITIVE =>
      throw UnimplementedError();

  int get crypto_pwhash_argon2id_OPSLIMIT_INTERACTIVE =>
      throw UnimplementedError();

  int get crypto_pwhash_argon2id_OPSLIMIT_MAX => throw UnimplementedError();

  int get crypto_pwhash_argon2id_OPSLIMIT_MIN => throw UnimplementedError();

  int get crypto_pwhash_argon2id_OPSLIMIT_MODERATE =>
      throw UnimplementedError();

  int get crypto_pwhash_argon2id_OPSLIMIT_SENSITIVE =>
      throw UnimplementedError();

  int get crypto_pwhash_argon2id_PASSWD_MAX => throw UnimplementedError();

  int get crypto_pwhash_argon2id_PASSWD_MIN => throw UnimplementedError();

  int get crypto_pwhash_argon2id_SALTBYTES => throw UnimplementedError();

  int get crypto_pwhash_argon2id_STRBYTES => throw UnimplementedError();

  String get crypto_pwhash_argon2id_STRPREFIX => throw UnimplementedError();

  int get crypto_pwhash_scryptsalsa208sha256_BYTES_MAX =>
      throw UnimplementedError();

  int get crypto_pwhash_scryptsalsa208sha256_BYTES_MIN =>
      throw UnimplementedError();

  int get crypto_pwhash_scryptsalsa208sha256_MEMLIMIT_INTERACTIVE =>
      throw UnimplementedError();

  int get crypto_pwhash_scryptsalsa208sha256_MEMLIMIT_MAX =>
      throw UnimplementedError();

  int get crypto_pwhash_scryptsalsa208sha256_MEMLIMIT_MIN =>
      throw UnimplementedError();

  int get crypto_pwhash_scryptsalsa208sha256_MEMLIMIT_SENSITIVE =>
      throw UnimplementedError();

  int get crypto_pwhash_scryptsalsa208sha256_OPSLIMIT_INTERACTIVE =>
      throw UnimplementedError();

  int get crypto_pwhash_scryptsalsa208sha256_OPSLIMIT_MAX =>
      throw UnimplementedError();

  int get crypto_pwhash_scryptsalsa208sha256_OPSLIMIT_MIN =>
      throw UnimplementedError();

  int get crypto_pwhash_scryptsalsa208sha256_OPSLIMIT_SENSITIVE =>
      throw UnimplementedError();

  int get crypto_pwhash_scryptsalsa208sha256_PASSWD_MAX =>
      throw UnimplementedError();

  int get crypto_pwhash_scryptsalsa208sha256_PASSWD_MIN =>
      throw UnimplementedError();

  int get crypto_pwhash_scryptsalsa208sha256_SALTBYTES =>
      throw UnimplementedError();

  int get crypto_pwhash_scryptsalsa208sha256_STRBYTES =>
      throw UnimplementedError();

  String get crypto_pwhash_scryptsalsa208sha256_STRPREFIX =>
      throw UnimplementedError();

  int get crypto_scalarmult_BYTES => throw UnimplementedError();

  int get crypto_scalarmult_SCALARBYTES => throw UnimplementedError();

  int get crypto_scalarmult_curve25519_BYTES => throw UnimplementedError();

  int get crypto_scalarmult_curve25519_SCALARBYTES =>
      throw UnimplementedError();

  int get crypto_scalarmult_ed25519_BYTES => throw UnimplementedError();

  int get crypto_scalarmult_ed25519_SCALARBYTES => throw UnimplementedError();

  int get crypto_scalarmult_ristretto255_BYTES => throw UnimplementedError();

  int get crypto_scalarmult_ristretto255_SCALARBYTES =>
      throw UnimplementedError();

  int get crypto_secretbox_KEYBYTES => throw UnimplementedError();

  int get crypto_secretbox_MACBYTES => throw UnimplementedError();

  int get crypto_secretbox_MESSAGEBYTES_MAX => throw UnimplementedError();

  int get crypto_secretbox_NONCEBYTES => throw UnimplementedError();

  int get crypto_secretbox_xchacha20poly1305_KEYBYTES =>
      throw UnimplementedError();

  int get crypto_secretbox_xchacha20poly1305_MACBYTES =>
      throw UnimplementedError();

  int get crypto_secretbox_xchacha20poly1305_MESSAGEBYTES_MAX =>
      throw UnimplementedError();

  int get crypto_secretbox_xchacha20poly1305_NONCEBYTES =>
      throw UnimplementedError();

  int get crypto_secretbox_xsalsa20poly1305_KEYBYTES =>
      throw UnimplementedError();

  int get crypto_secretbox_xsalsa20poly1305_MACBYTES =>
      throw UnimplementedError();

  int get crypto_secretbox_xsalsa20poly1305_MESSAGEBYTES_MAX =>
      throw UnimplementedError();

  int get crypto_secretbox_xsalsa20poly1305_NONCEBYTES =>
      throw UnimplementedError();

  int get crypto_secretstream_xchacha20poly1305_ABYTES =>
      throw UnimplementedError();

  int get crypto_secretstream_xchacha20poly1305_HEADERBYTES =>
      throw UnimplementedError();

  int get crypto_secretstream_xchacha20poly1305_KEYBYTES =>
      throw UnimplementedError();

  int get crypto_secretstream_xchacha20poly1305_MESSAGEBYTES_MAX =>
      throw UnimplementedError();

  int get crypto_secretstream_xchacha20poly1305_TAG_FINAL =>
      throw UnimplementedError();

  int get crypto_secretstream_xchacha20poly1305_TAG_MESSAGE =>
      throw UnimplementedError();

  int get crypto_secretstream_xchacha20poly1305_TAG_PUSH =>
      throw UnimplementedError();

  int get crypto_secretstream_xchacha20poly1305_TAG_REKEY =>
      throw UnimplementedError();

  int get crypto_shorthash_BYTES => throw UnimplementedError();

  int get crypto_shorthash_KEYBYTES => throw UnimplementedError();

  int get crypto_shorthash_siphash24_BYTES => throw UnimplementedError();

  int get crypto_shorthash_siphash24_KEYBYTES => throw UnimplementedError();

  int get crypto_shorthash_siphashx24_BYTES => throw UnimplementedError();

  int get crypto_shorthash_siphashx24_KEYBYTES => throw UnimplementedError();

  int get crypto_sign_BYTES => throw UnimplementedError();

  int get crypto_sign_MESSAGEBYTES_MAX => throw UnimplementedError();

  int get crypto_sign_PUBLICKEYBYTES => throw UnimplementedError();

  int get crypto_sign_SECRETKEYBYTES => throw UnimplementedError();

  int get crypto_sign_SEEDBYTES => throw UnimplementedError();

  int get crypto_sign_ed25519_BYTES => throw UnimplementedError();

  int get crypto_sign_ed25519_MESSAGEBYTES_MAX => throw UnimplementedError();

  int get crypto_sign_ed25519_PUBLICKEYBYTES => throw UnimplementedError();

  int get crypto_sign_ed25519_SECRETKEYBYTES => throw UnimplementedError();

  int get crypto_sign_ed25519_SEEDBYTES => throw UnimplementedError();

  int get crypto_stream_KEYBYTES => throw UnimplementedError();

  int get crypto_stream_MESSAGEBYTES_MAX => throw UnimplementedError();

  int get crypto_stream_NONCEBYTES => throw UnimplementedError();

  int get crypto_stream_chacha20_IETF_KEYBYTES => throw UnimplementedError();

  int get crypto_stream_chacha20_IETF_MESSAGEBYTES_MAX =>
      throw UnimplementedError();

  int get crypto_stream_chacha20_IETF_NONCEBYTES => throw UnimplementedError();

  int get crypto_stream_chacha20_KEYBYTES => throw UnimplementedError();

  int get crypto_stream_chacha20_MESSAGEBYTES_MAX => throw UnimplementedError();

  int get crypto_stream_chacha20_NONCEBYTES => throw UnimplementedError();

  int get crypto_stream_chacha20_ietf_KEYBYTES => throw UnimplementedError();

  int get crypto_stream_chacha20_ietf_MESSAGEBYTES_MAX =>
      throw UnimplementedError();

  int get crypto_stream_chacha20_ietf_NONCEBYTES => throw UnimplementedError();

  int get crypto_stream_salsa2012_KEYBYTES => throw UnimplementedError();

  int get crypto_stream_salsa2012_MESSAGEBYTES_MAX =>
      throw UnimplementedError();

  int get crypto_stream_salsa2012_NONCEBYTES => throw UnimplementedError();

  int get crypto_stream_salsa208_KEYBYTES => throw UnimplementedError();

  int get crypto_stream_salsa208_MESSAGEBYTES_MAX => throw UnimplementedError();

  int get crypto_stream_salsa208_NONCEBYTES => throw UnimplementedError();

  int get crypto_stream_salsa20_KEYBYTES => throw UnimplementedError();

  int get crypto_stream_salsa20_MESSAGEBYTES_MAX => throw UnimplementedError();

  int get crypto_stream_salsa20_NONCEBYTES => throw UnimplementedError();

  int get crypto_stream_xchacha20_KEYBYTES => throw UnimplementedError();

  int get crypto_stream_xchacha20_MESSAGEBYTES_MAX =>
      throw UnimplementedError();

  int get crypto_stream_xchacha20_NONCEBYTES => throw UnimplementedError();

  int get crypto_stream_xsalsa20_KEYBYTES => throw UnimplementedError();

  int get crypto_stream_xsalsa20_MESSAGEBYTES_MAX => throw UnimplementedError();

  int get crypto_stream_xsalsa20_NONCEBYTES => throw UnimplementedError();

  int get crypto_verify_16_BYTES => throw UnimplementedError();

  int get crypto_verify_32_BYTES => throw UnimplementedError();

  int get crypto_verify_64_BYTES => throw UnimplementedError();

  JSUint8Array crypto_aead_aegis128l_decrypt(
    JSUint8Array? secret_nonce,
    JSUint8Array ciphertext,
    JSUint8Array? additional_data,
    JSUint8Array public_nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_aead_aegis128l_decrypt_detached(
    JSUint8Array? secret_nonce,
    JSUint8Array ciphertext,
    JSUint8Array mac,
    JSUint8Array? additional_data,
    JSUint8Array public_nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_aead_aegis128l_encrypt(
    JSUint8Array message,
    JSUint8Array? additional_data,
    JSUint8Array? secret_nonce,
    JSUint8Array public_nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  CryptoBox crypto_aead_aegis128l_encrypt_detached(
    JSUint8Array message,
    JSUint8Array? additional_data,
    JSUint8Array? secret_nonce,
    JSUint8Array public_nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_aead_aegis128l_keygen() => throw UnimplementedError();

  JSUint8Array crypto_aead_aegis256_decrypt(
    JSUint8Array? secret_nonce,
    JSUint8Array ciphertext,
    JSUint8Array? additional_data,
    JSUint8Array public_nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_aead_aegis256_decrypt_detached(
    JSUint8Array? secret_nonce,
    JSUint8Array ciphertext,
    JSUint8Array mac,
    JSUint8Array? additional_data,
    JSUint8Array public_nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_aead_aegis256_encrypt(
    JSUint8Array message,
    JSUint8Array? additional_data,
    JSUint8Array? secret_nonce,
    JSUint8Array public_nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  CryptoBox crypto_aead_aegis256_encrypt_detached(
    JSUint8Array message,
    JSUint8Array? additional_data,
    JSUint8Array? secret_nonce,
    JSUint8Array public_nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_aead_aegis256_keygen() => throw UnimplementedError();

  JSUint8Array crypto_aead_chacha20poly1305_decrypt(
    JSUint8Array? secret_nonce,
    JSUint8Array ciphertext,
    JSUint8Array? additional_data,
    JSUint8Array public_nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_aead_chacha20poly1305_decrypt_detached(
    JSUint8Array? secret_nonce,
    JSUint8Array ciphertext,
    JSUint8Array mac,
    JSUint8Array? additional_data,
    JSUint8Array public_nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_aead_chacha20poly1305_encrypt(
    JSUint8Array message,
    JSUint8Array? additional_data,
    JSUint8Array? secret_nonce,
    JSUint8Array public_nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  CryptoBox crypto_aead_chacha20poly1305_encrypt_detached(
    JSUint8Array message,
    JSUint8Array? additional_data,
    JSUint8Array? secret_nonce,
    JSUint8Array public_nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_aead_chacha20poly1305_ietf_decrypt(
    JSUint8Array? secret_nonce,
    JSUint8Array ciphertext,
    JSUint8Array? additional_data,
    JSUint8Array public_nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_aead_chacha20poly1305_ietf_decrypt_detached(
    JSUint8Array? secret_nonce,
    JSUint8Array ciphertext,
    JSUint8Array mac,
    JSUint8Array? additional_data,
    JSUint8Array public_nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_aead_chacha20poly1305_ietf_encrypt(
    JSUint8Array message,
    JSUint8Array? additional_data,
    JSUint8Array? secret_nonce,
    JSUint8Array public_nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  CryptoBox crypto_aead_chacha20poly1305_ietf_encrypt_detached(
    JSUint8Array message,
    JSUint8Array? additional_data,
    JSUint8Array? secret_nonce,
    JSUint8Array public_nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_aead_chacha20poly1305_ietf_keygen() =>
      throw UnimplementedError();

  JSUint8Array crypto_aead_chacha20poly1305_keygen() =>
      throw UnimplementedError();

  JSUint8Array crypto_aead_xchacha20poly1305_ietf_decrypt(
    JSUint8Array? secret_nonce,
    JSUint8Array ciphertext,
    JSUint8Array? additional_data,
    JSUint8Array public_nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_aead_xchacha20poly1305_ietf_decrypt_detached(
    JSUint8Array? secret_nonce,
    JSUint8Array ciphertext,
    JSUint8Array mac,
    JSUint8Array? additional_data,
    JSUint8Array public_nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_aead_xchacha20poly1305_ietf_encrypt(
    JSUint8Array message,
    JSUint8Array? additional_data,
    JSUint8Array? secret_nonce,
    JSUint8Array public_nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  CryptoBox crypto_aead_xchacha20poly1305_ietf_encrypt_detached(
    JSUint8Array message,
    JSUint8Array? additional_data,
    JSUint8Array? secret_nonce,
    JSUint8Array public_nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_aead_xchacha20poly1305_ietf_keygen() =>
      throw UnimplementedError();

  JSUint8Array crypto_auth(
    JSUint8Array message,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_auth_hmacsha256(
    JSUint8Array message,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_auth_hmacsha256_final(
    AuthHmacsha256State state_address,
  ) =>
      throw UnimplementedError();

  AuthHmacsha256State crypto_auth_hmacsha256_init(JSUint8Array? key) =>
      throw UnimplementedError();

  JSUint8Array crypto_auth_hmacsha256_keygen() => throw UnimplementedError();

  void crypto_auth_hmacsha256_update(
    AuthHmacsha256State state_address,
    JSUint8Array message_chunk,
  ) =>
      throw UnimplementedError();

  bool crypto_auth_hmacsha256_verify(
    JSUint8Array tag,
    JSUint8Array message,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_auth_hmacsha512(
    JSUint8Array message,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_auth_hmacsha512256(
    JSUint8Array message,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_auth_hmacsha512256_final(
    AuthHmacsha512256State state_address,
  ) =>
      throw UnimplementedError();

  AuthHmacsha512256State crypto_auth_hmacsha512256_init(JSUint8Array? key) =>
      throw UnimplementedError();

  JSUint8Array crypto_auth_hmacsha512256_keygen() => throw UnimplementedError();

  void crypto_auth_hmacsha512256_update(
    AuthHmacsha512256State state_address,
    JSUint8Array message_chunk,
  ) =>
      throw UnimplementedError();

  bool crypto_auth_hmacsha512256_verify(
    JSUint8Array tag,
    JSUint8Array message,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_auth_hmacsha512_final(
    AuthHmacsha512State state_address,
  ) =>
      throw UnimplementedError();

  AuthHmacsha512State crypto_auth_hmacsha512_init(JSUint8Array? key) =>
      throw UnimplementedError();

  JSUint8Array crypto_auth_hmacsha512_keygen() => throw UnimplementedError();

  void crypto_auth_hmacsha512_update(
    AuthHmacsha512State state_address,
    JSUint8Array message_chunk,
  ) =>
      throw UnimplementedError();

  bool crypto_auth_hmacsha512_verify(
    JSUint8Array tag,
    JSUint8Array message,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_auth_keygen() => throw UnimplementedError();

  bool crypto_auth_verify(
    JSUint8Array tag,
    JSUint8Array message,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_box_beforenm(
    JSUint8Array publicKey,
    JSUint8Array privateKey,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_box_curve25519xchacha20poly1305_beforenm(
    JSUint8Array publicKey,
    JSUint8Array privateKey,
  ) =>
      throw UnimplementedError();

  CryptoBox crypto_box_curve25519xchacha20poly1305_detached(
    JSUint8Array message,
    JSUint8Array nonce,
    JSUint8Array publicKey,
    JSUint8Array privateKey,
  ) =>
      throw UnimplementedError();

  CryptoBox crypto_box_curve25519xchacha20poly1305_detached_afternm(
    JSUint8Array message,
    JSUint8Array nonce,
    JSUint8Array sharedKey,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_box_curve25519xchacha20poly1305_easy(
    JSUint8Array message,
    JSUint8Array nonce,
    JSUint8Array publicKey,
    JSUint8Array privateKey,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_box_curve25519xchacha20poly1305_easy_afternm(
    JSUint8Array message,
    JSUint8Array nonce,
    JSUint8Array sharedKey,
  ) =>
      throw UnimplementedError();

  KeyPair crypto_box_curve25519xchacha20poly1305_keypair() =>
      throw UnimplementedError();

  JSUint8Array crypto_box_curve25519xchacha20poly1305_open_detached(
    JSUint8Array ciphertext,
    JSUint8Array mac,
    JSUint8Array nonce,
    JSUint8Array publicKey,
    JSUint8Array privateKey,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_box_curve25519xchacha20poly1305_open_detached_afternm(
    JSUint8Array ciphertext,
    JSUint8Array mac,
    JSUint8Array nonce,
    JSUint8Array sharedKey,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_box_curve25519xchacha20poly1305_open_easy(
    JSUint8Array ciphertext,
    JSUint8Array nonce,
    JSUint8Array publicKey,
    JSUint8Array privateKey,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_box_curve25519xchacha20poly1305_open_easy_afternm(
    JSUint8Array ciphertext,
    JSUint8Array nonce,
    JSUint8Array sharedKey,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_box_curve25519xchacha20poly1305_seal(
    JSUint8Array message,
    JSUint8Array publicKey,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_box_curve25519xchacha20poly1305_seal_open(
    JSUint8Array ciphertext,
    JSUint8Array publicKey,
    JSUint8Array secretKey,
  ) =>
      throw UnimplementedError();

  KeyPair crypto_box_curve25519xchacha20poly1305_seed_keypair(
    JSUint8Array seed,
  ) =>
      throw UnimplementedError();

  CryptoBox crypto_box_detached(
    JSUint8Array message,
    JSUint8Array nonce,
    JSUint8Array publicKey,
    JSUint8Array privateKey,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_box_easy(
    JSUint8Array message,
    JSUint8Array nonce,
    JSUint8Array publicKey,
    JSUint8Array privateKey,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_box_easy_afternm(
    JSUint8Array message,
    JSUint8Array nonce,
    JSUint8Array sharedKey,
  ) =>
      throw UnimplementedError();

  KeyPair crypto_box_keypair() => throw UnimplementedError();

  JSUint8Array crypto_box_open_detached(
    JSUint8Array ciphertext,
    JSUint8Array mac,
    JSUint8Array nonce,
    JSUint8Array publicKey,
    JSUint8Array privateKey,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_box_open_easy(
    JSUint8Array ciphertext,
    JSUint8Array nonce,
    JSUint8Array publicKey,
    JSUint8Array privateKey,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_box_open_easy_afternm(
    JSUint8Array ciphertext,
    JSUint8Array nonce,
    JSUint8Array sharedKey,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_box_seal(
    JSUint8Array message,
    JSUint8Array publicKey,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_box_seal_open(
    JSUint8Array ciphertext,
    JSUint8Array publicKey,
    JSUint8Array privateKey,
  ) =>
      throw UnimplementedError();

  KeyPair crypto_box_seed_keypair(JSUint8Array seed) =>
      throw UnimplementedError();

  JSUint8Array crypto_core_ed25519_add(
    JSUint8Array p,
    JSUint8Array q,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_core_ed25519_from_hash(JSUint8Array r) =>
      throw UnimplementedError();

  JSUint8Array crypto_core_ed25519_from_uniform(JSUint8Array r) =>
      throw UnimplementedError();

  bool crypto_core_ed25519_is_valid_point(JSUint8Array repr) =>
      throw UnimplementedError();

  JSUint8Array crypto_core_ed25519_random() => throw UnimplementedError();

  JSUint8Array crypto_core_ed25519_scalar_add(
    JSUint8Array x,
    JSUint8Array y,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_core_ed25519_scalar_complement(JSUint8Array s) =>
      throw UnimplementedError();

  JSUint8Array crypto_core_ed25519_scalar_invert(JSUint8Array s) =>
      throw UnimplementedError();

  JSUint8Array crypto_core_ed25519_scalar_mul(
    JSUint8Array x,
    JSUint8Array y,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_core_ed25519_scalar_negate(JSUint8Array s) =>
      throw UnimplementedError();

  JSUint8Array crypto_core_ed25519_scalar_random() =>
      throw UnimplementedError();

  JSUint8Array crypto_core_ed25519_scalar_reduce(JSUint8Array sample) =>
      throw UnimplementedError();

  JSUint8Array crypto_core_ed25519_scalar_sub(
    JSUint8Array x,
    JSUint8Array y,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_core_ed25519_sub(
    JSUint8Array p,
    JSUint8Array q,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_core_hchacha20(
    JSUint8Array input,
    JSUint8Array privateKey,
    JSUint8Array? constant,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_core_hsalsa20(
    JSUint8Array input,
    JSUint8Array privateKey,
    JSUint8Array? constant,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_core_ristretto255_add(
    JSUint8Array p,
    JSUint8Array q,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_core_ristretto255_from_hash(JSUint8Array r) =>
      throw UnimplementedError();

  bool crypto_core_ristretto255_is_valid_point(JSUint8Array repr) =>
      throw UnimplementedError();

  JSUint8Array crypto_core_ristretto255_random() => throw UnimplementedError();

  JSUint8Array crypto_core_ristretto255_scalar_add(
    JSUint8Array x,
    JSUint8Array y,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_core_ristretto255_scalar_complement(JSUint8Array s) =>
      throw UnimplementedError();

  JSUint8Array crypto_core_ristretto255_scalar_invert(JSUint8Array s) =>
      throw UnimplementedError();

  JSUint8Array crypto_core_ristretto255_scalar_mul(
    JSUint8Array x,
    JSUint8Array y,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_core_ristretto255_scalar_negate(JSUint8Array s) =>
      throw UnimplementedError();

  JSUint8Array crypto_core_ristretto255_scalar_random() =>
      throw UnimplementedError();

  JSUint8Array crypto_core_ristretto255_scalar_reduce(JSUint8Array sample) =>
      throw UnimplementedError();

  JSUint8Array crypto_core_ristretto255_scalar_sub(
    JSUint8Array x,
    JSUint8Array y,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_core_ristretto255_sub(
    JSUint8Array p,
    JSUint8Array q,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_generichash(
    int hash_length,
    JSUint8Array message,
    JSUint8Array? key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_generichash_blake2b_salt_personal(
    int subkey_len,
    JSUint8Array? key,
    JSUint8Array? id,
    JSUint8Array? ctx,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_generichash_final(
    GenerichashState state_address,
    int hash_length,
  ) =>
      throw UnimplementedError();

  GenerichashState crypto_generichash_init(
    JSUint8Array? key,
    int hash_length,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_generichash_keygen() => throw UnimplementedError();

  void crypto_generichash_update(
    GenerichashState state_address,
    JSUint8Array message_chunk,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_hash(JSUint8Array message) => throw UnimplementedError();

  JSUint8Array crypto_hash_sha256(JSUint8Array message) =>
      throw UnimplementedError();

  JSUint8Array crypto_hash_sha256_final(HashSha256State state_address) =>
      throw UnimplementedError();

  HashSha256State crypto_hash_sha256_init() => throw UnimplementedError();

  void crypto_hash_sha256_update(
    HashSha256State state_address,
    JSUint8Array message_chunk,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_hash_sha512(JSUint8Array message) =>
      throw UnimplementedError();

  JSUint8Array crypto_hash_sha512_final(HashSha512State state_address) =>
      throw UnimplementedError();

  HashSha512State crypto_hash_sha512_init() => throw UnimplementedError();

  void crypto_hash_sha512_update(
    HashSha512State state_address,
    JSUint8Array message_chunk,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_kdf_derive_from_key(
    int subkey_len,
    JSBigInt subkey_id,
    String ctx,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_kdf_keygen() => throw UnimplementedError();

  CryptoKX crypto_kx_client_session_keys(
    JSUint8Array clientPublicKey,
    JSUint8Array clientSecretKey,
    JSUint8Array serverPublicKey,
  ) =>
      throw UnimplementedError();

  KeyPair crypto_kx_keypair() => throw UnimplementedError();

  KeyPair crypto_kx_seed_keypair(JSUint8Array seed) =>
      throw UnimplementedError();

  CryptoKX crypto_kx_server_session_keys(
    JSUint8Array serverPublicKey,
    JSUint8Array serverSecretKey,
    JSUint8Array clientPublicKey,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_onetimeauth(
    JSUint8Array message,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_onetimeauth_final(OnetimeauthState state_address) =>
      throw UnimplementedError();

  OnetimeauthState crypto_onetimeauth_init(JSUint8Array? key) =>
      throw UnimplementedError();

  JSUint8Array crypto_onetimeauth_keygen() => throw UnimplementedError();

  void crypto_onetimeauth_update(
    OnetimeauthState state_address,
    JSUint8Array message_chunk,
  ) =>
      throw UnimplementedError();

  bool crypto_onetimeauth_verify(
    JSUint8Array hash,
    JSUint8Array message,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_pwhash(
    int keyLength,
    JSUint8Array password,
    JSUint8Array salt,
    int opsLimit,
    int memLimit,
    int algorithm,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_pwhash_scryptsalsa208sha256(
    int keyLength,
    JSUint8Array password,
    JSUint8Array salt,
    int opsLimit,
    int memLimit,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_pwhash_scryptsalsa208sha256_ll(
    JSUint8Array password,
    JSUint8Array salt,
    int opsLimit,
    int r,
    int p,
    int keyLength,
  ) =>
      throw UnimplementedError();

  String crypto_pwhash_scryptsalsa208sha256_str(
    JSUint8Array password,
    int opsLimit,
    int memLimit,
  ) =>
      throw UnimplementedError();

  bool crypto_pwhash_scryptsalsa208sha256_str_verify(
    String hashed_password,
    JSUint8Array password,
  ) =>
      throw UnimplementedError();

  String crypto_pwhash_str(
    JSUint8Array password,
    int opsLimit,
    int memLimit,
  ) =>
      throw UnimplementedError();

  bool crypto_pwhash_str_needs_rehash(
    String hashed_password,
    int opsLimit,
    int memLimit,
  ) =>
      throw UnimplementedError();

  bool crypto_pwhash_str_verify(
    String hashed_password,
    JSUint8Array password,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_scalarmult(
    JSUint8Array privateKey,
    JSUint8Array publicKey,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_scalarmult_base(JSUint8Array privateKey) =>
      throw UnimplementedError();

  JSUint8Array crypto_scalarmult_ed25519(
    JSUint8Array n,
    JSUint8Array p,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_scalarmult_ed25519_base(JSUint8Array scalar) =>
      throw UnimplementedError();

  JSUint8Array crypto_scalarmult_ed25519_base_noclamp(JSUint8Array scalar) =>
      throw UnimplementedError();

  JSUint8Array crypto_scalarmult_ed25519_noclamp(
    JSUint8Array n,
    JSUint8Array p,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_scalarmult_ristretto255(
    JSUint8Array scalar,
    JSUint8Array element,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_scalarmult_ristretto255_base(JSUint8Array scalar) =>
      throw UnimplementedError();

  SecretBox crypto_secretbox_detached(
    JSUint8Array message,
    JSUint8Array nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_secretbox_easy(
    JSUint8Array message,
    JSUint8Array nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_secretbox_keygen() => throw UnimplementedError();

  JSUint8Array crypto_secretbox_open_detached(
    JSUint8Array ciphertext,
    JSUint8Array mac,
    JSUint8Array nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_secretbox_open_easy(
    JSUint8Array ciphertext,
    JSUint8Array nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  SecretstreamXchacha20poly1305State
      crypto_secretstream_xchacha20poly1305_init_pull(
    JSUint8Array header,
    JSUint8Array key,
  ) =>
          throw UnimplementedError();

  SecretStreamInitPush crypto_secretstream_xchacha20poly1305_init_push(
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_secretstream_xchacha20poly1305_keygen() =>
      throw UnimplementedError();

  JSAny crypto_secretstream_xchacha20poly1305_pull(
    SecretstreamXchacha20poly1305State state_address,
    JSUint8Array cipher,
    JSUint8Array? ad,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_secretstream_xchacha20poly1305_push(
    SecretstreamXchacha20poly1305State state_address,
    JSUint8Array message_chunk,
    JSUint8Array? ad,
    int tag,
  ) =>
      throw UnimplementedError();

  bool crypto_secretstream_xchacha20poly1305_rekey(
    SecretstreamXchacha20poly1305State state_address,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_shorthash(
    JSUint8Array message,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_shorthash_keygen() => throw UnimplementedError();

  JSUint8Array crypto_shorthash_siphashx24(
    JSUint8Array message,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_sign(
    JSUint8Array message,
    JSUint8Array privateKey,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_sign_detached(
    JSUint8Array message,
    JSUint8Array privateKey,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_sign_ed25519_pk_to_curve25519(JSUint8Array edPk) =>
      throw UnimplementedError();

  JSUint8Array crypto_sign_ed25519_sk_to_curve25519(JSUint8Array edSk) =>
      throw UnimplementedError();

  JSUint8Array crypto_sign_ed25519_sk_to_pk(JSUint8Array privateKey) =>
      throw UnimplementedError();

  JSUint8Array crypto_sign_ed25519_sk_to_seed(JSUint8Array privateKey) =>
      throw UnimplementedError();

  JSUint8Array crypto_sign_final_create(
    SignState state_address,
    JSUint8Array privateKey,
  ) =>
      throw UnimplementedError();

  bool crypto_sign_final_verify(
    SignState state_address,
    JSUint8Array signature,
    JSUint8Array publicKey,
  ) =>
      throw UnimplementedError();

  SignState crypto_sign_init() => throw UnimplementedError();

  KeyPair crypto_sign_keypair() => throw UnimplementedError();

  JSUint8Array crypto_sign_open(
    JSUint8Array signedMessage,
    JSUint8Array publicKey,
  ) =>
      throw UnimplementedError();

  KeyPair crypto_sign_seed_keypair(JSUint8Array seed) =>
      throw UnimplementedError();

  void crypto_sign_update(
    SignState state_address,
    JSUint8Array message_chunk,
  ) =>
      throw UnimplementedError();

  bool crypto_sign_verify_detached(
    JSUint8Array signature,
    JSUint8Array message,
    JSUint8Array publicKey,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_stream_chacha20(
    int outLength,
    JSUint8Array key,
    JSUint8Array nonce,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_stream_chacha20_ietf_xor(
    JSUint8Array input_message,
    JSUint8Array nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_stream_chacha20_ietf_xor_ic(
    JSUint8Array input_message,
    JSUint8Array nonce,
    int nonce_increment,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_stream_chacha20_keygen() => throw UnimplementedError();

  JSUint8Array crypto_stream_chacha20_xor(
    JSUint8Array input_message,
    JSUint8Array nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_stream_chacha20_xor_ic(
    JSUint8Array input_message,
    JSUint8Array nonce,
    int nonce_increment,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_stream_keygen() => throw UnimplementedError();

  JSUint8Array crypto_stream_xchacha20_keygen() => throw UnimplementedError();

  JSUint8Array crypto_stream_xchacha20_xor(
    JSUint8Array input_message,
    JSUint8Array nonce,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array crypto_stream_xchacha20_xor_ic(
    JSUint8Array input_message,
    JSUint8Array nonce,
    int nonce_increment,
    JSUint8Array key,
  ) =>
      throw UnimplementedError();

  JSUint8Array randombytes_buf(int length) => throw UnimplementedError();

  JSUint8Array randombytes_buf_deterministic(
    int length,
    JSUint8Array seed,
  ) =>
      throw UnimplementedError();

  void randombytes_close() => throw UnimplementedError();

  int randombytes_random() => throw UnimplementedError();

  void randombytes_set_implementation(JSAny implementation) =>
      throw UnimplementedError();

  void randombytes_stir() => throw UnimplementedError();

  int randombytes_uniform(int upper_bound) => throw UnimplementedError();

  String sodium_version_string() => throw UnimplementedError();

  int randombytes_seedbytes() => throw UnimplementedError();

  void memzero(JSUint8Array bytes) => throw UnimplementedError();

  JSUint8Array pad(
    JSUint8Array buf,
    int blocksize,
  ) =>
      throw UnimplementedError();

  JSUint8Array unpad(
    JSUint8Array buf,
    int blocksize,
  ) =>
      throw UnimplementedError();
}

@JSExport()
class MockLibSodiumJS extends Mock implements _MockLibSodiumJS {
  LibSodiumJS get asLibSodiumJS =>
      createJSInteropWrapper<MockLibSodiumJS>(this) as LibSodiumJS;
}
