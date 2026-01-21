// ignore_for_file: document_ignores, non_constant_identifier_names
// ignore_for_file: prefer_relative_imports, public_member_api_docs

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:ffi' as _i1;

import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart' as _i2;

class LibSodiumFFI {
  const LibSodiumFFI();

  _i1.Pointer<_i1.NativeFinalizerFunction>? get sodium_freePtr =>
      _i1.Native.addressOf(_i2.sodium_free);

  @pragma('vm:prefer-inline')
  _i1.Pointer<_i1.Char> sodium_version_string() => _i2.sodium_version_string();

  @pragma('vm:prefer-inline')
  int sodium_library_version_major() => _i2.sodium_library_version_major();

  @pragma('vm:prefer-inline')
  int sodium_library_version_minor() => _i2.sodium_library_version_minor();

  @pragma('vm:prefer-inline')
  int sodium_library_minimal() => _i2.sodium_library_minimal();

  @pragma('vm:prefer-inline')
  int sodium_init() => _i2.sodium_init();

  @pragma('vm:prefer-inline')
  int sodium_set_misuse_handler(
    _i1.Pointer<_i1.NativeFunction<_i1.Void Function()>> handler,
  ) => _i2.sodium_set_misuse_handler(handler);

  @pragma('vm:prefer-inline')
  void sodium_misuse() => _i2.sodium_misuse();

  @pragma('vm:prefer-inline')
  int crypto_aead_aegis128l_keybytes() => _i2.crypto_aead_aegis128l_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_aead_aegis128l_nsecbytes() =>
      _i2.crypto_aead_aegis128l_nsecbytes();

  @pragma('vm:prefer-inline')
  int crypto_aead_aegis128l_npubbytes() =>
      _i2.crypto_aead_aegis128l_npubbytes();

  @pragma('vm:prefer-inline')
  int crypto_aead_aegis128l_abytes() => _i2.crypto_aead_aegis128l_abytes();

  @pragma('vm:prefer-inline')
  int crypto_aead_aegis128l_messagebytes_max() =>
      _i2.crypto_aead_aegis128l_messagebytes_max();

