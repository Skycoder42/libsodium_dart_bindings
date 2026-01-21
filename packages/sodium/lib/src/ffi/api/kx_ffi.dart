import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/key_pair.dart';
import '../../api/kx.dart';
import '../../api/secure_key.dart';
import '../../api/sodium_exception.dart';
import '../bindings/libsodium.ffi.wrapper.dart';
import '../bindings/memory_protection.dart';
import '../bindings/secure_key_native.dart';
import '../bindings/sodium_pointer.dart';
import 'helpers/keygen_mixin.dart';
import 'secure_key_ffi.dart';

/// @nodoc
@internal
class KxFFI with KxValidations, KeygenMixin implements Kx {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  KxFFI(this.sodium);

  @override
  int get publicKeyBytes => sodium.crypto_kx_publickeybytes();

  @override
  int get secretKeyBytes => sodium.crypto_kx_secretkeybytes();

  @override
  int get seedBytes => sodium.crypto_kx_seedbytes();

  @override
  int get sessionKeyBytes => sodium.crypto_kx_sessionkeybytes();

  @override
  KeyPair keyPair() => keyPairImpl(
    sodium: sodium,
    secretKeyBytes: secretKeyBytes,
    publicKeyBytes: publicKeyBytes,
    implementation: sodium.crypto_kx_keypair,
  );

  @override
  KeyPair seedKeyPair(SecureKey seed) {
    validateSeed(seed);
    return seedKeyPairImpl(
      sodium: sodium,
      seed: seed,
      secretKeyBytes: secretKeyBytes,
      publicKeyBytes: publicKeyBytes,
      implementation: sodium.crypto_kx_seed_keypair,
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

    SecureKeyFFI? rxKey;
    SecureKeyFFI? txKey;
    SodiumPointer<UnsignedChar>? clientPublicKeyPtr;
    SodiumPointer<UnsignedChar>? serverPublicKeyPtr;
    try {
      rxKey = SecureKeyFFI.alloc(sodium, sessionKeyBytes);
      txKey = SecureKeyFFI.alloc(sodium, sessionKeyBytes);
      clientPublicKeyPtr = clientPublicKey.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      serverPublicKeyPtr = serverPublicKey.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = rxKey.runUnlockedNative(
        (rxKeyPtr) => txKey!.runUnlockedNative(
          (txKeyPtr) => clientSecretKey.runUnlockedNative(
            sodium,
            (clientSecretKeyPtr) => sodium.crypto_kx_client_session_keys(
              rxKeyPtr.ptr,
              txKeyPtr.ptr,
              clientPublicKeyPtr!.ptr,
              clientSecretKeyPtr.ptr,
              serverPublicKeyPtr!.ptr,
            ),
          ),
          writable: true,
        ),
        writable: true,
      );
      SodiumException.checkSucceededInt(result);

      return SessionKeys(rx: rxKey, tx: txKey);
    } catch (e) {
      rxKey?.dispose();
      txKey?.dispose();
      rethrow;
    } finally {
      clientPublicKeyPtr?.dispose();
      serverPublicKeyPtr?.dispose();
    }
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

    SecureKeyFFI? rxKey;
    SecureKeyFFI? txKey;
    SodiumPointer<UnsignedChar>? serverPublicKeyPtr;
    SodiumPointer<UnsignedChar>? clientPublicKeyPtr;
    try {
      rxKey = SecureKeyFFI.alloc(sodium, sessionKeyBytes);
      txKey = SecureKeyFFI.alloc(sodium, sessionKeyBytes);
      serverPublicKeyPtr = serverPublicKey.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      clientPublicKeyPtr = clientPublicKey.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = rxKey.runUnlockedNative(
        (rxKeyPtr) => txKey!.runUnlockedNative(
          (txKeyPtr) => serverSecretKey.runUnlockedNative(
            sodium,
            (serverSecretKeyPtr) => sodium.crypto_kx_server_session_keys(
              rxKeyPtr.ptr,
              txKeyPtr.ptr,
              serverPublicKeyPtr!.ptr,
              serverSecretKeyPtr.ptr,
              clientPublicKeyPtr!.ptr,
            ),
          ),
          writable: true,
        ),
        writable: true,
      );
      SodiumException.checkSucceededInt(result);

      return SessionKeys(rx: rxKey, tx: txKey);
    } catch (e) {
      rxKey?.dispose();
      txKey?.dispose();
      rethrow;
    } finally {
      serverPublicKeyPtr?.dispose();
      clientPublicKeyPtr?.dispose();
    }
  }
}
