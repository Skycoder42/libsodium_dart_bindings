// ignore_for_file: unnecessary_lambdas

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/key_pair.dart';
import '../../api/kx.dart';
import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart' hide KeyPair;
import 'secure_key_js.dart';

/// @nodoc
@internal
class KxJS with KxValidations implements Kx {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  KxJS(this.sodium);

  @override
  int get publicKeyBytes => sodium.crypto_kx_PUBLICKEYBYTES;

  @override
  int get secretKeyBytes => sodium.crypto_kx_SECRETKEYBYTES;

  @override
  int get seedBytes => sodium.crypto_kx_SEEDBYTES;

  @override
  int get sessionKeyBytes => sodium.crypto_kx_SESSIONKEYBYTES;

  @override
  KeyPair keyPair() {
    final keyPair = jsErrorWrap(() => sodium.crypto_kx_keypair());

    return KeyPair(
      publicKey: keyPair.publicKey.toDart,
      secretKey: SecureKeyJS(sodium, keyPair.privateKey),
    );
  }

  @override
  KeyPair seedKeyPair(SecureKey seed) {
    validateSeed(seed);

    final keyPair = jsErrorWrap(
      () => seed.runUnlockedSync(
        (seedData) => sodium.crypto_kx_seed_keypair(seedData.toJS),
      ),
    );

    return KeyPair(
      publicKey: keyPair.publicKey.toDart,
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

    final sessionKeys = jsErrorWrap(
      () => clientSecretKey.runUnlockedSync(
        (clientSecretKeyData) => sodium.crypto_kx_client_session_keys(
          clientPublicKey.toJS,
          clientSecretKeyData.toJS,
          serverPublicKey.toJS,
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

    final sessionKeys = jsErrorWrap(
      () => serverSecretKey.runUnlockedSync(
        (serverSecretKeyData) => sodium.crypto_kx_server_session_keys(
          serverPublicKey.toJS,
          serverSecretKeyData.toJS,
          clientPublicKey.toJS,
        ),
      ),
    );

    return SessionKeys(
      rx: SecureKeyJS(sodium, sessionKeys.sharedRx),
      tx: SecureKeyJS(sodium, sessionKeys.sharedTx),
    );
  }
}
