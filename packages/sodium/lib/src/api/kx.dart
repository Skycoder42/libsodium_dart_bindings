import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

import 'helpers/validations.dart';
import 'key_pair.dart';
import 'secure_key.dart';

part 'kx.freezed.dart';

/// A pair of session keys that can be used for secure data transfer.
///
/// This class simply holds a [rx]Key and a [tx]Key. The [rx] should be used to
/// decrypt received data and [tx] to encrypt data before sending it.
///
/// See https://libsodium.gitbook.io/doc/key_exchange.
@freezed
class SessionKeys with _$SessionKeys {
  const SessionKeys._();

  // ignore: sort_unnamed_constructors_first
  const factory SessionKeys({
    /// Session key to be used to decrypt received data
    required SecureKey rx,

    /// Session key to be used to encrypt data before transmitting it
    required SecureKey tx,
  }) = _SessionKeys;

  /// Shortcut to dispose both contained keys.
  ///
  /// Simply calls [SecureKey.dispose] on [rx] and [tx]
  void dispose() {
    rx.dispose();
    tx.dispose();
  }
}

/// A meta class that provides access to all libsodium kx APIs.
///
/// This class provides the dart interface for the crypto operations documented
/// in https://libsodium.gitbook.io/doc/key_exchange.
/// Please refer to that documentation for more details about these APIs.
abstract class Kx {
  const Kx._(); // coverage:ignore-line

  /// Provides crypto_kx_PUBLICKEYBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/key_exchange#constants
  int get publicKeyBytes;

  /// Provides crypto_kx_SECRETKEYBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/key_exchange#constants
  int get secretKeyBytes;

  /// Provides crypto_kx_SEEDBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/key_exchange#constants
  int get seedBytes;

  /// Provides crypto_kx_SESSIONKEYBYTES.
  ///
  /// See https://libsodium.gitbook.io/doc/key_exchange#constants
  int get sessionKeyBytes;

  /// Provides crypto_kx_keypair.
  ///
  /// See https://libsodium.gitbook.io/doc/key_exchange#usage
  KeyPair keyPair();

  /// Provides crypto_kx_seed_keypair.
  ///
  /// See https://libsodium.gitbook.io/doc/key_exchange#usage
  KeyPair seedKeyPair(SecureKey seed);

  /// Provides crypto_kx_client_session_keys.
  ///
  /// See https://libsodium.gitbook.io/doc/key_exchange#usage
  SessionKeys clientSessionKeys({
    required Uint8List clientPublicKey,
    required SecureKey clientSecretKey,
    required Uint8List serverPublicKey,
  });

  /// Provides crypto_kx_server_session_keys.
  ///
  /// See https://libsodium.gitbook.io/doc/key_exchange#usage
  SessionKeys serverSessionKeys({
    required Uint8List serverPublicKey,
    required SecureKey serverSecretKey,
    required Uint8List clientPublicKey,
  });
}

@internal
mixin KxValidations implements Kx {
  void validatePublicKey(Uint8List publicKey, String namePrefix) =>
      Validations.checkIsSame(
        publicKey.length,
        publicKeyBytes,
        '${namePrefix}PublicKey',
      );

  void validateSecretKey(SecureKey secretKey, String namePrefix) =>
      Validations.checkIsSame(
        secretKey.length,
        secretKeyBytes,
        '${namePrefix}SecretKey',
      );

  void validateSeed(SecureKey seed) => Validations.checkIsSame(
        seed.length,
        seedBytes,
        'seed',
      );
}
