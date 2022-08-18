import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/key_pair.dart';
import '../../api/kx.dart';
import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart' hide KeyPair;
import '../bindings/to_safe_int.dart';
import 'secure_key_js.dart';

/// @nodoc
@internal
class KxJS with KxValidations implements Kx {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  KxJS(this.sodium);

  @override
  int get publicKeyBytes => sodium.crypto_kx_PUBLICKEYBYTES.toSafeUInt32();

  @override
  int get secretKeyBytes => sodium.crypto_kx_SECRETKEYBYTES.toSafeUInt32();

  @override
  int get seedBytes => sodium.crypto_kx_SEEDBYTES.toSafeUInt32();

  @override
  int get sessionKeyBytes => sodium.crypto_kx_SESSIONKEYBYTES.toSafeUInt32();

  @override
  KeyPair keyPair() {
    final keyPair = JsError.wrap(sodium.crypto_kx_keypair);

    return KeyPair(
      publicKey: keyPair.publicKey,
      secretKey: SecureKeyJS(sodium, keyPair.privateKey),
    );
  }

  @override
  KeyPair seedKeyPair(SecureKey seed) {
    validateSeed(seed);

    final keyPair = JsError.wrap(
      () => seed.runUnlockedSync(
        sodium.crypto_kx_seed_keypair,
      ),
    );

    return KeyPair(
      publicKey: keyPair.publicKey,
      secretKey: SecureKeyJS(sodium, keyPair.privateKey),
    );
  }

  @override
  SessionKeys clientSessionKeys({
    required Uint8List clientPublicKey,
    required SecureKey clientSecretKey,
    required Uint8List serverPublicKey,
  }) {
    validatePublicKey(clientPublicKey, 'client');
    validateSecretKey(clientSecretKey, 'client');
    validatePublicKey(serverPublicKey, 'server');

    final sessionKeys = JsError.wrap(
      () => clientSecretKey.runUnlockedSync(
        (clientSecretKeyData) => sodium.crypto_kx_client_session_keys(
          clientPublicKey,
          clientSecretKeyData,
          serverPublicKey,
        ),
      ),
    );

    return SessionKeys(
      rx: SecureKeyJS(sodium, sessionKeys.sharedRx),
      tx: SecureKeyJS(sodium, sessionKeys.sharedTx),
    );
  }

  @override
  SessionKeys serverSessionKeys({
    required Uint8List serverPublicKey,
    required SecureKey serverSecretKey,
    required Uint8List clientPublicKey,
  }) {
    validatePublicKey(serverPublicKey, 'server');
    validateSecretKey(serverSecretKey, 'server');
    validatePublicKey(clientPublicKey, 'client');

    final sessionKeys = JsError.wrap(
      () => serverSecretKey.runUnlockedSync(
        (serverSecretKeyData) => sodium.crypto_kx_server_session_keys(
          serverPublicKey,
          serverSecretKeyData,
          clientPublicKey,
        ),
      ),
    );

    return SessionKeys(
      rx: SecureKeyJS(sodium, sessionKeys.sharedRx),
      tx: SecureKeyJS(sodium, sessionKeys.sharedTx),
    );
  }
}
