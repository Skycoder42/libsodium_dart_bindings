import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'helpers/validations.dart';
import 'ip_address.dart';
import 'secure_key.dart';

/// A meta class that provides access to all libsodium ipcrypt APIs.
///
/// This class provides the dart interface for the crypto operations documented
/// in https://libsodium.gitbook.io/doc/secret-key_cryptography/ip_address_encryption
/// Please refer to that documentation for more details about these APIs.
abstract interface class Ipcrypt {
  /// Provides crypto_ipcrypt_BYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/ip_address_encryption#constants
  int get bytes;

  /// Provides crypto_ipcrypt_KEYBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/ip_address_encryption#constants
  int get keyBytes;

  /// Access to the nonce-dependent (nd) ipcrypt variant.
  IpcryptNd get nd;

  /// Access to the nonce-dependent extended (ndx) ipcrypt variant.
  IpcryptNd get ndx;

  /// Access to the prefix-preserving (pfx) ipcrypt variant.
  IpcryptPfx get pfx;

  /// Provides crypto_ipcrypt_keygen.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/ip_address_encryption#usage
  SecureKey keygen();

  /// Provides crypto_ipcrypt_encrypt.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/ip_address_encryption#usage
  Uint8List encrypt({required IpAddress input, required SecureKey key});

  /// Provides crypto_ipcrypt_decrypt.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/ip_address_encryption#usage
  IpAddress decrypt({required Uint8List input, required SecureKey key});
}

/// @nodoc
@internal
mixin IpcryptValidations implements Ipcrypt {
  /// @nodoc
  void validateInput(Uint8List input) =>
      Validations.checkIsSame(input.length, bytes, 'input');

  /// @nodoc
  void validateKey(SecureKey key) =>
      Validations.checkIsSame(key.length, keyBytes, 'key');
}

/// A meta class that provides access to all libsodium ipcrypt nonce-dependent
/// APIs (nd and ndx variants).
///
/// This class provides the dart interface for the crypto operations documented
/// in https://libsodium.gitbook.io/doc/secret-key_cryptography/ip_address_encryption
/// Please refer to that documentation for more details about these APIs.
abstract interface class IpcryptNd {
  /// Provides crypto_ipcrypt_nd_KEYBYTES / crypto_ipcrypt_ndx_KEYBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/ip_address_encryption#constants
  int get keyBytes;

  /// Provides crypto_ipcrypt_nd_TWEAKBYTES / crypto_ipcrypt_ndx_TWEAKBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/ip_address_encryption#constants
  int get tweakBytes;

  /// Provides crypto_ipcrypt_nd_INPUTBYTES / crypto_ipcrypt_ndx_INPUTBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/ip_address_encryption#constants
  int get inputBytes;

  /// Provides crypto_ipcrypt_nd_OUTPUTBYTES / crypto_ipcrypt_ndx_OUTPUTBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/ip_address_encryption#constants
  int get outputBytes;

  /// Provides crypto_ipcrypt_nd_keygen / crypto_ipcrypt_ndx_keygen.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/ip_address_encryption#usage
  SecureKey keygen();

  /// Provides crypto_ipcrypt_nd_encrypt / crypto_ipcrypt_ndx_encrypt.
  ///
  /// Returns the encrypted ciphertext (outputBytes long), which is not an IP
  /// address. The [tweak] is consumed by the encryption and need not be stored
  /// separately for decryption.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/ip_address_encryption#usage
  Uint8List encrypt({
    required IpAddress input,
    required Uint8List tweak,
    required SecureKey key,
  });

  /// Provides crypto_ipcrypt_nd_decrypt / crypto_ipcrypt_ndx_decrypt.
  ///
  /// [ciphertext] must be the full outputBytes-long value returned by
  /// [encrypt].
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/ip_address_encryption#usage
  IpAddress decrypt({required Uint8List ciphertext, required SecureKey key});
}

/// @nodoc
@internal
mixin IpcryptNdValidations implements IpcryptNd {
  /// @nodoc
  void validateInput(Uint8List input) =>
      Validations.checkIsSame(input.length, inputBytes, 'input');

  /// @nodoc
  void validateTweak(Uint8List tweak) =>
      Validations.checkIsSame(tweak.length, tweakBytes, 'tweak');

  /// @nodoc
  void validateKey(SecureKey key) =>
      Validations.checkIsSame(key.length, keyBytes, 'key');

  /// @nodoc
  void validateCiphertext(Uint8List ciphertext) =>
      Validations.checkIsSame(ciphertext.length, outputBytes, 'ciphertext');
}

/// A meta class that provides access to all libsodium ipcrypt
/// prefix-preserving APIs.
///
/// This class provides the dart interface for the crypto operations documented
/// in https://libsodium.gitbook.io/doc/secret-key_cryptography/ip_address_encryption
/// Please refer to that documentation for more details about these APIs.
abstract interface class IpcryptPfx {
  /// Provides crypto_ipcrypt_pfx_KEYBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/ip_address_encryption#constants
  int get keyBytes;

  /// Provides crypto_ipcrypt_pfx_BYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/ip_address_encryption#constants
  int get bytes;

  /// Provides crypto_ipcrypt_pfx_keygen.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/ip_address_encryption#usage
  SecureKey keygen();

  /// Provides crypto_ipcrypt_pfx_encrypt.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/ip_address_encryption#usage
  Uint8List encrypt({required IpAddress input, required SecureKey key});

  /// Provides crypto_ipcrypt_pfx_decrypt.
  ///
  /// See https://libsodium.gitbook.io/doc/secret-key_cryptography/ip_address_encryption#usage
  IpAddress decrypt({required Uint8List input, required SecureKey key});
}

/// @nodoc
@internal
mixin IpcryptPfxValidations implements IpcryptPfx {
  /// @nodoc
  void validateInput(Uint8List input) =>
      Validations.checkIsSame(input.length, bytes, 'input');

  /// @nodoc
  void validateKey(SecureKey key) =>
      Validations.checkIsSame(key.length, keyBytes, 'key');
}