  @pragma('vm:prefer-inline')
  int crypto_aead_aegis128l_encrypt(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedLongLong> clen_p,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_aegis128l_encrypt(
    c,
    clen_p,
    m,
    mlen,
    ad,
    adlen,
    nsec,
    npub,
    k,
  );

  @pragma('vm:prefer-inline')
  int crypto_aead_aegis128l_decrypt(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedLongLong> mlen_p,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_aegis128l_decrypt(
    m,
    mlen_p,
    nsec,
    c,
    clen,
    ad,
    adlen,
    npub,
    k,
  );

  @pragma('vm:prefer-inline')
  int crypto_aead_aegis128l_encrypt_detached(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> mac,
    _i1.Pointer<_i1.UnsignedLongLong> maclen_p,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_aegis128l_encrypt_detached(
    c,
    mac,
    maclen_p,
    m,
    mlen,
    ad,
    adlen,
    nsec,
    npub,
    k,
  );

  @pragma('vm:prefer-inline')
  int crypto_aead_aegis128l_decrypt_detached(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> mac,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_aegis128l_decrypt_detached(
    m,
    nsec,
    c,
    clen,
    mac,
    ad,
    adlen,
    npub,
    k,
  );

  @pragma('vm:prefer-inline')
  void crypto_aead_aegis128l_keygen(_i1.Pointer<_i1.UnsignedChar> k) =>
      _i2.crypto_aead_aegis128l_keygen(k);

  @pragma('vm:prefer-inline')
  int crypto_aead_aegis256_keybytes() => _i2.crypto_aead_aegis256_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_aead_aegis256_nsecbytes() => _i2.crypto_aead_aegis256_nsecbytes();

  @pragma('vm:prefer-inline')
  int crypto_aead_aegis256_npubbytes() => _i2.crypto_aead_aegis256_npubbytes();

  @pragma('vm:prefer-inline')
  int crypto_aead_aegis256_abytes() => _i2.crypto_aead_aegis256_abytes();

  @pragma('vm:prefer-inline')
  int crypto_aead_aegis256_messagebytes_max() =>
      _i2.crypto_aead_aegis256_messagebytes_max();

  @pragma('vm:prefer-inline')
  int crypto_aead_aegis256_encrypt(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedLongLong> clen_p,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_aegis256_encrypt(
    c,
    clen_p,
    m,
    mlen,
    ad,
    adlen,
    nsec,
    npub,
    k,
  );

  @pragma('vm:prefer-inline')
  int crypto_aead_aegis256_decrypt(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedLongLong> mlen_p,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_aegis256_decrypt(
    m,
    mlen_p,
    nsec,
    c,
    clen,
    ad,
    adlen,
    npub,
    k,
  );

  @pragma('vm:prefer-inline')
  int crypto_aead_aegis256_encrypt_detached(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> mac,
    _i1.Pointer<_i1.UnsignedLongLong> maclen_p,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_aegis256_encrypt_detached(
    c,
    mac,
    maclen_p,
    m,
    mlen,
    ad,
    adlen,
    nsec,
    npub,
    k,
  );

  @pragma('vm:prefer-inline')
  int crypto_aead_aegis256_decrypt_detached(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> mac,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_aegis256_decrypt_detached(
    m,
    nsec,
    c,
    clen,
    mac,
    ad,
    adlen,
    npub,
    k,
  );

  @pragma('vm:prefer-inline')
  void crypto_aead_aegis256_keygen(_i1.Pointer<_i1.UnsignedChar> k) =>
      _i2.crypto_aead_aegis256_keygen(k);

  @pragma('vm:prefer-inline')
  int crypto_aead_aes256gcm_is_available() =>
      _i2.crypto_aead_aes256gcm_is_available();

  @pragma('vm:prefer-inline')
  int crypto_aead_aes256gcm_keybytes() => _i2.crypto_aead_aes256gcm_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_aead_aes256gcm_nsecbytes() =>
      _i2.crypto_aead_aes256gcm_nsecbytes();

  @pragma('vm:prefer-inline')
  int crypto_aead_aes256gcm_npubbytes() =>
      _i2.crypto_aead_aes256gcm_npubbytes();

  @pragma('vm:prefer-inline')
  int crypto_aead_aes256gcm_abytes() => _i2.crypto_aead_aes256gcm_abytes();

  @pragma('vm:prefer-inline')
  int crypto_aead_aes256gcm_messagebytes_max() =>
      _i2.crypto_aead_aes256gcm_messagebytes_max();

  @pragma('vm:prefer-inline')
  int crypto_aead_aes256gcm_statebytes() =>
      _i2.crypto_aead_aes256gcm_statebytes();

  @pragma('vm:prefer-inline')
  int crypto_aead_aes256gcm_encrypt(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedLongLong> clen_p,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_aes256gcm_encrypt(
    c,
    clen_p,
    m,
    mlen,
    ad,
    adlen,
    nsec,
    npub,
    k,
  );

  @pragma('vm:prefer-inline')
  int crypto_aead_aes256gcm_decrypt(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedLongLong> mlen_p,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_aes256gcm_decrypt(
    m,
    mlen_p,
    nsec,
    c,
    clen,
    ad,
    adlen,
    npub,
    k,
  );

  @pragma('vm:prefer-inline')
  int crypto_aead_aes256gcm_encrypt_detached(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> mac,
    _i1.Pointer<_i1.UnsignedLongLong> maclen_p,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_aes256gcm_encrypt_detached(
    c,
    mac,
    maclen_p,
    m,
    mlen,
    ad,
    adlen,
    nsec,
    npub,
    k,
  );

  @pragma('vm:prefer-inline')
  int crypto_aead_aes256gcm_decrypt_detached(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> mac,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_aes256gcm_decrypt_detached(
    m,
    nsec,
    c,
    clen,
    mac,
    ad,
    adlen,
    npub,
    k,
  );

  @pragma('vm:prefer-inline')
  int crypto_aead_aes256gcm_beforenm(
    _i1.Pointer<_i2.crypto_aead_aes256gcm_state_> ctx_,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_aes256gcm_beforenm(ctx_, k);

  @pragma('vm:prefer-inline')
  int crypto_aead_aes256gcm_encrypt_afternm(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedLongLong> clen_p,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i2.crypto_aead_aes256gcm_state_> ctx_,
  ) => _i2.crypto_aead_aes256gcm_encrypt_afternm(
    c,
    clen_p,
    m,
    mlen,
    ad,
    adlen,
    nsec,
    npub,
    ctx_,
  );

  @pragma('vm:prefer-inline')
  int crypto_aead_aes256gcm_decrypt_afternm(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedLongLong> mlen_p,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i2.crypto_aead_aes256gcm_state_> ctx_,
  ) => _i2.crypto_aead_aes256gcm_decrypt_afternm(
    m,
    mlen_p,
    nsec,
    c,
    clen,
    ad,
    adlen,
    npub,
    ctx_,
  );

  @pragma('vm:prefer-inline')
  int crypto_aead_aes256gcm_encrypt_detached_afternm(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> mac,
    _i1.Pointer<_i1.UnsignedLongLong> maclen_p,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i2.crypto_aead_aes256gcm_state_> ctx_,
  ) => _i2.crypto_aead_aes256gcm_encrypt_detached_afternm(
    c,
    mac,
    maclen_p,
    m,
    mlen,
    ad,
    adlen,
    nsec,
    npub,
    ctx_,
  );

  @pragma('vm:prefer-inline')
  int crypto_aead_aes256gcm_decrypt_detached_afternm(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> mac,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i2.crypto_aead_aes256gcm_state_> ctx_,
  ) => _i2.crypto_aead_aes256gcm_decrypt_detached_afternm(
    m,
    nsec,
    c,
    clen,
    mac,
    ad,
    adlen,
    npub,
    ctx_,
  );

  @pragma('vm:prefer-inline')
  void crypto_aead_aes256gcm_keygen(_i1.Pointer<_i1.UnsignedChar> k) =>
      _i2.crypto_aead_aes256gcm_keygen(k);

  @pragma('vm:prefer-inline')
  int crypto_aead_chacha20poly1305_ietf_keybytes() =>
      _i2.crypto_aead_chacha20poly1305_ietf_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_aead_chacha20poly1305_ietf_nsecbytes() =>
      _i2.crypto_aead_chacha20poly1305_ietf_nsecbytes();

  @pragma('vm:prefer-inline')
  int crypto_aead_chacha20poly1305_ietf_npubbytes() =>
      _i2.crypto_aead_chacha20poly1305_ietf_npubbytes();

  @pragma('vm:prefer-inline')
  int crypto_aead_chacha20poly1305_ietf_abytes() =>
      _i2.crypto_aead_chacha20poly1305_ietf_abytes();

  @pragma('vm:prefer-inline')
  int crypto_aead_chacha20poly1305_ietf_messagebytes_max() =>
      _i2.crypto_aead_chacha20poly1305_ietf_messagebytes_max();

  @pragma('vm:prefer-inline')
  int crypto_aead_chacha20poly1305_ietf_encrypt(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedLongLong> clen_p,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_chacha20poly1305_ietf_encrypt(
    c,
    clen_p,
    m,
    mlen,
    ad,
    adlen,
    nsec,
    npub,
    k,
  );

  @pragma('vm:prefer-inline')
  int crypto_aead_chacha20poly1305_ietf_decrypt(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedLongLong> mlen_p,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_chacha20poly1305_ietf_decrypt(
    m,
    mlen_p,
    nsec,
    c,
    clen,
    ad,
    adlen,
    npub,
    k,
  );

  @pragma('vm:prefer-inline')
  int crypto_aead_chacha20poly1305_ietf_encrypt_detached(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> mac,
    _i1.Pointer<_i1.UnsignedLongLong> maclen_p,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_chacha20poly1305_ietf_encrypt_detached(
    c,
    mac,
    maclen_p,
    m,
    mlen,
    ad,
    adlen,
    nsec,
    npub,
    k,
  );

  @pragma('vm:prefer-inline')
  int crypto_aead_chacha20poly1305_ietf_decrypt_detached(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> mac,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_chacha20poly1305_ietf_decrypt_detached(
    m,
    nsec,
    c,
    clen,
    mac,
    ad,
    adlen,
    npub,
    k,
  );

  @pragma('vm:prefer-inline')
  void crypto_aead_chacha20poly1305_ietf_keygen(
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_chacha20poly1305_ietf_keygen(k);

  @pragma('vm:prefer-inline')
  int crypto_aead_chacha20poly1305_keybytes() =>
      _i2.crypto_aead_chacha20poly1305_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_aead_chacha20poly1305_nsecbytes() =>
      _i2.crypto_aead_chacha20poly1305_nsecbytes();

  @pragma('vm:prefer-inline')
  int crypto_aead_chacha20poly1305_npubbytes() =>
      _i2.crypto_aead_chacha20poly1305_npubbytes();

  @pragma('vm:prefer-inline')
  int crypto_aead_chacha20poly1305_abytes() =>
      _i2.crypto_aead_chacha20poly1305_abytes();

  @pragma('vm:prefer-inline')
  int crypto_aead_chacha20poly1305_messagebytes_max() =>
      _i2.crypto_aead_chacha20poly1305_messagebytes_max();

  @pragma('vm:prefer-inline')
  int crypto_aead_chacha20poly1305_encrypt(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedLongLong> clen_p,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_chacha20poly1305_encrypt(
    c,
    clen_p,
    m,
    mlen,
    ad,
    adlen,
    nsec,
    npub,
    k,
  );

  @pragma('vm:prefer-inline')
  int crypto_aead_chacha20poly1305_decrypt(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedLongLong> mlen_p,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_chacha20poly1305_decrypt(
    m,
    mlen_p,
    nsec,
    c,
    clen,
    ad,
    adlen,
    npub,
    k,
  );

  @pragma('vm:prefer-inline')
  int crypto_aead_chacha20poly1305_encrypt_detached(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> mac,
    _i1.Pointer<_i1.UnsignedLongLong> maclen_p,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_chacha20poly1305_encrypt_detached(
    c,
    mac,
    maclen_p,
    m,
    mlen,
    ad,
    adlen,
    nsec,
    npub,
    k,
  );

  @pragma('vm:prefer-inline')
  int crypto_aead_chacha20poly1305_decrypt_detached(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> mac,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_chacha20poly1305_decrypt_detached(
    m,
    nsec,
    c,
    clen,
    mac,
    ad,
    adlen,
    npub,
    k,
  );

  @pragma('vm:prefer-inline')
  void crypto_aead_chacha20poly1305_keygen(_i1.Pointer<_i1.UnsignedChar> k) =>
      _i2.crypto_aead_chacha20poly1305_keygen(k);

  @pragma('vm:prefer-inline')
  int crypto_aead_xchacha20poly1305_ietf_keybytes() =>
      _i2.crypto_aead_xchacha20poly1305_ietf_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_aead_xchacha20poly1305_ietf_nsecbytes() =>
      _i2.crypto_aead_xchacha20poly1305_ietf_nsecbytes();

  @pragma('vm:prefer-inline')
  int crypto_aead_xchacha20poly1305_ietf_npubbytes() =>
      _i2.crypto_aead_xchacha20poly1305_ietf_npubbytes();

  @pragma('vm:prefer-inline')
  int crypto_aead_xchacha20poly1305_ietf_abytes() =>
      _i2.crypto_aead_xchacha20poly1305_ietf_abytes();

  @pragma('vm:prefer-inline')
  int crypto_aead_xchacha20poly1305_ietf_messagebytes_max() =>
      _i2.crypto_aead_xchacha20poly1305_ietf_messagebytes_max();

  @pragma('vm:prefer-inline')
  int crypto_aead_xchacha20poly1305_ietf_encrypt(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedLongLong> clen_p,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_xchacha20poly1305_ietf_encrypt(
    c,
    clen_p,
    m,
    mlen,
    ad,
    adlen,
    nsec,
    npub,
    k,
  );

  @pragma('vm:prefer-inline')
  int crypto_aead_xchacha20poly1305_ietf_decrypt(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedLongLong> mlen_p,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_xchacha20poly1305_ietf_decrypt(
    m,
    mlen_p,
    nsec,
    c,
    clen,
    ad,
    adlen,
    npub,
    k,
  );

  @pragma('vm:prefer-inline')
  int crypto_aead_xchacha20poly1305_ietf_encrypt_detached(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> mac,
    _i1.Pointer<_i1.UnsignedLongLong> maclen_p,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_xchacha20poly1305_ietf_encrypt_detached(
    c,
    mac,
    maclen_p,
    m,
    mlen,
    ad,
    adlen,
    nsec,
    npub,
    k,
  );

  @pragma('vm:prefer-inline')
  int crypto_aead_xchacha20poly1305_ietf_decrypt_detached(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> nsec,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> mac,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    _i1.Pointer<_i1.UnsignedChar> npub,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_xchacha20poly1305_ietf_decrypt_detached(
    m,
    nsec,
    c,
    clen,
    mac,
    ad,
    adlen,
    npub,
    k,
  );

  @pragma('vm:prefer-inline')
  void crypto_aead_xchacha20poly1305_ietf_keygen(
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_aead_xchacha20poly1305_ietf_keygen(k);

  @pragma('vm:prefer-inline')
  int crypto_hash_sha512_statebytes() => _i2.crypto_hash_sha512_statebytes();

  @pragma('vm:prefer-inline')
  int crypto_hash_sha512_bytes() => _i2.crypto_hash_sha512_bytes();

  @pragma('vm:prefer-inline')
  int crypto_hash_sha512(
    _i1.Pointer<_i1.UnsignedChar> out,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
  ) => _i2.crypto_hash_sha512(out, in$, inlen);

  @pragma('vm:prefer-inline')
  int crypto_hash_sha512_init(
    _i1.Pointer<_i2.crypto_hash_sha512_state> state,
  ) => _i2.crypto_hash_sha512_init(state);

  @pragma('vm:prefer-inline')
  int crypto_hash_sha512_update(
    _i1.Pointer<_i2.crypto_hash_sha512_state> state,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
  ) => _i2.crypto_hash_sha512_update(state, in$, inlen);

  @pragma('vm:prefer-inline')
  int crypto_hash_sha512_final(
    _i1.Pointer<_i2.crypto_hash_sha512_state> state,
    _i1.Pointer<_i1.UnsignedChar> out,
  ) => _i2.crypto_hash_sha512_final(state, out);

  @pragma('vm:prefer-inline')
  int crypto_auth_hmacsha512_bytes() => _i2.crypto_auth_hmacsha512_bytes();

  @pragma('vm:prefer-inline')
  int crypto_auth_hmacsha512_keybytes() =>
      _i2.crypto_auth_hmacsha512_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_auth_hmacsha512(
    _i1.Pointer<_i1.UnsignedChar> out,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_auth_hmacsha512(out, in$, inlen, k);

  @pragma('vm:prefer-inline')
  int crypto_auth_hmacsha512_verify(
    _i1.Pointer<_i1.UnsignedChar> h,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_auth_hmacsha512_verify(h, in$, inlen, k);

  @pragma('vm:prefer-inline')
  int crypto_auth_hmacsha512_statebytes() =>
      _i2.crypto_auth_hmacsha512_statebytes();

  @pragma('vm:prefer-inline')
  int crypto_auth_hmacsha512_init(
    _i1.Pointer<_i2.crypto_auth_hmacsha512_state> state,
    _i1.Pointer<_i1.UnsignedChar> key,
    int keylen,
  ) => _i2.crypto_auth_hmacsha512_init(state, key, keylen);

  @pragma('vm:prefer-inline')
  int crypto_auth_hmacsha512_update(
    _i1.Pointer<_i2.crypto_auth_hmacsha512_state> state,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
  ) => _i2.crypto_auth_hmacsha512_update(state, in$, inlen);

  @pragma('vm:prefer-inline')
  int crypto_auth_hmacsha512_final(
    _i1.Pointer<_i2.crypto_auth_hmacsha512_state> state,
    _i1.Pointer<_i1.UnsignedChar> out,
  ) => _i2.crypto_auth_hmacsha512_final(state, out);

  @pragma('vm:prefer-inline')
  void crypto_auth_hmacsha512_keygen(_i1.Pointer<_i1.UnsignedChar> k) =>
      _i2.crypto_auth_hmacsha512_keygen(k);

  @pragma('vm:prefer-inline')
  int crypto_auth_hmacsha512256_bytes() =>
      _i2.crypto_auth_hmacsha512256_bytes();

  @pragma('vm:prefer-inline')
  int crypto_auth_hmacsha512256_keybytes() =>
      _i2.crypto_auth_hmacsha512256_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_auth_hmacsha512256(
    _i1.Pointer<_i1.UnsignedChar> out,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_auth_hmacsha512256(out, in$, inlen, k);

  @pragma('vm:prefer-inline')
  int crypto_auth_hmacsha512256_verify(
    _i1.Pointer<_i1.UnsignedChar> h,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_auth_hmacsha512256_verify(h, in$, inlen, k);

  @pragma('vm:prefer-inline')
  int crypto_auth_hmacsha512256_statebytes() =>
      _i2.crypto_auth_hmacsha512256_statebytes();

  @pragma('vm:prefer-inline')
  int crypto_auth_hmacsha512256_init(
    _i1.Pointer<_i2.crypto_auth_hmacsha512_state> state,
    _i1.Pointer<_i1.UnsignedChar> key,
    int keylen,
  ) => _i2.crypto_auth_hmacsha512256_init(state, key, keylen);

  @pragma('vm:prefer-inline')
  int crypto_auth_hmacsha512256_update(
    _i1.Pointer<_i2.crypto_auth_hmacsha512_state> state,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
  ) => _i2.crypto_auth_hmacsha512256_update(state, in$, inlen);

  @pragma('vm:prefer-inline')
  int crypto_auth_hmacsha512256_final(
    _i1.Pointer<_i2.crypto_auth_hmacsha512_state> state,
    _i1.Pointer<_i1.UnsignedChar> out,
  ) => _i2.crypto_auth_hmacsha512256_final(state, out);

  @pragma('vm:prefer-inline')
  void crypto_auth_hmacsha512256_keygen(_i1.Pointer<_i1.UnsignedChar> k) =>
      _i2.crypto_auth_hmacsha512256_keygen(k);

  @pragma('vm:prefer-inline')
  int crypto_auth_bytes() => _i2.crypto_auth_bytes();

  @pragma('vm:prefer-inline')
  int crypto_auth_keybytes() => _i2.crypto_auth_keybytes();

  @pragma('vm:prefer-inline')
  _i1.Pointer<_i1.Char> crypto_auth_primitive() => _i2.crypto_auth_primitive();

  @pragma('vm:prefer-inline')
  int crypto_auth(
    _i1.Pointer<_i1.UnsignedChar> out,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_auth(out, in$, inlen, k);

  @pragma('vm:prefer-inline')
  int crypto_auth_verify(
    _i1.Pointer<_i1.UnsignedChar> h,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_auth_verify(h, in$, inlen, k);

  @pragma('vm:prefer-inline')
  void crypto_auth_keygen(_i1.Pointer<_i1.UnsignedChar> k) =>
      _i2.crypto_auth_keygen(k);

  @pragma('vm:prefer-inline')
  int crypto_hash_sha256_statebytes() => _i2.crypto_hash_sha256_statebytes();

  @pragma('vm:prefer-inline')
  int crypto_hash_sha256_bytes() => _i2.crypto_hash_sha256_bytes();

  @pragma('vm:prefer-inline')
  int crypto_hash_sha256(
    _i1.Pointer<_i1.UnsignedChar> out,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
  ) => _i2.crypto_hash_sha256(out, in$, inlen);

  @pragma('vm:prefer-inline')
  int crypto_hash_sha256_init(
    _i1.Pointer<_i2.crypto_hash_sha256_state> state,
  ) => _i2.crypto_hash_sha256_init(state);

  @pragma('vm:prefer-inline')
  int crypto_hash_sha256_update(
    _i1.Pointer<_i2.crypto_hash_sha256_state> state,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
  ) => _i2.crypto_hash_sha256_update(state, in$, inlen);

  @pragma('vm:prefer-inline')
  int crypto_hash_sha256_final(
    _i1.Pointer<_i2.crypto_hash_sha256_state> state,
    _i1.Pointer<_i1.UnsignedChar> out,
  ) => _i2.crypto_hash_sha256_final(state, out);

  @pragma('vm:prefer-inline')
  int crypto_auth_hmacsha256_bytes() => _i2.crypto_auth_hmacsha256_bytes();

  @pragma('vm:prefer-inline')
  int crypto_auth_hmacsha256_keybytes() =>
      _i2.crypto_auth_hmacsha256_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_auth_hmacsha256(
    _i1.Pointer<_i1.UnsignedChar> out,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_auth_hmacsha256(out, in$, inlen, k);

  @pragma('vm:prefer-inline')
  int crypto_auth_hmacsha256_verify(
    _i1.Pointer<_i1.UnsignedChar> h,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_auth_hmacsha256_verify(h, in$, inlen, k);

  @pragma('vm:prefer-inline')
  int crypto_auth_hmacsha256_statebytes() =>
      _i2.crypto_auth_hmacsha256_statebytes();

  @pragma('vm:prefer-inline')
  int crypto_auth_hmacsha256_init(
    _i1.Pointer<_i2.crypto_auth_hmacsha256_state> state,
    _i1.Pointer<_i1.UnsignedChar> key,
    int keylen,
  ) => _i2.crypto_auth_hmacsha256_init(state, key, keylen);

  @pragma('vm:prefer-inline')
  int crypto_auth_hmacsha256_update(
    _i1.Pointer<_i2.crypto_auth_hmacsha256_state> state,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
  ) => _i2.crypto_auth_hmacsha256_update(state, in$, inlen);

  @pragma('vm:prefer-inline')
  int crypto_auth_hmacsha256_final(
    _i1.Pointer<_i2.crypto_auth_hmacsha256_state> state,
    _i1.Pointer<_i1.UnsignedChar> out,
  ) => _i2.crypto_auth_hmacsha256_final(state, out);

  @pragma('vm:prefer-inline')
  void crypto_auth_hmacsha256_keygen(_i1.Pointer<_i1.UnsignedChar> k) =>
      _i2.crypto_auth_hmacsha256_keygen(k);

  @pragma('vm:prefer-inline')
  int crypto_stream_xsalsa20_keybytes() =>
      _i2.crypto_stream_xsalsa20_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_stream_xsalsa20_noncebytes() =>
      _i2.crypto_stream_xsalsa20_noncebytes();

  @pragma('vm:prefer-inline')
  int crypto_stream_xsalsa20_messagebytes_max() =>
      _i2.crypto_stream_xsalsa20_messagebytes_max();

  @pragma('vm:prefer-inline')
  int crypto_stream_xsalsa20(
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_stream_xsalsa20(c, clen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_stream_xsalsa20_xor(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_stream_xsalsa20_xor(c, m, mlen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_stream_xsalsa20_xor_ic(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    int ic,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_stream_xsalsa20_xor_ic(c, m, mlen, n, ic, k);

  @pragma('vm:prefer-inline')
  void crypto_stream_xsalsa20_keygen(_i1.Pointer<_i1.UnsignedChar> k) =>
      _i2.crypto_stream_xsalsa20_keygen(k);

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xsalsa20poly1305_seedbytes() =>
      _i2.crypto_box_curve25519xsalsa20poly1305_seedbytes();

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xsalsa20poly1305_publickeybytes() =>
      _i2.crypto_box_curve25519xsalsa20poly1305_publickeybytes();

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xsalsa20poly1305_secretkeybytes() =>
      _i2.crypto_box_curve25519xsalsa20poly1305_secretkeybytes();

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xsalsa20poly1305_beforenmbytes() =>
      _i2.crypto_box_curve25519xsalsa20poly1305_beforenmbytes();

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xsalsa20poly1305_noncebytes() =>
      _i2.crypto_box_curve25519xsalsa20poly1305_noncebytes();

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xsalsa20poly1305_macbytes() =>
      _i2.crypto_box_curve25519xsalsa20poly1305_macbytes();

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xsalsa20poly1305_messagebytes_max() =>
      _i2.crypto_box_curve25519xsalsa20poly1305_messagebytes_max();

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xsalsa20poly1305_seed_keypair(
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
    _i1.Pointer<_i1.UnsignedChar> seed,
  ) => _i2.crypto_box_curve25519xsalsa20poly1305_seed_keypair(pk, sk, seed);

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xsalsa20poly1305_keypair(
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_box_curve25519xsalsa20poly1305_keypair(pk, sk);

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xsalsa20poly1305_beforenm(
    _i1.Pointer<_i1.UnsignedChar> k,
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_box_curve25519xsalsa20poly1305_beforenm(k, pk, sk);

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xsalsa20poly1305_boxzerobytes() =>
      _i2.crypto_box_curve25519xsalsa20poly1305_boxzerobytes();

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xsalsa20poly1305_zerobytes() =>
      _i2.crypto_box_curve25519xsalsa20poly1305_zerobytes();

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xsalsa20poly1305(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_box_curve25519xsalsa20poly1305(c, m, mlen, n, pk, sk);

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xsalsa20poly1305_open(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_box_curve25519xsalsa20poly1305_open(m, c, clen, n, pk, sk);

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xsalsa20poly1305_afternm(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_box_curve25519xsalsa20poly1305_afternm(c, m, mlen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xsalsa20poly1305_open_afternm(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_box_curve25519xsalsa20poly1305_open_afternm(m, c, clen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_box_seedbytes() => _i2.crypto_box_seedbytes();

  @pragma('vm:prefer-inline')
  int crypto_box_publickeybytes() => _i2.crypto_box_publickeybytes();

  @pragma('vm:prefer-inline')
  int crypto_box_secretkeybytes() => _i2.crypto_box_secretkeybytes();

  @pragma('vm:prefer-inline')
  int crypto_box_noncebytes() => _i2.crypto_box_noncebytes();

  @pragma('vm:prefer-inline')
  int crypto_box_macbytes() => _i2.crypto_box_macbytes();

  @pragma('vm:prefer-inline')
  int crypto_box_messagebytes_max() => _i2.crypto_box_messagebytes_max();

  @pragma('vm:prefer-inline')
  _i1.Pointer<_i1.Char> crypto_box_primitive() => _i2.crypto_box_primitive();

  @pragma('vm:prefer-inline')
  int crypto_box_seed_keypair(
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
    _i1.Pointer<_i1.UnsignedChar> seed,
  ) => _i2.crypto_box_seed_keypair(pk, sk, seed);

  @pragma('vm:prefer-inline')
  int crypto_box_keypair(
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_box_keypair(pk, sk);

  @pragma('vm:prefer-inline')
  int crypto_box_easy(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_box_easy(c, m, mlen, n, pk, sk);

  @pragma('vm:prefer-inline')
  int crypto_box_open_easy(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_box_open_easy(m, c, clen, n, pk, sk);

  @pragma('vm:prefer-inline')
  int crypto_box_detached(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> mac,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_box_detached(c, mac, m, mlen, n, pk, sk);

  @pragma('vm:prefer-inline')
  int crypto_box_open_detached(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> mac,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_box_open_detached(m, c, mac, clen, n, pk, sk);

  @pragma('vm:prefer-inline')
  int crypto_box_beforenmbytes() => _i2.crypto_box_beforenmbytes();

  @pragma('vm:prefer-inline')
  int crypto_box_beforenm(
    _i1.Pointer<_i1.UnsignedChar> k,
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_box_beforenm(k, pk, sk);

  @pragma('vm:prefer-inline')
  int crypto_box_easy_afternm(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_box_easy_afternm(c, m, mlen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_box_open_easy_afternm(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_box_open_easy_afternm(m, c, clen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_box_detached_afternm(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> mac,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_box_detached_afternm(c, mac, m, mlen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_box_open_detached_afternm(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> mac,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_box_open_detached_afternm(m, c, mac, clen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_box_sealbytes() => _i2.crypto_box_sealbytes();

  @pragma('vm:prefer-inline')
  int crypto_box_seal(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> pk,
  ) => _i2.crypto_box_seal(c, m, mlen, pk);

  @pragma('vm:prefer-inline')
  int crypto_box_seal_open(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_box_seal_open(m, c, clen, pk, sk);

  @pragma('vm:prefer-inline')
  int crypto_box_zerobytes() => _i2.crypto_box_zerobytes();

  @pragma('vm:prefer-inline')
  int crypto_box_boxzerobytes() => _i2.crypto_box_boxzerobytes();

  @pragma('vm:prefer-inline')
  int crypto_box(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_box(c, m, mlen, n, pk, sk);

  @pragma('vm:prefer-inline')
  int crypto_box_open(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_box_open(m, c, clen, n, pk, sk);

  @pragma('vm:prefer-inline')
  int crypto_box_afternm(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_box_afternm(c, m, mlen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_box_open_afternm(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_box_open_afternm(m, c, clen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_core_hchacha20_outputbytes() =>
      _i2.crypto_core_hchacha20_outputbytes();

  @pragma('vm:prefer-inline')
  int crypto_core_hchacha20_inputbytes() =>
      _i2.crypto_core_hchacha20_inputbytes();

  @pragma('vm:prefer-inline')
  int crypto_core_hchacha20_keybytes() => _i2.crypto_core_hchacha20_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_core_hchacha20_constbytes() =>
      _i2.crypto_core_hchacha20_constbytes();

  @pragma('vm:prefer-inline')
  int crypto_core_hchacha20(
    _i1.Pointer<_i1.UnsignedChar> out,
    _i1.Pointer<_i1.UnsignedChar> in$,
    _i1.Pointer<_i1.UnsignedChar> k,
    _i1.Pointer<_i1.UnsignedChar> c,
  ) => _i2.crypto_core_hchacha20(out, in$, k, c);

  @pragma('vm:prefer-inline')
  int crypto_core_hsalsa20_outputbytes() =>
      _i2.crypto_core_hsalsa20_outputbytes();

  @pragma('vm:prefer-inline')
  int crypto_core_hsalsa20_inputbytes() =>
      _i2.crypto_core_hsalsa20_inputbytes();

  @pragma('vm:prefer-inline')
  int crypto_core_hsalsa20_keybytes() => _i2.crypto_core_hsalsa20_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_core_hsalsa20_constbytes() =>
      _i2.crypto_core_hsalsa20_constbytes();

  @pragma('vm:prefer-inline')
  int crypto_core_hsalsa20(
    _i1.Pointer<_i1.UnsignedChar> out,
    _i1.Pointer<_i1.UnsignedChar> in$,
    _i1.Pointer<_i1.UnsignedChar> k,
    _i1.Pointer<_i1.UnsignedChar> c,
  ) => _i2.crypto_core_hsalsa20(out, in$, k, c);

  @pragma('vm:prefer-inline')
  int crypto_core_salsa20_outputbytes() =>
      _i2.crypto_core_salsa20_outputbytes();

  @pragma('vm:prefer-inline')
  int crypto_core_salsa20_inputbytes() => _i2.crypto_core_salsa20_inputbytes();

  @pragma('vm:prefer-inline')
  int crypto_core_salsa20_keybytes() => _i2.crypto_core_salsa20_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_core_salsa20_constbytes() => _i2.crypto_core_salsa20_constbytes();

  @pragma('vm:prefer-inline')
  int crypto_core_salsa20(
    _i1.Pointer<_i1.UnsignedChar> out,
    _i1.Pointer<_i1.UnsignedChar> in$,
    _i1.Pointer<_i1.UnsignedChar> k,
    _i1.Pointer<_i1.UnsignedChar> c,
  ) => _i2.crypto_core_salsa20(out, in$, k, c);

  @pragma('vm:prefer-inline')
  int crypto_core_salsa2012_outputbytes() =>
      _i2.crypto_core_salsa2012_outputbytes();

  @pragma('vm:prefer-inline')
  int crypto_core_salsa2012_inputbytes() =>
      _i2.crypto_core_salsa2012_inputbytes();

  @pragma('vm:prefer-inline')
  int crypto_core_salsa2012_keybytes() => _i2.crypto_core_salsa2012_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_core_salsa2012_constbytes() =>
      _i2.crypto_core_salsa2012_constbytes();

  @pragma('vm:prefer-inline')
  int crypto_core_salsa2012(
    _i1.Pointer<_i1.UnsignedChar> out,
    _i1.Pointer<_i1.UnsignedChar> in$,
    _i1.Pointer<_i1.UnsignedChar> k,
    _i1.Pointer<_i1.UnsignedChar> c,
  ) => _i2.crypto_core_salsa2012(out, in$, k, c);

  @pragma('vm:prefer-inline')
  int crypto_core_salsa208_outputbytes() =>
      _i2.crypto_core_salsa208_outputbytes();

  @pragma('vm:prefer-inline')
  int crypto_core_salsa208_inputbytes() =>
      _i2.crypto_core_salsa208_inputbytes();

  @pragma('vm:prefer-inline')
  int crypto_core_salsa208_keybytes() => _i2.crypto_core_salsa208_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_core_salsa208_constbytes() =>
      _i2.crypto_core_salsa208_constbytes();

  @pragma('vm:prefer-inline')
  int crypto_core_salsa208(
    _i1.Pointer<_i1.UnsignedChar> out,
    _i1.Pointer<_i1.UnsignedChar> in$,
    _i1.Pointer<_i1.UnsignedChar> k,
    _i1.Pointer<_i1.UnsignedChar> c,
  ) => _i2.crypto_core_salsa208(out, in$, k, c);

  @pragma('vm:prefer-inline')
  int crypto_generichash_blake2b_bytes_min() =>
      _i2.crypto_generichash_blake2b_bytes_min();

  @pragma('vm:prefer-inline')
  int crypto_generichash_blake2b_bytes_max() =>
      _i2.crypto_generichash_blake2b_bytes_max();

  @pragma('vm:prefer-inline')
  int crypto_generichash_blake2b_bytes() =>
      _i2.crypto_generichash_blake2b_bytes();

  @pragma('vm:prefer-inline')
  int crypto_generichash_blake2b_keybytes_min() =>
      _i2.crypto_generichash_blake2b_keybytes_min();

  @pragma('vm:prefer-inline')
  int crypto_generichash_blake2b_keybytes_max() =>
      _i2.crypto_generichash_blake2b_keybytes_max();

  @pragma('vm:prefer-inline')
  int crypto_generichash_blake2b_keybytes() =>
      _i2.crypto_generichash_blake2b_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_generichash_blake2b_saltbytes() =>
      _i2.crypto_generichash_blake2b_saltbytes();

  @pragma('vm:prefer-inline')
  int crypto_generichash_blake2b_personalbytes() =>
      _i2.crypto_generichash_blake2b_personalbytes();

  @pragma('vm:prefer-inline')
  int crypto_generichash_blake2b_statebytes() =>
      _i2.crypto_generichash_blake2b_statebytes();

  @pragma('vm:prefer-inline')
  int crypto_generichash_blake2b(
    _i1.Pointer<_i1.UnsignedChar> out,
    int outlen,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
    _i1.Pointer<_i1.UnsignedChar> key,
    int keylen,
  ) => _i2.crypto_generichash_blake2b(out, outlen, in$, inlen, key, keylen);

  @pragma('vm:prefer-inline')
  int crypto_generichash_blake2b_salt_personal(
    _i1.Pointer<_i1.UnsignedChar> out,
    int outlen,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
    _i1.Pointer<_i1.UnsignedChar> key,
    int keylen,
    _i1.Pointer<_i1.UnsignedChar> salt,
    _i1.Pointer<_i1.UnsignedChar> personal,
  ) => _i2.crypto_generichash_blake2b_salt_personal(
    out,
    outlen,
    in$,
    inlen,
    key,
    keylen,
    salt,
    personal,
  );

  @pragma('vm:prefer-inline')
  int crypto_generichash_blake2b_init(
    _i1.Pointer<_i2.crypto_generichash_blake2b_state> state,
    _i1.Pointer<_i1.UnsignedChar> key,
    int keylen,
    int outlen,
  ) => _i2.crypto_generichash_blake2b_init(state, key, keylen, outlen);

  @pragma('vm:prefer-inline')
  int crypto_generichash_blake2b_init_salt_personal(
    _i1.Pointer<_i2.crypto_generichash_blake2b_state> state,
    _i1.Pointer<_i1.UnsignedChar> key,
    int keylen,
    int outlen,
    _i1.Pointer<_i1.UnsignedChar> salt,
    _i1.Pointer<_i1.UnsignedChar> personal,
  ) => _i2.crypto_generichash_blake2b_init_salt_personal(
    state,
    key,
    keylen,
    outlen,
    salt,
    personal,
  );

  @pragma('vm:prefer-inline')
  int crypto_generichash_blake2b_update(
    _i1.Pointer<_i2.crypto_generichash_blake2b_state> state,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
  ) => _i2.crypto_generichash_blake2b_update(state, in$, inlen);

  @pragma('vm:prefer-inline')
  int crypto_generichash_blake2b_final(
    _i1.Pointer<_i2.crypto_generichash_blake2b_state> state,
    _i1.Pointer<_i1.UnsignedChar> out,
    int outlen,
  ) => _i2.crypto_generichash_blake2b_final(state, out, outlen);

  @pragma('vm:prefer-inline')
  void crypto_generichash_blake2b_keygen(_i1.Pointer<_i1.UnsignedChar> k) =>
      _i2.crypto_generichash_blake2b_keygen(k);

  @pragma('vm:prefer-inline')
  int crypto_generichash_bytes_min() => _i2.crypto_generichash_bytes_min();

  @pragma('vm:prefer-inline')
  int crypto_generichash_bytes_max() => _i2.crypto_generichash_bytes_max();

  @pragma('vm:prefer-inline')
  int crypto_generichash_bytes() => _i2.crypto_generichash_bytes();

  @pragma('vm:prefer-inline')
  int crypto_generichash_keybytes_min() =>
      _i2.crypto_generichash_keybytes_min();

  @pragma('vm:prefer-inline')
  int crypto_generichash_keybytes_max() =>
      _i2.crypto_generichash_keybytes_max();

  @pragma('vm:prefer-inline')
  int crypto_generichash_keybytes() => _i2.crypto_generichash_keybytes();

  @pragma('vm:prefer-inline')
  _i1.Pointer<_i1.Char> crypto_generichash_primitive() =>
      _i2.crypto_generichash_primitive();

  @pragma('vm:prefer-inline')
  int crypto_generichash_statebytes() => _i2.crypto_generichash_statebytes();

  @pragma('vm:prefer-inline')
  int crypto_generichash(
    _i1.Pointer<_i1.UnsignedChar> out,
    int outlen,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
    _i1.Pointer<_i1.UnsignedChar> key,
    int keylen,
  ) => _i2.crypto_generichash(out, outlen, in$, inlen, key, keylen);

  @pragma('vm:prefer-inline')
  int crypto_generichash_init(
    _i1.Pointer<_i2.crypto_generichash_blake2b_state> state,
    _i1.Pointer<_i1.UnsignedChar> key,
    int keylen,
    int outlen,
  ) => _i2.crypto_generichash_init(state, key, keylen, outlen);

  @pragma('vm:prefer-inline')
  int crypto_generichash_update(
    _i1.Pointer<_i2.crypto_generichash_blake2b_state> state,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
  ) => _i2.crypto_generichash_update(state, in$, inlen);

  @pragma('vm:prefer-inline')
  int crypto_generichash_final(
    _i1.Pointer<_i2.crypto_generichash_blake2b_state> state,
    _i1.Pointer<_i1.UnsignedChar> out,
    int outlen,
  ) => _i2.crypto_generichash_final(state, out, outlen);

  @pragma('vm:prefer-inline')
  void crypto_generichash_keygen(_i1.Pointer<_i1.UnsignedChar> k) =>
      _i2.crypto_generichash_keygen(k);

  @pragma('vm:prefer-inline')
  int crypto_hash_bytes() => _i2.crypto_hash_bytes();

  @pragma('vm:prefer-inline')
  int crypto_hash(
    _i1.Pointer<_i1.UnsignedChar> out,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
  ) => _i2.crypto_hash(out, in$, inlen);

  @pragma('vm:prefer-inline')
  _i1.Pointer<_i1.Char> crypto_hash_primitive() => _i2.crypto_hash_primitive();

  @pragma('vm:prefer-inline')
  int crypto_kdf_blake2b_bytes_min() => _i2.crypto_kdf_blake2b_bytes_min();

  @pragma('vm:prefer-inline')
  int crypto_kdf_blake2b_bytes_max() => _i2.crypto_kdf_blake2b_bytes_max();

  @pragma('vm:prefer-inline')
  int crypto_kdf_blake2b_contextbytes() =>
      _i2.crypto_kdf_blake2b_contextbytes();

  @pragma('vm:prefer-inline')
  int crypto_kdf_blake2b_keybytes() => _i2.crypto_kdf_blake2b_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_kdf_blake2b_derive_from_key(
    _i1.Pointer<_i1.UnsignedChar> subkey,
    int subkey_len,
    int subkey_id,
    _i1.Pointer<_i1.Char> ctx,
    _i1.Pointer<_i1.UnsignedChar> key,
  ) => _i2.crypto_kdf_blake2b_derive_from_key(
    subkey,
    subkey_len,
    subkey_id,
    ctx,
    key,
  );

  @pragma('vm:prefer-inline')
  int crypto_kdf_bytes_min() => _i2.crypto_kdf_bytes_min();

  @pragma('vm:prefer-inline')
  int crypto_kdf_bytes_max() => _i2.crypto_kdf_bytes_max();

  @pragma('vm:prefer-inline')
  int crypto_kdf_contextbytes() => _i2.crypto_kdf_contextbytes();

  @pragma('vm:prefer-inline')
  int crypto_kdf_keybytes() => _i2.crypto_kdf_keybytes();

  @pragma('vm:prefer-inline')
  _i1.Pointer<_i1.Char> crypto_kdf_primitive() => _i2.crypto_kdf_primitive();

  @pragma('vm:prefer-inline')
  int crypto_kdf_derive_from_key(
    _i1.Pointer<_i1.UnsignedChar> subkey,
    int subkey_len,
    int subkey_id,
    _i1.Pointer<_i1.Char> ctx,
    _i1.Pointer<_i1.UnsignedChar> key,
  ) => _i2.crypto_kdf_derive_from_key(subkey, subkey_len, subkey_id, ctx, key);

  @pragma('vm:prefer-inline')
  void crypto_kdf_keygen(_i1.Pointer<_i1.UnsignedChar> k) =>
      _i2.crypto_kdf_keygen(k);

  @pragma('vm:prefer-inline')
  int crypto_kdf_hkdf_sha256_keybytes() =>
      _i2.crypto_kdf_hkdf_sha256_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_kdf_hkdf_sha256_bytes_min() =>
      _i2.crypto_kdf_hkdf_sha256_bytes_min();

  @pragma('vm:prefer-inline')
  int crypto_kdf_hkdf_sha256_bytes_max() =>
      _i2.crypto_kdf_hkdf_sha256_bytes_max();

  @pragma('vm:prefer-inline')
  int crypto_kdf_hkdf_sha256_extract(
    _i1.Pointer<_i1.UnsignedChar> prk,
    _i1.Pointer<_i1.UnsignedChar> salt,
    int salt_len,
    _i1.Pointer<_i1.UnsignedChar> ikm,
    int ikm_len,
  ) => _i2.crypto_kdf_hkdf_sha256_extract(prk, salt, salt_len, ikm, ikm_len);

  @pragma('vm:prefer-inline')
  void crypto_kdf_hkdf_sha256_keygen(_i1.Pointer<_i1.UnsignedChar> prk) =>
      _i2.crypto_kdf_hkdf_sha256_keygen(prk);

  @pragma('vm:prefer-inline')
  int crypto_kdf_hkdf_sha256_expand(
    _i1.Pointer<_i1.UnsignedChar> out,
    int out_len,
    _i1.Pointer<_i1.Char> ctx,
    int ctx_len,
    _i1.Pointer<_i1.UnsignedChar> prk,
  ) => _i2.crypto_kdf_hkdf_sha256_expand(out, out_len, ctx, ctx_len, prk);

  @pragma('vm:prefer-inline')
  int crypto_kdf_hkdf_sha256_statebytes() =>
      _i2.crypto_kdf_hkdf_sha256_statebytes();

  @pragma('vm:prefer-inline')
  int crypto_kdf_hkdf_sha256_extract_init(
    _i1.Pointer<_i2.crypto_kdf_hkdf_sha256_state> state,
    _i1.Pointer<_i1.UnsignedChar> salt,
    int salt_len,
  ) => _i2.crypto_kdf_hkdf_sha256_extract_init(state, salt, salt_len);

  @pragma('vm:prefer-inline')
  int crypto_kdf_hkdf_sha256_extract_update(
    _i1.Pointer<_i2.crypto_kdf_hkdf_sha256_state> state,
    _i1.Pointer<_i1.UnsignedChar> ikm,
    int ikm_len,
  ) => _i2.crypto_kdf_hkdf_sha256_extract_update(state, ikm, ikm_len);

  @pragma('vm:prefer-inline')
  int crypto_kdf_hkdf_sha256_extract_final(
    _i1.Pointer<_i2.crypto_kdf_hkdf_sha256_state> state,
    _i1.Pointer<_i1.UnsignedChar> prk,
  ) => _i2.crypto_kdf_hkdf_sha256_extract_final(state, prk);

  @pragma('vm:prefer-inline')
  int crypto_kdf_hkdf_sha512_keybytes() =>
      _i2.crypto_kdf_hkdf_sha512_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_kdf_hkdf_sha512_bytes_min() =>
      _i2.crypto_kdf_hkdf_sha512_bytes_min();

  @pragma('vm:prefer-inline')
  int crypto_kdf_hkdf_sha512_bytes_max() =>
      _i2.crypto_kdf_hkdf_sha512_bytes_max();

  @pragma('vm:prefer-inline')
  int crypto_kdf_hkdf_sha512_extract(
    _i1.Pointer<_i1.UnsignedChar> prk,
    _i1.Pointer<_i1.UnsignedChar> salt,
    int salt_len,
    _i1.Pointer<_i1.UnsignedChar> ikm,
    int ikm_len,
  ) => _i2.crypto_kdf_hkdf_sha512_extract(prk, salt, salt_len, ikm, ikm_len);

  @pragma('vm:prefer-inline')
  void crypto_kdf_hkdf_sha512_keygen(_i1.Pointer<_i1.UnsignedChar> prk) =>
      _i2.crypto_kdf_hkdf_sha512_keygen(prk);

  @pragma('vm:prefer-inline')
  int crypto_kdf_hkdf_sha512_expand(
    _i1.Pointer<_i1.UnsignedChar> out,
    int out_len,
    _i1.Pointer<_i1.Char> ctx,
    int ctx_len,
    _i1.Pointer<_i1.UnsignedChar> prk,
  ) => _i2.crypto_kdf_hkdf_sha512_expand(out, out_len, ctx, ctx_len, prk);

  @pragma('vm:prefer-inline')
  int crypto_kdf_hkdf_sha512_statebytes() =>
      _i2.crypto_kdf_hkdf_sha512_statebytes();

  @pragma('vm:prefer-inline')
  int crypto_kdf_hkdf_sha512_extract_init(
    _i1.Pointer<_i2.crypto_kdf_hkdf_sha512_state> state,
    _i1.Pointer<_i1.UnsignedChar> salt,
    int salt_len,
  ) => _i2.crypto_kdf_hkdf_sha512_extract_init(state, salt, salt_len);

  @pragma('vm:prefer-inline')
  int crypto_kdf_hkdf_sha512_extract_update(
    _i1.Pointer<_i2.crypto_kdf_hkdf_sha512_state> state,
    _i1.Pointer<_i1.UnsignedChar> ikm,
    int ikm_len,
  ) => _i2.crypto_kdf_hkdf_sha512_extract_update(state, ikm, ikm_len);

  @pragma('vm:prefer-inline')
  int crypto_kdf_hkdf_sha512_extract_final(
    _i1.Pointer<_i2.crypto_kdf_hkdf_sha512_state> state,
    _i1.Pointer<_i1.UnsignedChar> prk,
  ) => _i2.crypto_kdf_hkdf_sha512_extract_final(state, prk);

  @pragma('vm:prefer-inline')
  int crypto_kx_publickeybytes() => _i2.crypto_kx_publickeybytes();

  @pragma('vm:prefer-inline')
  int crypto_kx_secretkeybytes() => _i2.crypto_kx_secretkeybytes();

  @pragma('vm:prefer-inline')
  int crypto_kx_seedbytes() => _i2.crypto_kx_seedbytes();

  @pragma('vm:prefer-inline')
  int crypto_kx_sessionkeybytes() => _i2.crypto_kx_sessionkeybytes();

  @pragma('vm:prefer-inline')
  _i1.Pointer<_i1.Char> crypto_kx_primitive() => _i2.crypto_kx_primitive();

  @pragma('vm:prefer-inline')
  int crypto_kx_seed_keypair(
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
    _i1.Pointer<_i1.UnsignedChar> seed,
  ) => _i2.crypto_kx_seed_keypair(pk, sk, seed);

  @pragma('vm:prefer-inline')
  int crypto_kx_keypair(
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_kx_keypair(pk, sk);

  @pragma('vm:prefer-inline')
  int crypto_kx_client_session_keys(
    _i1.Pointer<_i1.UnsignedChar> rx,
    _i1.Pointer<_i1.UnsignedChar> tx,
    _i1.Pointer<_i1.UnsignedChar> client_pk,
    _i1.Pointer<_i1.UnsignedChar> client_sk,
    _i1.Pointer<_i1.UnsignedChar> server_pk,
  ) => _i2.crypto_kx_client_session_keys(
    rx,
    tx,
    client_pk,
    client_sk,
    server_pk,
  );

  @pragma('vm:prefer-inline')
  int crypto_kx_server_session_keys(
    _i1.Pointer<_i1.UnsignedChar> rx,
    _i1.Pointer<_i1.UnsignedChar> tx,
    _i1.Pointer<_i1.UnsignedChar> server_pk,
    _i1.Pointer<_i1.UnsignedChar> server_sk,
    _i1.Pointer<_i1.UnsignedChar> client_pk,
  ) => _i2.crypto_kx_server_session_keys(
    rx,
    tx,
    server_pk,
    server_sk,
    client_pk,
  );

  @pragma('vm:prefer-inline')
  int crypto_onetimeauth_poly1305_statebytes() =>
      _i2.crypto_onetimeauth_poly1305_statebytes();

  @pragma('vm:prefer-inline')
  int crypto_onetimeauth_poly1305_bytes() =>
      _i2.crypto_onetimeauth_poly1305_bytes();

  @pragma('vm:prefer-inline')
  int crypto_onetimeauth_poly1305_keybytes() =>
      _i2.crypto_onetimeauth_poly1305_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_onetimeauth_poly1305(
    _i1.Pointer<_i1.UnsignedChar> out,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_onetimeauth_poly1305(out, in$, inlen, k);

  @pragma('vm:prefer-inline')
  int crypto_onetimeauth_poly1305_verify(
    _i1.Pointer<_i1.UnsignedChar> h,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_onetimeauth_poly1305_verify(h, in$, inlen, k);

  @pragma('vm:prefer-inline')
  int crypto_onetimeauth_poly1305_init(
    _i1.Pointer<_i2.crypto_onetimeauth_poly1305_state> state,
    _i1.Pointer<_i1.UnsignedChar> key,
  ) => _i2.crypto_onetimeauth_poly1305_init(state, key);

  @pragma('vm:prefer-inline')
  int crypto_onetimeauth_poly1305_update(
    _i1.Pointer<_i2.crypto_onetimeauth_poly1305_state> state,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
  ) => _i2.crypto_onetimeauth_poly1305_update(state, in$, inlen);

  @pragma('vm:prefer-inline')
  int crypto_onetimeauth_poly1305_final(
    _i1.Pointer<_i2.crypto_onetimeauth_poly1305_state> state,
    _i1.Pointer<_i1.UnsignedChar> out,
  ) => _i2.crypto_onetimeauth_poly1305_final(state, out);

  @pragma('vm:prefer-inline')
  void crypto_onetimeauth_poly1305_keygen(_i1.Pointer<_i1.UnsignedChar> k) =>
      _i2.crypto_onetimeauth_poly1305_keygen(k);

  @pragma('vm:prefer-inline')
  int crypto_onetimeauth_statebytes() => _i2.crypto_onetimeauth_statebytes();

  @pragma('vm:prefer-inline')
  int crypto_onetimeauth_bytes() => _i2.crypto_onetimeauth_bytes();

  @pragma('vm:prefer-inline')
  int crypto_onetimeauth_keybytes() => _i2.crypto_onetimeauth_keybytes();

  @pragma('vm:prefer-inline')
  _i1.Pointer<_i1.Char> crypto_onetimeauth_primitive() =>
      _i2.crypto_onetimeauth_primitive();

  @pragma('vm:prefer-inline')
  int crypto_onetimeauth(
    _i1.Pointer<_i1.UnsignedChar> out,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_onetimeauth(out, in$, inlen, k);

  @pragma('vm:prefer-inline')
  int crypto_onetimeauth_verify(
    _i1.Pointer<_i1.UnsignedChar> h,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_onetimeauth_verify(h, in$, inlen, k);

  @pragma('vm:prefer-inline')
  int crypto_onetimeauth_init(
    _i1.Pointer<_i2.crypto_onetimeauth_poly1305_state> state,
    _i1.Pointer<_i1.UnsignedChar> key,
  ) => _i2.crypto_onetimeauth_init(state, key);

  @pragma('vm:prefer-inline')
  int crypto_onetimeauth_update(
    _i1.Pointer<_i2.crypto_onetimeauth_poly1305_state> state,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
  ) => _i2.crypto_onetimeauth_update(state, in$, inlen);

  @pragma('vm:prefer-inline')
  int crypto_onetimeauth_final(
    _i1.Pointer<_i2.crypto_onetimeauth_poly1305_state> state,
    _i1.Pointer<_i1.UnsignedChar> out,
  ) => _i2.crypto_onetimeauth_final(state, out);

  @pragma('vm:prefer-inline')
  void crypto_onetimeauth_keygen(_i1.Pointer<_i1.UnsignedChar> k) =>
      _i2.crypto_onetimeauth_keygen(k);

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2i_alg_argon2i13() =>
      _i2.crypto_pwhash_argon2i_alg_argon2i13();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2i_bytes_min() =>
      _i2.crypto_pwhash_argon2i_bytes_min();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2i_bytes_max() =>
      _i2.crypto_pwhash_argon2i_bytes_max();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2i_passwd_min() =>
      _i2.crypto_pwhash_argon2i_passwd_min();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2i_passwd_max() =>
      _i2.crypto_pwhash_argon2i_passwd_max();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2i_saltbytes() =>
      _i2.crypto_pwhash_argon2i_saltbytes();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2i_strbytes() => _i2.crypto_pwhash_argon2i_strbytes();

  @pragma('vm:prefer-inline')
  _i1.Pointer<_i1.Char> crypto_pwhash_argon2i_strprefix() =>
      _i2.crypto_pwhash_argon2i_strprefix();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2i_opslimit_min() =>
      _i2.crypto_pwhash_argon2i_opslimit_min();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2i_opslimit_max() =>
      _i2.crypto_pwhash_argon2i_opslimit_max();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2i_memlimit_min() =>
      _i2.crypto_pwhash_argon2i_memlimit_min();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2i_memlimit_max() =>
      _i2.crypto_pwhash_argon2i_memlimit_max();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2i_opslimit_interactive() =>
      _i2.crypto_pwhash_argon2i_opslimit_interactive();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2i_memlimit_interactive() =>
      _i2.crypto_pwhash_argon2i_memlimit_interactive();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2i_opslimit_moderate() =>
      _i2.crypto_pwhash_argon2i_opslimit_moderate();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2i_memlimit_moderate() =>
      _i2.crypto_pwhash_argon2i_memlimit_moderate();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2i_opslimit_sensitive() =>
      _i2.crypto_pwhash_argon2i_opslimit_sensitive();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2i_memlimit_sensitive() =>
      _i2.crypto_pwhash_argon2i_memlimit_sensitive();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2i(
    _i1.Pointer<_i1.UnsignedChar> out,
    int outlen,
    _i1.Pointer<_i1.Char> passwd,
    int passwdlen,
    _i1.Pointer<_i1.UnsignedChar> salt,
    int opslimit,
    int memlimit,
    int alg,
  ) => _i2.crypto_pwhash_argon2i(
    out,
    outlen,
    passwd,
    passwdlen,
    salt,
    opslimit,
    memlimit,
    alg,
  );

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2i_str(
    _i1.Pointer<_i1.Char> out,
    _i1.Pointer<_i1.Char> passwd,
    int passwdlen,
    int opslimit,
    int memlimit,
  ) =>
      _i2.crypto_pwhash_argon2i_str(out, passwd, passwdlen, opslimit, memlimit);

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2i_str_verify(
    _i1.Pointer<_i1.Char> str,
    _i1.Pointer<_i1.Char> passwd,
    int passwdlen,
  ) => _i2.crypto_pwhash_argon2i_str_verify(str, passwd, passwdlen);

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2i_str_needs_rehash(
    _i1.Pointer<_i1.Char> str,
    int opslimit,
    int memlimit,
  ) => _i2.crypto_pwhash_argon2i_str_needs_rehash(str, opslimit, memlimit);

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2id_alg_argon2id13() =>
      _i2.crypto_pwhash_argon2id_alg_argon2id13();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2id_bytes_min() =>
      _i2.crypto_pwhash_argon2id_bytes_min();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2id_bytes_max() =>
      _i2.crypto_pwhash_argon2id_bytes_max();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2id_passwd_min() =>
      _i2.crypto_pwhash_argon2id_passwd_min();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2id_passwd_max() =>
      _i2.crypto_pwhash_argon2id_passwd_max();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2id_saltbytes() =>
      _i2.crypto_pwhash_argon2id_saltbytes();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2id_strbytes() =>
      _i2.crypto_pwhash_argon2id_strbytes();

  @pragma('vm:prefer-inline')
  _i1.Pointer<_i1.Char> crypto_pwhash_argon2id_strprefix() =>
      _i2.crypto_pwhash_argon2id_strprefix();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2id_opslimit_min() =>
      _i2.crypto_pwhash_argon2id_opslimit_min();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2id_opslimit_max() =>
      _i2.crypto_pwhash_argon2id_opslimit_max();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2id_memlimit_min() =>
      _i2.crypto_pwhash_argon2id_memlimit_min();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2id_memlimit_max() =>
      _i2.crypto_pwhash_argon2id_memlimit_max();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2id_opslimit_interactive() =>
      _i2.crypto_pwhash_argon2id_opslimit_interactive();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2id_memlimit_interactive() =>
      _i2.crypto_pwhash_argon2id_memlimit_interactive();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2id_opslimit_moderate() =>
      _i2.crypto_pwhash_argon2id_opslimit_moderate();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2id_memlimit_moderate() =>
      _i2.crypto_pwhash_argon2id_memlimit_moderate();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2id_opslimit_sensitive() =>
      _i2.crypto_pwhash_argon2id_opslimit_sensitive();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2id_memlimit_sensitive() =>
      _i2.crypto_pwhash_argon2id_memlimit_sensitive();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2id(
    _i1.Pointer<_i1.UnsignedChar> out,
    int outlen,
    _i1.Pointer<_i1.Char> passwd,
    int passwdlen,
    _i1.Pointer<_i1.UnsignedChar> salt,
    int opslimit,
    int memlimit,
    int alg,
  ) => _i2.crypto_pwhash_argon2id(
    out,
    outlen,
    passwd,
    passwdlen,
    salt,
    opslimit,
    memlimit,
    alg,
  );

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2id_str(
    _i1.Pointer<_i1.Char> out,
    _i1.Pointer<_i1.Char> passwd,
    int passwdlen,
    int opslimit,
    int memlimit,
  ) => _i2.crypto_pwhash_argon2id_str(
    out,
    passwd,
    passwdlen,
    opslimit,
    memlimit,
  );

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2id_str_verify(
    _i1.Pointer<_i1.Char> str,
    _i1.Pointer<_i1.Char> passwd,
    int passwdlen,
  ) => _i2.crypto_pwhash_argon2id_str_verify(str, passwd, passwdlen);

  @pragma('vm:prefer-inline')
  int crypto_pwhash_argon2id_str_needs_rehash(
    _i1.Pointer<_i1.Char> str,
    int opslimit,
    int memlimit,
  ) => _i2.crypto_pwhash_argon2id_str_needs_rehash(str, opslimit, memlimit);

  @pragma('vm:prefer-inline')
  int crypto_pwhash_alg_argon2i13() => _i2.crypto_pwhash_alg_argon2i13();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_alg_argon2id13() => _i2.crypto_pwhash_alg_argon2id13();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_alg_default() => _i2.crypto_pwhash_alg_default();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_bytes_min() => _i2.crypto_pwhash_bytes_min();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_bytes_max() => _i2.crypto_pwhash_bytes_max();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_passwd_min() => _i2.crypto_pwhash_passwd_min();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_passwd_max() => _i2.crypto_pwhash_passwd_max();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_saltbytes() => _i2.crypto_pwhash_saltbytes();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_strbytes() => _i2.crypto_pwhash_strbytes();

  @pragma('vm:prefer-inline')
  _i1.Pointer<_i1.Char> crypto_pwhash_strprefix() =>
      _i2.crypto_pwhash_strprefix();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_opslimit_min() => _i2.crypto_pwhash_opslimit_min();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_opslimit_max() => _i2.crypto_pwhash_opslimit_max();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_memlimit_min() => _i2.crypto_pwhash_memlimit_min();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_memlimit_max() => _i2.crypto_pwhash_memlimit_max();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_opslimit_interactive() =>
      _i2.crypto_pwhash_opslimit_interactive();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_memlimit_interactive() =>
      _i2.crypto_pwhash_memlimit_interactive();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_opslimit_moderate() =>
      _i2.crypto_pwhash_opslimit_moderate();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_memlimit_moderate() =>
      _i2.crypto_pwhash_memlimit_moderate();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_opslimit_sensitive() =>
      _i2.crypto_pwhash_opslimit_sensitive();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_memlimit_sensitive() =>
      _i2.crypto_pwhash_memlimit_sensitive();

  @pragma('vm:prefer-inline')
  int crypto_pwhash(
    _i1.Pointer<_i1.UnsignedChar> out,
    int outlen,
    _i1.Pointer<_i1.Char> passwd,
    int passwdlen,
    _i1.Pointer<_i1.UnsignedChar> salt,
    int opslimit,
    int memlimit,
    int alg,
  ) => _i2.crypto_pwhash(
    out,
    outlen,
    passwd,
    passwdlen,
    salt,
    opslimit,
    memlimit,
    alg,
  );

  @pragma('vm:prefer-inline')
  int crypto_pwhash_str(
    _i1.Pointer<_i1.Char> out,
    _i1.Pointer<_i1.Char> passwd,
    int passwdlen,
    int opslimit,
    int memlimit,
  ) => _i2.crypto_pwhash_str(out, passwd, passwdlen, opslimit, memlimit);

  @pragma('vm:prefer-inline')
  int crypto_pwhash_str_alg(
    _i1.Pointer<_i1.Char> out,
    _i1.Pointer<_i1.Char> passwd,
    int passwdlen,
    int opslimit,
    int memlimit,
    int alg,
  ) => _i2.crypto_pwhash_str_alg(
    out,
    passwd,
    passwdlen,
    opslimit,
    memlimit,
    alg,
  );

  @pragma('vm:prefer-inline')
  int crypto_pwhash_str_verify(
    _i1.Pointer<_i1.Char> str,
    _i1.Pointer<_i1.Char> passwd,
    int passwdlen,
  ) => _i2.crypto_pwhash_str_verify(str, passwd, passwdlen);

  @pragma('vm:prefer-inline')
  int crypto_pwhash_str_needs_rehash(
    _i1.Pointer<_i1.Char> str,
    int opslimit,
    int memlimit,
  ) => _i2.crypto_pwhash_str_needs_rehash(str, opslimit, memlimit);

  @pragma('vm:prefer-inline')
  _i1.Pointer<_i1.Char> crypto_pwhash_primitive() =>
      _i2.crypto_pwhash_primitive();

  @pragma('vm:prefer-inline')
  int crypto_scalarmult_curve25519_bytes() =>
      _i2.crypto_scalarmult_curve25519_bytes();

  @pragma('vm:prefer-inline')
  int crypto_scalarmult_curve25519_scalarbytes() =>
      _i2.crypto_scalarmult_curve25519_scalarbytes();

  @pragma('vm:prefer-inline')
  int crypto_scalarmult_curve25519(
    _i1.Pointer<_i1.UnsignedChar> q,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> p,
  ) => _i2.crypto_scalarmult_curve25519(q, n, p);

  @pragma('vm:prefer-inline')
  int crypto_scalarmult_curve25519_base(
    _i1.Pointer<_i1.UnsignedChar> q,
    _i1.Pointer<_i1.UnsignedChar> n,
  ) => _i2.crypto_scalarmult_curve25519_base(q, n);

  @pragma('vm:prefer-inline')
  int crypto_scalarmult_bytes() => _i2.crypto_scalarmult_bytes();

  @pragma('vm:prefer-inline')
  int crypto_scalarmult_scalarbytes() => _i2.crypto_scalarmult_scalarbytes();

  @pragma('vm:prefer-inline')
  _i1.Pointer<_i1.Char> crypto_scalarmult_primitive() =>
      _i2.crypto_scalarmult_primitive();

  @pragma('vm:prefer-inline')
  int crypto_scalarmult_base(
    _i1.Pointer<_i1.UnsignedChar> q,
    _i1.Pointer<_i1.UnsignedChar> n,
  ) => _i2.crypto_scalarmult_base(q, n);

  @pragma('vm:prefer-inline')
  int crypto_scalarmult(
    _i1.Pointer<_i1.UnsignedChar> q,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> p,
  ) => _i2.crypto_scalarmult(q, n, p);

  @pragma('vm:prefer-inline')
  int crypto_secretbox_xsalsa20poly1305_keybytes() =>
      _i2.crypto_secretbox_xsalsa20poly1305_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_secretbox_xsalsa20poly1305_noncebytes() =>
      _i2.crypto_secretbox_xsalsa20poly1305_noncebytes();

  @pragma('vm:prefer-inline')
  int crypto_secretbox_xsalsa20poly1305_macbytes() =>
      _i2.crypto_secretbox_xsalsa20poly1305_macbytes();

  @pragma('vm:prefer-inline')
  int crypto_secretbox_xsalsa20poly1305_messagebytes_max() =>
      _i2.crypto_secretbox_xsalsa20poly1305_messagebytes_max();

  @pragma('vm:prefer-inline')
  int crypto_secretbox_xsalsa20poly1305(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_secretbox_xsalsa20poly1305(c, m, mlen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_secretbox_xsalsa20poly1305_open(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_secretbox_xsalsa20poly1305_open(m, c, clen, n, k);

  @pragma('vm:prefer-inline')
  void crypto_secretbox_xsalsa20poly1305_keygen(
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_secretbox_xsalsa20poly1305_keygen(k);

  @pragma('vm:prefer-inline')
  int crypto_secretbox_xsalsa20poly1305_boxzerobytes() =>
      _i2.crypto_secretbox_xsalsa20poly1305_boxzerobytes();

  @pragma('vm:prefer-inline')
  int crypto_secretbox_xsalsa20poly1305_zerobytes() =>
      _i2.crypto_secretbox_xsalsa20poly1305_zerobytes();

  @pragma('vm:prefer-inline')
  int crypto_secretbox_keybytes() => _i2.crypto_secretbox_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_secretbox_noncebytes() => _i2.crypto_secretbox_noncebytes();

  @pragma('vm:prefer-inline')
  int crypto_secretbox_macbytes() => _i2.crypto_secretbox_macbytes();

  @pragma('vm:prefer-inline')
  _i1.Pointer<_i1.Char> crypto_secretbox_primitive() =>
      _i2.crypto_secretbox_primitive();

  @pragma('vm:prefer-inline')
  int crypto_secretbox_messagebytes_max() =>
      _i2.crypto_secretbox_messagebytes_max();

  @pragma('vm:prefer-inline')
  int crypto_secretbox_easy(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_secretbox_easy(c, m, mlen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_secretbox_open_easy(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_secretbox_open_easy(m, c, clen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_secretbox_detached(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> mac,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_secretbox_detached(c, mac, m, mlen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_secretbox_open_detached(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> mac,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_secretbox_open_detached(m, c, mac, clen, n, k);

  @pragma('vm:prefer-inline')
  void crypto_secretbox_keygen(_i1.Pointer<_i1.UnsignedChar> k) =>
      _i2.crypto_secretbox_keygen(k);

  @pragma('vm:prefer-inline')
  int crypto_secretbox_zerobytes() => _i2.crypto_secretbox_zerobytes();

  @pragma('vm:prefer-inline')
  int crypto_secretbox_boxzerobytes() => _i2.crypto_secretbox_boxzerobytes();

  @pragma('vm:prefer-inline')
  int crypto_secretbox(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_secretbox(c, m, mlen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_secretbox_open(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_secretbox_open(m, c, clen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_stream_chacha20_keybytes() =>
      _i2.crypto_stream_chacha20_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_stream_chacha20_noncebytes() =>
      _i2.crypto_stream_chacha20_noncebytes();

  @pragma('vm:prefer-inline')
  int crypto_stream_chacha20_messagebytes_max() =>
      _i2.crypto_stream_chacha20_messagebytes_max();

  @pragma('vm:prefer-inline')
  int crypto_stream_chacha20(
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_stream_chacha20(c, clen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_stream_chacha20_xor(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_stream_chacha20_xor(c, m, mlen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_stream_chacha20_xor_ic(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    int ic,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_stream_chacha20_xor_ic(c, m, mlen, n, ic, k);

  @pragma('vm:prefer-inline')
  void crypto_stream_chacha20_keygen(_i1.Pointer<_i1.UnsignedChar> k) =>
      _i2.crypto_stream_chacha20_keygen(k);

  @pragma('vm:prefer-inline')
  int crypto_stream_chacha20_ietf_keybytes() =>
      _i2.crypto_stream_chacha20_ietf_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_stream_chacha20_ietf_noncebytes() =>
      _i2.crypto_stream_chacha20_ietf_noncebytes();

  @pragma('vm:prefer-inline')
  int crypto_stream_chacha20_ietf_messagebytes_max() =>
      _i2.crypto_stream_chacha20_ietf_messagebytes_max();

  @pragma('vm:prefer-inline')
  int crypto_stream_chacha20_ietf(
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_stream_chacha20_ietf(c, clen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_stream_chacha20_ietf_xor(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_stream_chacha20_ietf_xor(c, m, mlen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_stream_chacha20_ietf_xor_ic(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    int ic,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_stream_chacha20_ietf_xor_ic(c, m, mlen, n, ic, k);

  @pragma('vm:prefer-inline')
  void crypto_stream_chacha20_ietf_keygen(_i1.Pointer<_i1.UnsignedChar> k) =>
      _i2.crypto_stream_chacha20_ietf_keygen(k);

  @pragma('vm:prefer-inline')
  int crypto_secretstream_xchacha20poly1305_abytes() =>
      _i2.crypto_secretstream_xchacha20poly1305_abytes();

  @pragma('vm:prefer-inline')
  int crypto_secretstream_xchacha20poly1305_headerbytes() =>
      _i2.crypto_secretstream_xchacha20poly1305_headerbytes();

  @pragma('vm:prefer-inline')
  int crypto_secretstream_xchacha20poly1305_keybytes() =>
      _i2.crypto_secretstream_xchacha20poly1305_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_secretstream_xchacha20poly1305_messagebytes_max() =>
      _i2.crypto_secretstream_xchacha20poly1305_messagebytes_max();

  @pragma('vm:prefer-inline')
  int crypto_secretstream_xchacha20poly1305_tag_message() =>
      _i2.crypto_secretstream_xchacha20poly1305_tag_message();

  @pragma('vm:prefer-inline')
  int crypto_secretstream_xchacha20poly1305_tag_push() =>
      _i2.crypto_secretstream_xchacha20poly1305_tag_push();

  @pragma('vm:prefer-inline')
  int crypto_secretstream_xchacha20poly1305_tag_rekey() =>
      _i2.crypto_secretstream_xchacha20poly1305_tag_rekey();

  @pragma('vm:prefer-inline')
  int crypto_secretstream_xchacha20poly1305_tag_final() =>
      _i2.crypto_secretstream_xchacha20poly1305_tag_final();

  @pragma('vm:prefer-inline')
  int crypto_secretstream_xchacha20poly1305_statebytes() =>
      _i2.crypto_secretstream_xchacha20poly1305_statebytes();

  @pragma('vm:prefer-inline')
  void crypto_secretstream_xchacha20poly1305_keygen(
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_secretstream_xchacha20poly1305_keygen(k);

  @pragma('vm:prefer-inline')
  int crypto_secretstream_xchacha20poly1305_init_push(
    _i1.Pointer<_i2.crypto_secretstream_xchacha20poly1305_state> state,
    _i1.Pointer<_i1.UnsignedChar> header,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_secretstream_xchacha20poly1305_init_push(state, header, k);

  @pragma('vm:prefer-inline')
  int crypto_secretstream_xchacha20poly1305_push(
    _i1.Pointer<_i2.crypto_secretstream_xchacha20poly1305_state> state,
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedLongLong> clen_p,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
    int tag,
  ) => _i2.crypto_secretstream_xchacha20poly1305_push(
    state,
    c,
    clen_p,
    m,
    mlen,
    ad,
    adlen,
    tag,
  );

  @pragma('vm:prefer-inline')
  int crypto_secretstream_xchacha20poly1305_init_pull(
    _i1.Pointer<_i2.crypto_secretstream_xchacha20poly1305_state> state,
    _i1.Pointer<_i1.UnsignedChar> header,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_secretstream_xchacha20poly1305_init_pull(state, header, k);

  @pragma('vm:prefer-inline')
  int crypto_secretstream_xchacha20poly1305_pull(
    _i1.Pointer<_i2.crypto_secretstream_xchacha20poly1305_state> state,
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedLongLong> mlen_p,
    _i1.Pointer<_i1.UnsignedChar> tag_p,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> ad,
    int adlen,
  ) => _i2.crypto_secretstream_xchacha20poly1305_pull(
    state,
    m,
    mlen_p,
    tag_p,
    c,
    clen,
    ad,
    adlen,
  );

  @pragma('vm:prefer-inline')
  void crypto_secretstream_xchacha20poly1305_rekey(
    _i1.Pointer<_i2.crypto_secretstream_xchacha20poly1305_state> state,
  ) => _i2.crypto_secretstream_xchacha20poly1305_rekey(state);

  @pragma('vm:prefer-inline')
  int crypto_shorthash_siphash24_bytes() =>
      _i2.crypto_shorthash_siphash24_bytes();

  @pragma('vm:prefer-inline')
  int crypto_shorthash_siphash24_keybytes() =>
      _i2.crypto_shorthash_siphash24_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_shorthash_siphash24(
    _i1.Pointer<_i1.UnsignedChar> out,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_shorthash_siphash24(out, in$, inlen, k);

  @pragma('vm:prefer-inline')
  int crypto_shorthash_siphashx24_bytes() =>
      _i2.crypto_shorthash_siphashx24_bytes();

  @pragma('vm:prefer-inline')
  int crypto_shorthash_siphashx24_keybytes() =>
      _i2.crypto_shorthash_siphashx24_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_shorthash_siphashx24(
    _i1.Pointer<_i1.UnsignedChar> out,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_shorthash_siphashx24(out, in$, inlen, k);

  @pragma('vm:prefer-inline')
  int crypto_shorthash_bytes() => _i2.crypto_shorthash_bytes();

  @pragma('vm:prefer-inline')
  int crypto_shorthash_keybytes() => _i2.crypto_shorthash_keybytes();

  @pragma('vm:prefer-inline')
  _i1.Pointer<_i1.Char> crypto_shorthash_primitive() =>
      _i2.crypto_shorthash_primitive();

  @pragma('vm:prefer-inline')
  int crypto_shorthash(
    _i1.Pointer<_i1.UnsignedChar> out,
    _i1.Pointer<_i1.UnsignedChar> in$,
    int inlen,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_shorthash(out, in$, inlen, k);

  @pragma('vm:prefer-inline')
  void crypto_shorthash_keygen(_i1.Pointer<_i1.UnsignedChar> k) =>
      _i2.crypto_shorthash_keygen(k);

  @pragma('vm:prefer-inline')
  int crypto_sign_ed25519ph_statebytes() =>
      _i2.crypto_sign_ed25519ph_statebytes();

  @pragma('vm:prefer-inline')
  int crypto_sign_ed25519_bytes() => _i2.crypto_sign_ed25519_bytes();

  @pragma('vm:prefer-inline')
  int crypto_sign_ed25519_seedbytes() => _i2.crypto_sign_ed25519_seedbytes();

  @pragma('vm:prefer-inline')
  int crypto_sign_ed25519_publickeybytes() =>
      _i2.crypto_sign_ed25519_publickeybytes();

  @pragma('vm:prefer-inline')
  int crypto_sign_ed25519_secretkeybytes() =>
      _i2.crypto_sign_ed25519_secretkeybytes();

  @pragma('vm:prefer-inline')
  int crypto_sign_ed25519_messagebytes_max() =>
      _i2.crypto_sign_ed25519_messagebytes_max();

  @pragma('vm:prefer-inline')
  int crypto_sign_ed25519(
    _i1.Pointer<_i1.UnsignedChar> sm,
    _i1.Pointer<_i1.UnsignedLongLong> smlen_p,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_sign_ed25519(sm, smlen_p, m, mlen, sk);

  @pragma('vm:prefer-inline')
  int crypto_sign_ed25519_open(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedLongLong> mlen_p,
    _i1.Pointer<_i1.UnsignedChar> sm,
    int smlen,
    _i1.Pointer<_i1.UnsignedChar> pk,
  ) => _i2.crypto_sign_ed25519_open(m, mlen_p, sm, smlen, pk);

  @pragma('vm:prefer-inline')
  int crypto_sign_ed25519_detached(
    _i1.Pointer<_i1.UnsignedChar> sig,
    _i1.Pointer<_i1.UnsignedLongLong> siglen_p,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_sign_ed25519_detached(sig, siglen_p, m, mlen, sk);

  @pragma('vm:prefer-inline')
  int crypto_sign_ed25519_verify_detached(
    _i1.Pointer<_i1.UnsignedChar> sig,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> pk,
  ) => _i2.crypto_sign_ed25519_verify_detached(sig, m, mlen, pk);

  @pragma('vm:prefer-inline')
  int crypto_sign_ed25519_keypair(
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_sign_ed25519_keypair(pk, sk);

  @pragma('vm:prefer-inline')
  int crypto_sign_ed25519_seed_keypair(
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
    _i1.Pointer<_i1.UnsignedChar> seed,
  ) => _i2.crypto_sign_ed25519_seed_keypair(pk, sk, seed);

  @pragma('vm:prefer-inline')
  int crypto_sign_ed25519_pk_to_curve25519(
    _i1.Pointer<_i1.UnsignedChar> curve25519_pk,
    _i1.Pointer<_i1.UnsignedChar> ed25519_pk,
  ) => _i2.crypto_sign_ed25519_pk_to_curve25519(curve25519_pk, ed25519_pk);

  @pragma('vm:prefer-inline')
  int crypto_sign_ed25519_sk_to_curve25519(
    _i1.Pointer<_i1.UnsignedChar> curve25519_sk,
    _i1.Pointer<_i1.UnsignedChar> ed25519_sk,
  ) => _i2.crypto_sign_ed25519_sk_to_curve25519(curve25519_sk, ed25519_sk);

  @pragma('vm:prefer-inline')
  int crypto_sign_ed25519_sk_to_seed(
    _i1.Pointer<_i1.UnsignedChar> seed,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_sign_ed25519_sk_to_seed(seed, sk);

  @pragma('vm:prefer-inline')
  int crypto_sign_ed25519_sk_to_pk(
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_sign_ed25519_sk_to_pk(pk, sk);

  @pragma('vm:prefer-inline')
  int crypto_sign_ed25519ph_init(
    _i1.Pointer<_i2.crypto_sign_ed25519ph_state> state,
  ) => _i2.crypto_sign_ed25519ph_init(state);

  @pragma('vm:prefer-inline')
  int crypto_sign_ed25519ph_update(
    _i1.Pointer<_i2.crypto_sign_ed25519ph_state> state,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
  ) => _i2.crypto_sign_ed25519ph_update(state, m, mlen);

  @pragma('vm:prefer-inline')
  int crypto_sign_ed25519ph_final_create(
    _i1.Pointer<_i2.crypto_sign_ed25519ph_state> state,
    _i1.Pointer<_i1.UnsignedChar> sig,
    _i1.Pointer<_i1.UnsignedLongLong> siglen_p,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_sign_ed25519ph_final_create(state, sig, siglen_p, sk);

  @pragma('vm:prefer-inline')
  int crypto_sign_ed25519ph_final_verify(
    _i1.Pointer<_i2.crypto_sign_ed25519ph_state> state,
    _i1.Pointer<_i1.UnsignedChar> sig,
    _i1.Pointer<_i1.UnsignedChar> pk,
  ) => _i2.crypto_sign_ed25519ph_final_verify(state, sig, pk);

  @pragma('vm:prefer-inline')
  int crypto_sign_statebytes() => _i2.crypto_sign_statebytes();

  @pragma('vm:prefer-inline')
  int crypto_sign_bytes() => _i2.crypto_sign_bytes();

  @pragma('vm:prefer-inline')
  int crypto_sign_seedbytes() => _i2.crypto_sign_seedbytes();

  @pragma('vm:prefer-inline')
  int crypto_sign_publickeybytes() => _i2.crypto_sign_publickeybytes();

  @pragma('vm:prefer-inline')
  int crypto_sign_secretkeybytes() => _i2.crypto_sign_secretkeybytes();

  @pragma('vm:prefer-inline')
  int crypto_sign_messagebytes_max() => _i2.crypto_sign_messagebytes_max();

  @pragma('vm:prefer-inline')
  _i1.Pointer<_i1.Char> crypto_sign_primitive() => _i2.crypto_sign_primitive();

  @pragma('vm:prefer-inline')
  int crypto_sign_seed_keypair(
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
    _i1.Pointer<_i1.UnsignedChar> seed,
  ) => _i2.crypto_sign_seed_keypair(pk, sk, seed);

  @pragma('vm:prefer-inline')
  int crypto_sign_keypair(
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_sign_keypair(pk, sk);

  @pragma('vm:prefer-inline')
  int crypto_sign(
    _i1.Pointer<_i1.UnsignedChar> sm,
    _i1.Pointer<_i1.UnsignedLongLong> smlen_p,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_sign(sm, smlen_p, m, mlen, sk);

  @pragma('vm:prefer-inline')
  int crypto_sign_open(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedLongLong> mlen_p,
    _i1.Pointer<_i1.UnsignedChar> sm,
    int smlen,
    _i1.Pointer<_i1.UnsignedChar> pk,
  ) => _i2.crypto_sign_open(m, mlen_p, sm, smlen, pk);

  @pragma('vm:prefer-inline')
  int crypto_sign_detached(
    _i1.Pointer<_i1.UnsignedChar> sig,
    _i1.Pointer<_i1.UnsignedLongLong> siglen_p,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_sign_detached(sig, siglen_p, m, mlen, sk);

  @pragma('vm:prefer-inline')
  int crypto_sign_verify_detached(
    _i1.Pointer<_i1.UnsignedChar> sig,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> pk,
  ) => _i2.crypto_sign_verify_detached(sig, m, mlen, pk);

  @pragma('vm:prefer-inline')
  int crypto_sign_init(_i1.Pointer<_i2.crypto_sign_ed25519ph_state> state) =>
      _i2.crypto_sign_init(state);

  @pragma('vm:prefer-inline')
  int crypto_sign_update(
    _i1.Pointer<_i2.crypto_sign_ed25519ph_state> state,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
  ) => _i2.crypto_sign_update(state, m, mlen);

  @pragma('vm:prefer-inline')
  int crypto_sign_final_create(
    _i1.Pointer<_i2.crypto_sign_ed25519ph_state> state,
    _i1.Pointer<_i1.UnsignedChar> sig,
    _i1.Pointer<_i1.UnsignedLongLong> siglen_p,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_sign_final_create(state, sig, siglen_p, sk);

  @pragma('vm:prefer-inline')
  int crypto_sign_final_verify(
    _i1.Pointer<_i2.crypto_sign_ed25519ph_state> state,
    _i1.Pointer<_i1.UnsignedChar> sig,
    _i1.Pointer<_i1.UnsignedChar> pk,
  ) => _i2.crypto_sign_final_verify(state, sig, pk);

  @pragma('vm:prefer-inline')
  int crypto_stream_keybytes() => _i2.crypto_stream_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_stream_noncebytes() => _i2.crypto_stream_noncebytes();

  @pragma('vm:prefer-inline')
  int crypto_stream_messagebytes_max() => _i2.crypto_stream_messagebytes_max();

  @pragma('vm:prefer-inline')
  _i1.Pointer<_i1.Char> crypto_stream_primitive() =>
      _i2.crypto_stream_primitive();

  @pragma('vm:prefer-inline')
  int crypto_stream(
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_stream(c, clen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_stream_xor(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_stream_xor(c, m, mlen, n, k);

  @pragma('vm:prefer-inline')
  void crypto_stream_keygen(_i1.Pointer<_i1.UnsignedChar> k) =>
      _i2.crypto_stream_keygen(k);

  @pragma('vm:prefer-inline')
  int crypto_stream_salsa20_keybytes() => _i2.crypto_stream_salsa20_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_stream_salsa20_noncebytes() =>
      _i2.crypto_stream_salsa20_noncebytes();

  @pragma('vm:prefer-inline')
  int crypto_stream_salsa20_messagebytes_max() =>
      _i2.crypto_stream_salsa20_messagebytes_max();

  @pragma('vm:prefer-inline')
  int crypto_stream_salsa20(
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_stream_salsa20(c, clen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_stream_salsa20_xor(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_stream_salsa20_xor(c, m, mlen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_stream_salsa20_xor_ic(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    int ic,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_stream_salsa20_xor_ic(c, m, mlen, n, ic, k);

  @pragma('vm:prefer-inline')
  void crypto_stream_salsa20_keygen(_i1.Pointer<_i1.UnsignedChar> k) =>
      _i2.crypto_stream_salsa20_keygen(k);

  @pragma('vm:prefer-inline')
  int crypto_verify_16_bytes() => _i2.crypto_verify_16_bytes();

  @pragma('vm:prefer-inline')
  int crypto_verify_16(
    _i1.Pointer<_i1.UnsignedChar> x,
    _i1.Pointer<_i1.UnsignedChar> y,
  ) => _i2.crypto_verify_16(x, y);

  @pragma('vm:prefer-inline')
  int crypto_verify_32_bytes() => _i2.crypto_verify_32_bytes();

  @pragma('vm:prefer-inline')
  int crypto_verify_32(
    _i1.Pointer<_i1.UnsignedChar> x,
    _i1.Pointer<_i1.UnsignedChar> y,
  ) => _i2.crypto_verify_32(x, y);

  @pragma('vm:prefer-inline')
  int crypto_verify_64_bytes() => _i2.crypto_verify_64_bytes();

  @pragma('vm:prefer-inline')
  int crypto_verify_64(
    _i1.Pointer<_i1.UnsignedChar> x,
    _i1.Pointer<_i1.UnsignedChar> y,
  ) => _i2.crypto_verify_64(x, y);

  @pragma('vm:prefer-inline')
  int randombytes_seedbytes() => _i2.randombytes_seedbytes();

  @pragma('vm:prefer-inline')
  void randombytes_buf(_i1.Pointer<_i1.Void> buf, int size) =>
      _i2.randombytes_buf(buf, size);

  @pragma('vm:prefer-inline')
  void randombytes_buf_deterministic(
    _i1.Pointer<_i1.Void> buf,
    int size,
    _i1.Pointer<_i1.UnsignedChar> seed,
  ) => _i2.randombytes_buf_deterministic(buf, size, seed);

  @pragma('vm:prefer-inline')
  int randombytes_random() => _i2.randombytes_random();

  @pragma('vm:prefer-inline')
  int randombytes_uniform(int upper_bound) =>
      _i2.randombytes_uniform(upper_bound);

  @pragma('vm:prefer-inline')
  void randombytes_stir() => _i2.randombytes_stir();

  @pragma('vm:prefer-inline')
  int randombytes_close() => _i2.randombytes_close();

  @pragma('vm:prefer-inline')
  int randombytes_set_implementation(
    _i1.Pointer<_i2.randombytes_implementation> impl,
  ) => _i2.randombytes_set_implementation(impl);

  @pragma('vm:prefer-inline')
  _i1.Pointer<_i1.Char> randombytes_implementation_name() =>
      _i2.randombytes_implementation_name();

  @pragma('vm:prefer-inline')
  void randombytes(_i1.Pointer<_i1.UnsignedChar> buf, int buf_len) =>
      _i2.randombytes(buf, buf_len);

  @pragma('vm:prefer-inline')
  int sodium_runtime_has_neon() => _i2.sodium_runtime_has_neon();

  @pragma('vm:prefer-inline')
  int sodium_runtime_has_armcrypto() => _i2.sodium_runtime_has_armcrypto();

  @pragma('vm:prefer-inline')
  int sodium_runtime_has_sse2() => _i2.sodium_runtime_has_sse2();

  @pragma('vm:prefer-inline')
  int sodium_runtime_has_sse3() => _i2.sodium_runtime_has_sse3();

  @pragma('vm:prefer-inline')
  int sodium_runtime_has_ssse3() => _i2.sodium_runtime_has_ssse3();

  @pragma('vm:prefer-inline')
  int sodium_runtime_has_sse41() => _i2.sodium_runtime_has_sse41();

  @pragma('vm:prefer-inline')
  int sodium_runtime_has_avx() => _i2.sodium_runtime_has_avx();

  @pragma('vm:prefer-inline')
  int sodium_runtime_has_avx2() => _i2.sodium_runtime_has_avx2();

  @pragma('vm:prefer-inline')
  int sodium_runtime_has_avx512f() => _i2.sodium_runtime_has_avx512f();

  @pragma('vm:prefer-inline')
  int sodium_runtime_has_pclmul() => _i2.sodium_runtime_has_pclmul();

  @pragma('vm:prefer-inline')
  int sodium_runtime_has_aesni() => _i2.sodium_runtime_has_aesni();

  @pragma('vm:prefer-inline')
  int sodium_runtime_has_rdrand() => _i2.sodium_runtime_has_rdrand();

  @pragma('vm:prefer-inline')
  void sodium_memzero(_i1.Pointer<_i1.Void> pnt, int len) =>
      _i2.sodium_memzero(pnt, len);

  @pragma('vm:prefer-inline')
  void sodium_stackzero(int len) => _i2.sodium_stackzero(len);

  @pragma('vm:prefer-inline')
  int sodium_memcmp(
    _i1.Pointer<_i1.Void> b1_,
    _i1.Pointer<_i1.Void> b2_,
    int len,
  ) => _i2.sodium_memcmp(b1_, b2_, len);

  @pragma('vm:prefer-inline')
  int sodium_compare(
    _i1.Pointer<_i1.UnsignedChar> b1_,
    _i1.Pointer<_i1.UnsignedChar> b2_,
    int len,
  ) => _i2.sodium_compare(b1_, b2_, len);

  @pragma('vm:prefer-inline')
  int sodium_is_zero(_i1.Pointer<_i1.UnsignedChar> n, int nlen) =>
      _i2.sodium_is_zero(n, nlen);

  @pragma('vm:prefer-inline')
  void sodium_increment(_i1.Pointer<_i1.UnsignedChar> n, int nlen) =>
      _i2.sodium_increment(n, nlen);

  @pragma('vm:prefer-inline')
  void sodium_add(
    _i1.Pointer<_i1.UnsignedChar> a,
    _i1.Pointer<_i1.UnsignedChar> b,
    int len,
  ) => _i2.sodium_add(a, b, len);

  @pragma('vm:prefer-inline')
  void sodium_sub(
    _i1.Pointer<_i1.UnsignedChar> a,
    _i1.Pointer<_i1.UnsignedChar> b,
    int len,
  ) => _i2.sodium_sub(a, b, len);

  @pragma('vm:prefer-inline')
  _i1.Pointer<_i1.Char> sodium_bin2hex(
    _i1.Pointer<_i1.Char> hex,
    int hex_maxlen,
    _i1.Pointer<_i1.UnsignedChar> bin,
    int bin_len,
  ) => _i2.sodium_bin2hex(hex, hex_maxlen, bin, bin_len);

  @pragma('vm:prefer-inline')
  int sodium_hex2bin(
    _i1.Pointer<_i1.UnsignedChar> bin,
    int bin_maxlen,
    _i1.Pointer<_i1.Char> hex,
    int hex_len,
    _i1.Pointer<_i1.Char> ignore,
    _i1.Pointer<_i1.Size> bin_len,
    _i1.Pointer<_i1.Pointer<_i1.Char>> hex_end,
  ) => _i2.sodium_hex2bin(
    bin,
    bin_maxlen,
    hex,
    hex_len,
    ignore,
    bin_len,
    hex_end,
  );

  @pragma('vm:prefer-inline')
  int sodium_base64_encoded_len(int bin_len, int variant) =>
      _i2.sodium_base64_encoded_len(bin_len, variant);

  @pragma('vm:prefer-inline')
  _i1.Pointer<_i1.Char> sodium_bin2base64(
    _i1.Pointer<_i1.Char> b64,
    int b64_maxlen,
    _i1.Pointer<_i1.UnsignedChar> bin,
    int bin_len,
    int variant,
  ) => _i2.sodium_bin2base64(b64, b64_maxlen, bin, bin_len, variant);

  @pragma('vm:prefer-inline')
  int sodium_base642bin(
    _i1.Pointer<_i1.UnsignedChar> bin,
    int bin_maxlen,
    _i1.Pointer<_i1.Char> b64,
    int b64_len,
    _i1.Pointer<_i1.Char> ignore,
    _i1.Pointer<_i1.Size> bin_len,
    _i1.Pointer<_i1.Pointer<_i1.Char>> b64_end,
    int variant,
  ) => _i2.sodium_base642bin(
    bin,
    bin_maxlen,
    b64,
    b64_len,
    ignore,
    bin_len,
    b64_end,
    variant,
  );

  @pragma('vm:prefer-inline')
  int sodium_mlock(_i1.Pointer<_i1.Void> addr, int len) =>
      _i2.sodium_mlock(addr, len);

  @pragma('vm:prefer-inline')
  int sodium_munlock(_i1.Pointer<_i1.Void> addr, int len) =>
      _i2.sodium_munlock(addr, len);

  @pragma('vm:prefer-inline')
  _i1.Pointer<_i1.Void> sodium_malloc(int size) => _i2.sodium_malloc(size);

  @pragma('vm:prefer-inline')
  _i1.Pointer<_i1.Void> sodium_allocarray(int count, int size) =>
      _i2.sodium_allocarray(count, size);

  @pragma('vm:prefer-inline')
  void sodium_free(_i1.Pointer<_i1.Void> ptr) => _i2.sodium_free(ptr);

  @pragma('vm:prefer-inline')
  int sodium_mprotect_noaccess(_i1.Pointer<_i1.Void> ptr) =>
      _i2.sodium_mprotect_noaccess(ptr);

  @pragma('vm:prefer-inline')
  int sodium_mprotect_readonly(_i1.Pointer<_i1.Void> ptr) =>
      _i2.sodium_mprotect_readonly(ptr);

  @pragma('vm:prefer-inline')
  int sodium_mprotect_readwrite(_i1.Pointer<_i1.Void> ptr) =>
      _i2.sodium_mprotect_readwrite(ptr);

  @pragma('vm:prefer-inline')
  int sodium_pad(
    _i1.Pointer<_i1.Size> padded_buflen_p,
    _i1.Pointer<_i1.UnsignedChar> buf,
    int unpadded_buflen,
    int blocksize,
    int max_buflen,
  ) => _i2.sodium_pad(
    padded_buflen_p,
    buf,
    unpadded_buflen,
    blocksize,
    max_buflen,
  );

  @pragma('vm:prefer-inline')
  int sodium_unpad(
    _i1.Pointer<_i1.Size> unpadded_buflen_p,
    _i1.Pointer<_i1.UnsignedChar> buf,
    int padded_buflen,
    int blocksize,
  ) => _i2.sodium_unpad(unpadded_buflen_p, buf, padded_buflen, blocksize);

  @pragma('vm:prefer-inline')
  int crypto_stream_xchacha20_keybytes() =>
      _i2.crypto_stream_xchacha20_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_stream_xchacha20_noncebytes() =>
      _i2.crypto_stream_xchacha20_noncebytes();

  @pragma('vm:prefer-inline')
  int crypto_stream_xchacha20_messagebytes_max() =>
      _i2.crypto_stream_xchacha20_messagebytes_max();

  @pragma('vm:prefer-inline')
  int crypto_stream_xchacha20(
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_stream_xchacha20(c, clen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_stream_xchacha20_xor(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_stream_xchacha20_xor(c, m, mlen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_stream_xchacha20_xor_ic(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    int ic,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_stream_xchacha20_xor_ic(c, m, mlen, n, ic, k);

  @pragma('vm:prefer-inline')
  void crypto_stream_xchacha20_keygen(_i1.Pointer<_i1.UnsignedChar> k) =>
      _i2.crypto_stream_xchacha20_keygen(k);

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xchacha20poly1305_seedbytes() =>
      _i2.crypto_box_curve25519xchacha20poly1305_seedbytes();

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xchacha20poly1305_publickeybytes() =>
      _i2.crypto_box_curve25519xchacha20poly1305_publickeybytes();

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xchacha20poly1305_secretkeybytes() =>
      _i2.crypto_box_curve25519xchacha20poly1305_secretkeybytes();

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xchacha20poly1305_beforenmbytes() =>
      _i2.crypto_box_curve25519xchacha20poly1305_beforenmbytes();

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xchacha20poly1305_noncebytes() =>
      _i2.crypto_box_curve25519xchacha20poly1305_noncebytes();

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xchacha20poly1305_macbytes() =>
      _i2.crypto_box_curve25519xchacha20poly1305_macbytes();

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xchacha20poly1305_messagebytes_max() =>
      _i2.crypto_box_curve25519xchacha20poly1305_messagebytes_max();

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xchacha20poly1305_seed_keypair(
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
    _i1.Pointer<_i1.UnsignedChar> seed,
  ) => _i2.crypto_box_curve25519xchacha20poly1305_seed_keypair(pk, sk, seed);

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xchacha20poly1305_keypair(
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_box_curve25519xchacha20poly1305_keypair(pk, sk);

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xchacha20poly1305_easy(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_box_curve25519xchacha20poly1305_easy(c, m, mlen, n, pk, sk);

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xchacha20poly1305_open_easy(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_box_curve25519xchacha20poly1305_open_easy(
    m,
    c,
    clen,
    n,
    pk,
    sk,
  );

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xchacha20poly1305_detached(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> mac,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_box_curve25519xchacha20poly1305_detached(
    c,
    mac,
    m,
    mlen,
    n,
    pk,
    sk,
  );

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xchacha20poly1305_open_detached(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> mac,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_box_curve25519xchacha20poly1305_open_detached(
    m,
    c,
    mac,
    clen,
    n,
    pk,
    sk,
  );

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xchacha20poly1305_beforenm(
    _i1.Pointer<_i1.UnsignedChar> k,
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_box_curve25519xchacha20poly1305_beforenm(k, pk, sk);

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xchacha20poly1305_easy_afternm(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) =>
      _i2.crypto_box_curve25519xchacha20poly1305_easy_afternm(c, m, mlen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xchacha20poly1305_open_easy_afternm(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_box_curve25519xchacha20poly1305_open_easy_afternm(
    m,
    c,
    clen,
    n,
    k,
  );

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xchacha20poly1305_detached_afternm(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> mac,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_box_curve25519xchacha20poly1305_detached_afternm(
    c,
    mac,
    m,
    mlen,
    n,
    k,
  );

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xchacha20poly1305_open_detached_afternm(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> mac,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_box_curve25519xchacha20poly1305_open_detached_afternm(
    m,
    c,
    mac,
    clen,
    n,
    k,
  );

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xchacha20poly1305_sealbytes() =>
      _i2.crypto_box_curve25519xchacha20poly1305_sealbytes();

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xchacha20poly1305_seal(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> pk,
  ) => _i2.crypto_box_curve25519xchacha20poly1305_seal(c, m, mlen, pk);

  @pragma('vm:prefer-inline')
  int crypto_box_curve25519xchacha20poly1305_seal_open(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> pk,
    _i1.Pointer<_i1.UnsignedChar> sk,
  ) => _i2.crypto_box_curve25519xchacha20poly1305_seal_open(m, c, clen, pk, sk);

  @pragma('vm:prefer-inline')
  int crypto_core_ed25519_bytes() => _i2.crypto_core_ed25519_bytes();

  @pragma('vm:prefer-inline')
  int crypto_core_ed25519_uniformbytes() =>
      _i2.crypto_core_ed25519_uniformbytes();

  @pragma('vm:prefer-inline')
  int crypto_core_ed25519_hashbytes() => _i2.crypto_core_ed25519_hashbytes();

  @pragma('vm:prefer-inline')
  int crypto_core_ed25519_scalarbytes() =>
      _i2.crypto_core_ed25519_scalarbytes();

  @pragma('vm:prefer-inline')
  int crypto_core_ed25519_nonreducedscalarbytes() =>
      _i2.crypto_core_ed25519_nonreducedscalarbytes();

  @pragma('vm:prefer-inline')
  int crypto_core_ed25519_is_valid_point(_i1.Pointer<_i1.UnsignedChar> p) =>
      _i2.crypto_core_ed25519_is_valid_point(p);

  @pragma('vm:prefer-inline')
  int crypto_core_ed25519_add(
    _i1.Pointer<_i1.UnsignedChar> r,
    _i1.Pointer<_i1.UnsignedChar> p,
    _i1.Pointer<_i1.UnsignedChar> q,
  ) => _i2.crypto_core_ed25519_add(r, p, q);

  @pragma('vm:prefer-inline')
  int crypto_core_ed25519_sub(
    _i1.Pointer<_i1.UnsignedChar> r,
    _i1.Pointer<_i1.UnsignedChar> p,
    _i1.Pointer<_i1.UnsignedChar> q,
  ) => _i2.crypto_core_ed25519_sub(r, p, q);

  @pragma('vm:prefer-inline')
  int crypto_core_ed25519_from_uniform(
    _i1.Pointer<_i1.UnsignedChar> p,
    _i1.Pointer<_i1.UnsignedChar> r,
  ) => _i2.crypto_core_ed25519_from_uniform(p, r);

  @pragma('vm:prefer-inline')
  int crypto_core_ed25519_from_hash(
    _i1.Pointer<_i1.UnsignedChar> p,
    _i1.Pointer<_i1.UnsignedChar> h,
  ) => _i2.crypto_core_ed25519_from_hash(p, h);

  @pragma('vm:prefer-inline')
  void crypto_core_ed25519_random(_i1.Pointer<_i1.UnsignedChar> p) =>
      _i2.crypto_core_ed25519_random(p);

  @pragma('vm:prefer-inline')
  void crypto_core_ed25519_scalar_random(_i1.Pointer<_i1.UnsignedChar> r) =>
      _i2.crypto_core_ed25519_scalar_random(r);

  @pragma('vm:prefer-inline')
  int crypto_core_ed25519_scalar_invert(
    _i1.Pointer<_i1.UnsignedChar> recip,
    _i1.Pointer<_i1.UnsignedChar> s,
  ) => _i2.crypto_core_ed25519_scalar_invert(recip, s);

  @pragma('vm:prefer-inline')
  void crypto_core_ed25519_scalar_negate(
    _i1.Pointer<_i1.UnsignedChar> neg,
    _i1.Pointer<_i1.UnsignedChar> s,
  ) => _i2.crypto_core_ed25519_scalar_negate(neg, s);

  @pragma('vm:prefer-inline')
  void crypto_core_ed25519_scalar_complement(
    _i1.Pointer<_i1.UnsignedChar> comp,
    _i1.Pointer<_i1.UnsignedChar> s,
  ) => _i2.crypto_core_ed25519_scalar_complement(comp, s);

  @pragma('vm:prefer-inline')
  void crypto_core_ed25519_scalar_add(
    _i1.Pointer<_i1.UnsignedChar> z,
    _i1.Pointer<_i1.UnsignedChar> x,
    _i1.Pointer<_i1.UnsignedChar> y,
  ) => _i2.crypto_core_ed25519_scalar_add(z, x, y);

  @pragma('vm:prefer-inline')
  void crypto_core_ed25519_scalar_sub(
    _i1.Pointer<_i1.UnsignedChar> z,
    _i1.Pointer<_i1.UnsignedChar> x,
    _i1.Pointer<_i1.UnsignedChar> y,
  ) => _i2.crypto_core_ed25519_scalar_sub(z, x, y);

  @pragma('vm:prefer-inline')
  void crypto_core_ed25519_scalar_mul(
    _i1.Pointer<_i1.UnsignedChar> z,
    _i1.Pointer<_i1.UnsignedChar> x,
    _i1.Pointer<_i1.UnsignedChar> y,
  ) => _i2.crypto_core_ed25519_scalar_mul(z, x, y);

  @pragma('vm:prefer-inline')
  void crypto_core_ed25519_scalar_reduce(
    _i1.Pointer<_i1.UnsignedChar> r,
    _i1.Pointer<_i1.UnsignedChar> s,
  ) => _i2.crypto_core_ed25519_scalar_reduce(r, s);

  @pragma('vm:prefer-inline')
  int crypto_core_ristretto255_bytes() => _i2.crypto_core_ristretto255_bytes();

  @pragma('vm:prefer-inline')
  int crypto_core_ristretto255_hashbytes() =>
      _i2.crypto_core_ristretto255_hashbytes();

  @pragma('vm:prefer-inline')
  int crypto_core_ristretto255_scalarbytes() =>
      _i2.crypto_core_ristretto255_scalarbytes();

  @pragma('vm:prefer-inline')
  int crypto_core_ristretto255_nonreducedscalarbytes() =>
      _i2.crypto_core_ristretto255_nonreducedscalarbytes();

  @pragma('vm:prefer-inline')
  int crypto_core_ristretto255_is_valid_point(
    _i1.Pointer<_i1.UnsignedChar> p,
  ) => _i2.crypto_core_ristretto255_is_valid_point(p);

  @pragma('vm:prefer-inline')
  int crypto_core_ristretto255_add(
    _i1.Pointer<_i1.UnsignedChar> r,
    _i1.Pointer<_i1.UnsignedChar> p,
    _i1.Pointer<_i1.UnsignedChar> q,
  ) => _i2.crypto_core_ristretto255_add(r, p, q);

  @pragma('vm:prefer-inline')
  int crypto_core_ristretto255_sub(
    _i1.Pointer<_i1.UnsignedChar> r,
    _i1.Pointer<_i1.UnsignedChar> p,
    _i1.Pointer<_i1.UnsignedChar> q,
  ) => _i2.crypto_core_ristretto255_sub(r, p, q);

  @pragma('vm:prefer-inline')
  int crypto_core_ristretto255_from_hash(
    _i1.Pointer<_i1.UnsignedChar> p,
    _i1.Pointer<_i1.UnsignedChar> r,
  ) => _i2.crypto_core_ristretto255_from_hash(p, r);

  @pragma('vm:prefer-inline')
  void crypto_core_ristretto255_random(_i1.Pointer<_i1.UnsignedChar> p) =>
      _i2.crypto_core_ristretto255_random(p);

  @pragma('vm:prefer-inline')
  void crypto_core_ristretto255_scalar_random(
    _i1.Pointer<_i1.UnsignedChar> r,
  ) => _i2.crypto_core_ristretto255_scalar_random(r);

  @pragma('vm:prefer-inline')
  int crypto_core_ristretto255_scalar_invert(
    _i1.Pointer<_i1.UnsignedChar> recip,
    _i1.Pointer<_i1.UnsignedChar> s,
  ) => _i2.crypto_core_ristretto255_scalar_invert(recip, s);

  @pragma('vm:prefer-inline')
  void crypto_core_ristretto255_scalar_negate(
    _i1.Pointer<_i1.UnsignedChar> neg,
    _i1.Pointer<_i1.UnsignedChar> s,
  ) => _i2.crypto_core_ristretto255_scalar_negate(neg, s);

  @pragma('vm:prefer-inline')
  void crypto_core_ristretto255_scalar_complement(
    _i1.Pointer<_i1.UnsignedChar> comp,
    _i1.Pointer<_i1.UnsignedChar> s,
  ) => _i2.crypto_core_ristretto255_scalar_complement(comp, s);

  @pragma('vm:prefer-inline')
  void crypto_core_ristretto255_scalar_add(
    _i1.Pointer<_i1.UnsignedChar> z,
    _i1.Pointer<_i1.UnsignedChar> x,
    _i1.Pointer<_i1.UnsignedChar> y,
  ) => _i2.crypto_core_ristretto255_scalar_add(z, x, y);

  @pragma('vm:prefer-inline')
  void crypto_core_ristretto255_scalar_sub(
    _i1.Pointer<_i1.UnsignedChar> z,
    _i1.Pointer<_i1.UnsignedChar> x,
    _i1.Pointer<_i1.UnsignedChar> y,
  ) => _i2.crypto_core_ristretto255_scalar_sub(z, x, y);

  @pragma('vm:prefer-inline')
  void crypto_core_ristretto255_scalar_mul(
    _i1.Pointer<_i1.UnsignedChar> z,
    _i1.Pointer<_i1.UnsignedChar> x,
    _i1.Pointer<_i1.UnsignedChar> y,
  ) => _i2.crypto_core_ristretto255_scalar_mul(z, x, y);

  @pragma('vm:prefer-inline')
  void crypto_core_ristretto255_scalar_reduce(
    _i1.Pointer<_i1.UnsignedChar> r,
    _i1.Pointer<_i1.UnsignedChar> s,
  ) => _i2.crypto_core_ristretto255_scalar_reduce(r, s);

  @pragma('vm:prefer-inline')
  int crypto_pwhash_scryptsalsa208sha256_bytes_min() =>
      _i2.crypto_pwhash_scryptsalsa208sha256_bytes_min();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_scryptsalsa208sha256_bytes_max() =>
      _i2.crypto_pwhash_scryptsalsa208sha256_bytes_max();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_scryptsalsa208sha256_passwd_min() =>
      _i2.crypto_pwhash_scryptsalsa208sha256_passwd_min();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_scryptsalsa208sha256_passwd_max() =>
      _i2.crypto_pwhash_scryptsalsa208sha256_passwd_max();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_scryptsalsa208sha256_saltbytes() =>
      _i2.crypto_pwhash_scryptsalsa208sha256_saltbytes();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_scryptsalsa208sha256_strbytes() =>
      _i2.crypto_pwhash_scryptsalsa208sha256_strbytes();

  @pragma('vm:prefer-inline')
  _i1.Pointer<_i1.Char> crypto_pwhash_scryptsalsa208sha256_strprefix() =>
      _i2.crypto_pwhash_scryptsalsa208sha256_strprefix();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_scryptsalsa208sha256_opslimit_min() =>
      _i2.crypto_pwhash_scryptsalsa208sha256_opslimit_min();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_scryptsalsa208sha256_opslimit_max() =>
      _i2.crypto_pwhash_scryptsalsa208sha256_opslimit_max();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_scryptsalsa208sha256_memlimit_min() =>
      _i2.crypto_pwhash_scryptsalsa208sha256_memlimit_min();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_scryptsalsa208sha256_memlimit_max() =>
      _i2.crypto_pwhash_scryptsalsa208sha256_memlimit_max();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_scryptsalsa208sha256_opslimit_interactive() =>
      _i2.crypto_pwhash_scryptsalsa208sha256_opslimit_interactive();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_scryptsalsa208sha256_memlimit_interactive() =>
      _i2.crypto_pwhash_scryptsalsa208sha256_memlimit_interactive();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_scryptsalsa208sha256_opslimit_sensitive() =>
      _i2.crypto_pwhash_scryptsalsa208sha256_opslimit_sensitive();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_scryptsalsa208sha256_memlimit_sensitive() =>
      _i2.crypto_pwhash_scryptsalsa208sha256_memlimit_sensitive();

  @pragma('vm:prefer-inline')
  int crypto_pwhash_scryptsalsa208sha256(
    _i1.Pointer<_i1.UnsignedChar> out,
    int outlen,
    _i1.Pointer<_i1.Char> passwd,
    int passwdlen,
    _i1.Pointer<_i1.UnsignedChar> salt,
    int opslimit,
    int memlimit,
  ) => _i2.crypto_pwhash_scryptsalsa208sha256(
    out,
    outlen,
    passwd,
    passwdlen,
    salt,
    opslimit,
    memlimit,
  );

  @pragma('vm:prefer-inline')
  int crypto_pwhash_scryptsalsa208sha256_str(
    _i1.Pointer<_i1.Char> out,
    _i1.Pointer<_i1.Char> passwd,
    int passwdlen,
    int opslimit,
    int memlimit,
  ) => _i2.crypto_pwhash_scryptsalsa208sha256_str(
    out,
    passwd,
    passwdlen,
    opslimit,
    memlimit,
  );

  @pragma('vm:prefer-inline')
  int crypto_pwhash_scryptsalsa208sha256_str_verify(
    _i1.Pointer<_i1.Char> str,
    _i1.Pointer<_i1.Char> passwd,
    int passwdlen,
  ) =>
      _i2.crypto_pwhash_scryptsalsa208sha256_str_verify(str, passwd, passwdlen);

  @pragma('vm:prefer-inline')
  int crypto_pwhash_scryptsalsa208sha256_ll(
    _i1.Pointer<_i1.Uint8> passwd,
    int passwdlen,
    _i1.Pointer<_i1.Uint8> salt,
    int saltlen,
    int N,
    int r,
    int p,
    _i1.Pointer<_i1.Uint8> buf,
    int buflen,
  ) => _i2.crypto_pwhash_scryptsalsa208sha256_ll(
    passwd,
    passwdlen,
    salt,
    saltlen,
    N,
    r,
    p,
    buf,
    buflen,
  );

  @pragma('vm:prefer-inline')
  int crypto_pwhash_scryptsalsa208sha256_str_needs_rehash(
    _i1.Pointer<_i1.Char> str,
    int opslimit,
    int memlimit,
  ) => _i2.crypto_pwhash_scryptsalsa208sha256_str_needs_rehash(
    str,
    opslimit,
    memlimit,
  );

  @pragma('vm:prefer-inline')
  int crypto_scalarmult_ed25519_bytes() =>
      _i2.crypto_scalarmult_ed25519_bytes();

  @pragma('vm:prefer-inline')
  int crypto_scalarmult_ed25519_scalarbytes() =>
      _i2.crypto_scalarmult_ed25519_scalarbytes();

  @pragma('vm:prefer-inline')
  int crypto_scalarmult_ed25519(
    _i1.Pointer<_i1.UnsignedChar> q,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> p,
  ) => _i2.crypto_scalarmult_ed25519(q, n, p);

  @pragma('vm:prefer-inline')
  int crypto_scalarmult_ed25519_noclamp(
    _i1.Pointer<_i1.UnsignedChar> q,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> p,
  ) => _i2.crypto_scalarmult_ed25519_noclamp(q, n, p);

  @pragma('vm:prefer-inline')
  int crypto_scalarmult_ed25519_base(
    _i1.Pointer<_i1.UnsignedChar> q,
    _i1.Pointer<_i1.UnsignedChar> n,
  ) => _i2.crypto_scalarmult_ed25519_base(q, n);

  @pragma('vm:prefer-inline')
  int crypto_scalarmult_ed25519_base_noclamp(
    _i1.Pointer<_i1.UnsignedChar> q,
    _i1.Pointer<_i1.UnsignedChar> n,
  ) => _i2.crypto_scalarmult_ed25519_base_noclamp(q, n);

  @pragma('vm:prefer-inline')
  int crypto_scalarmult_ristretto255_bytes() =>
      _i2.crypto_scalarmult_ristretto255_bytes();

  @pragma('vm:prefer-inline')
  int crypto_scalarmult_ristretto255_scalarbytes() =>
      _i2.crypto_scalarmult_ristretto255_scalarbytes();

  @pragma('vm:prefer-inline')
  int crypto_scalarmult_ristretto255(
    _i1.Pointer<_i1.UnsignedChar> q,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> p,
  ) => _i2.crypto_scalarmult_ristretto255(q, n, p);

  @pragma('vm:prefer-inline')
  int crypto_scalarmult_ristretto255_base(
    _i1.Pointer<_i1.UnsignedChar> q,
    _i1.Pointer<_i1.UnsignedChar> n,
  ) => _i2.crypto_scalarmult_ristretto255_base(q, n);

  @pragma('vm:prefer-inline')
  int crypto_secretbox_xchacha20poly1305_keybytes() =>
      _i2.crypto_secretbox_xchacha20poly1305_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_secretbox_xchacha20poly1305_noncebytes() =>
      _i2.crypto_secretbox_xchacha20poly1305_noncebytes();

  @pragma('vm:prefer-inline')
  int crypto_secretbox_xchacha20poly1305_macbytes() =>
      _i2.crypto_secretbox_xchacha20poly1305_macbytes();

  @pragma('vm:prefer-inline')
  int crypto_secretbox_xchacha20poly1305_messagebytes_max() =>
      _i2.crypto_secretbox_xchacha20poly1305_messagebytes_max();

  @pragma('vm:prefer-inline')
  int crypto_secretbox_xchacha20poly1305_easy(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_secretbox_xchacha20poly1305_easy(c, m, mlen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_secretbox_xchacha20poly1305_open_easy(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_secretbox_xchacha20poly1305_open_easy(m, c, clen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_secretbox_xchacha20poly1305_detached(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> mac,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_secretbox_xchacha20poly1305_detached(c, mac, m, mlen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_secretbox_xchacha20poly1305_open_detached(
    _i1.Pointer<_i1.UnsignedChar> m,
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> mac,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_secretbox_xchacha20poly1305_open_detached(
    m,
    c,
    mac,
    clen,
    n,
    k,
  );

  @pragma('vm:prefer-inline')
  int crypto_stream_salsa2012_keybytes() =>
      _i2.crypto_stream_salsa2012_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_stream_salsa2012_noncebytes() =>
      _i2.crypto_stream_salsa2012_noncebytes();

  @pragma('vm:prefer-inline')
  int crypto_stream_salsa2012_messagebytes_max() =>
      _i2.crypto_stream_salsa2012_messagebytes_max();

  @pragma('vm:prefer-inline')
  int crypto_stream_salsa2012(
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_stream_salsa2012(c, clen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_stream_salsa2012_xor(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_stream_salsa2012_xor(c, m, mlen, n, k);

  @pragma('vm:prefer-inline')
  void crypto_stream_salsa2012_keygen(_i1.Pointer<_i1.UnsignedChar> k) =>
      _i2.crypto_stream_salsa2012_keygen(k);

  @pragma('vm:prefer-inline')
  int crypto_stream_salsa208_keybytes() =>
      _i2.crypto_stream_salsa208_keybytes();

  @pragma('vm:prefer-inline')
  int crypto_stream_salsa208_noncebytes() =>
      _i2.crypto_stream_salsa208_noncebytes();

  @pragma('vm:prefer-inline')
  int crypto_stream_salsa208_messagebytes_max() =>
      _i2.crypto_stream_salsa208_messagebytes_max();

  @pragma('vm:prefer-inline')
  int crypto_stream_salsa208(
    _i1.Pointer<_i1.UnsignedChar> c,
    int clen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_stream_salsa208(c, clen, n, k);

  @pragma('vm:prefer-inline')
  int crypto_stream_salsa208_xor(
    _i1.Pointer<_i1.UnsignedChar> c,
    _i1.Pointer<_i1.UnsignedChar> m,
    int mlen,
    _i1.Pointer<_i1.UnsignedChar> n,
    _i1.Pointer<_i1.UnsignedChar> k,
  ) => _i2.crypto_stream_salsa208_xor(c, m, mlen, n, k);

  @pragma('vm:prefer-inline')
  void crypto_stream_salsa208_keygen(_i1.Pointer<_i1.UnsignedChar> k) =>
      _i2.crypto_stream_salsa208_keygen(k);
}
