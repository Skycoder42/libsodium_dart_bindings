import 'aead.dart';
import 'auth.dart';
import 'box.dart';
import 'generic_hash.dart';
import 'kdf.dart';
import 'kx.dart';
import 'secret_box.dart';
import 'secret_stream.dart';
import 'short_hash.dart';
import 'sign.dart';
import 'sumo/pwhash.dart';

/// A meta class that provides access to all libsodium crypto APIs.
abstract class Crypto {
  const Crypto._(); // coverage:ignore-line

  /// An instance of [SecretBox].
  ///
  /// This provides all APIs that start with `crypto_secretbox`.
  SecretBox get secretBox;

  /// An instance of [SecretStream].
  ///
  /// This provides all APIs that start with `crypto_secretstream`.
  SecretStream get secretStream;

  /// An instance of [Aead].
  ///
  /// This provides all APIs that start with
  /// `crypto_aead_xchacha20poly1305_ietf`.
  Aead get aead;

  /// An instance of [Aead].
  ///
  /// This provides all APIs that start with `crypto_aead_chacha20poly1305`.
  Aead get aeadChacha20Poly1305;

  /// An instance of [Auth].
  ///
  /// This provides all APIs that start with `crypto_auth`.
  Auth get auth;

  /// An instance of [Box].
  ///
  /// This provides all APIs that start with `crypto_box`.
  Box get box;

  /// An instance of [Sign].
  ///
  /// This provides all APIs that start with `crypto_sign`.
  Sign get sign;

  /// An instance of [GenericHash].
  ///
  /// This provides all APIs that start with `crypto_generichash`.
  GenericHash get genericHash;

  /// An instance of [ShortHash].
  ///
  /// This provides all APIs that start with `crypto_shorthash`.
  ShortHash get shortHash;

  /// An instance of [Kdf].
  ///
  /// This provides all APIs that start with `crypto_kdf`.
  Kdf get kdf;

  /// An instance of [Kx].
  ///
  /// This provides all APIs that start with `crypto_kx`.
  Kx get kx;

  /// An instance of [Pwhash].
  ///
  /// This provides all APIs that start with `crypto_pwhash`.
  @Deprecated(
    'pwhash was removed from the standard sodium.js and is only available in '
    'sodium-sumo.js. Please use SodiumSumo if you want to use the pwhash APIs',
  )
  Pwhash get pwhash;
}
