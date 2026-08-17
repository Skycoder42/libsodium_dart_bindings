import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/box.dart';
import '../../api/detached_cipher_result.dart';
import '../../api/key_pair.dart';
import '../../api/secure_key.dart';
import '../../api/sodium_exception.dart';
import '../bindings/libsodium.ffi.wrapper.dart';
import '../bindings/secure_key_native.dart';
import '../bindings/sodium_scope.dart';
import 'helpers/keygen_mixin.dart';
import 'secure_key_ffi.dart';

/// @nodoc
@internal
class PrecalculatedBoxFFI implements PrecalculatedBox {
  /// @nodoc
  final BoxFFI box;

  /// @nodoc
  final SecureKeyFFI sharedKey;

  /// @nodoc
  new(this.box, this.sharedKey);

  @override
  Uint8List easy({required Uint8List message, required Uint8List nonce}) {
    box.validateNonce(nonce);

    return sodiumScope(box.sodium, (scope) {
      final dataPtr = scope.alloc<UnsignedChar>(message.length + box.macBytes)
        ..fill(List<int>.filled(box.macBytes, 0))
        ..fill(message, offset: box.macBytes);
      final noncePtr = scope.copyList<UnsignedChar>(nonce);

      final result = sharedKey.runUnlockedNative(
        (sharedKeyPtr) => box.sodium.crypto_box_easy_afternm(
          dataPtr.ptr,
          dataPtr.viewAt(box.macBytes).ptr,
          message.length,
          noncePtr.ptr,
          sharedKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return scope.takeBytes(dataPtr);
    });
  }

  @override
  Uint8List openEasy({
    required Uint8List cipherText,
    required Uint8List nonce,
  }) {
    box
      ..validateEasyCipherText(cipherText)
      ..validateNonce(nonce);

    return sodiumScope(box.sodium, (scope) {
      final dataPtr = scope.copyList<UnsignedChar>(
        cipherText,
        memoryProtection: .readWrite,
      );
      final noncePtr = scope.copyList<UnsignedChar>(nonce);

      final result = sharedKey.runUnlockedNative(
        (sharedKeyPtr) => box.sodium.crypto_box_open_easy_afternm(
          dataPtr.viewAt(box.macBytes).ptr,
          dataPtr.ptr,
          dataPtr.count,
          noncePtr.ptr,
          sharedKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return Uint8List.sublistView(
        scope.takeBytes<Uint8List>(dataPtr),
        box.macBytes,
      );
    });
  }

  @override
  DetachedCipherResult detached({
    required Uint8List message,
    required Uint8List nonce,
  }) {
    box.validateNonce(nonce);

    return sodiumScope(box.sodium, (scope) {
      final dataPtr = scope.copyList<UnsignedChar>(
        message,
        memoryProtection: .readWrite,
      );
      final noncePtr = scope.copyList<UnsignedChar>(nonce);
      final macPtr = scope.alloc<UnsignedChar>(box.macBytes);

      final result = sharedKey.runUnlockedNative(
        (sharedKeyPtr) => box.sodium.crypto_box_detached_afternm(
          dataPtr.ptr,
          macPtr.ptr,
          dataPtr.ptr,
          dataPtr.count,
          noncePtr.ptr,
          sharedKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return DetachedCipherResult(
        cipherText: scope.takeBytes(dataPtr),
        mac: scope.takeBytes(macPtr),
      );
    });
  }

  @override
  Uint8List openDetached({
    required Uint8List cipherText,
    required Uint8List mac,
    required Uint8List nonce,
  }) {
    box
      ..validateMac(mac)
      ..validateNonce(nonce);

    return sodiumScope(box.sodium, (scope) {
      final dataPtr = scope.copyList<UnsignedChar>(
        cipherText,
        memoryProtection: .readWrite,
      );
      final macPtr = scope.copyList<UnsignedChar>(mac);
      final noncePtr = scope.copyList<UnsignedChar>(nonce);

      final result = sharedKey.runUnlockedNative(
        (sharedKeyPtr) => box.sodium.crypto_box_open_detached_afternm(
          dataPtr.ptr,
          dataPtr.ptr,
          macPtr.ptr,
          dataPtr.count,
          noncePtr.ptr,
          sharedKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return scope.takeBytes(dataPtr);
    });
  }

  @override
  void dispose() => sharedKey.dispose();
}

/// @nodoc
@internal
class BoxFFI with BoxValidations, KeygenMixin implements Box {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  new(this.sodium);

  @override
  int get publicKeyBytes => sodium.crypto_box_publickeybytes();

  @override
  int get secretKeyBytes => sodium.crypto_box_secretkeybytes();

  @override
  int get macBytes => sodium.crypto_box_macbytes();

  @override
  int get nonceBytes => sodium.crypto_box_noncebytes();

  @override
  int get seedBytes => sodium.crypto_box_seedbytes();

  @override
  int get sealBytes => sodium.crypto_box_sealbytes();

  @override
  KeyPair keyPair() => keyPairImpl(
    sodium: sodium,
    secretKeyBytes: secretKeyBytes,
    publicKeyBytes: publicKeyBytes,
    implementation: sodium.crypto_box_keypair,
  );

  @override
  KeyPair seedKeyPair(SecureKey seed) {
    validateSeed(seed);
    return seedKeyPairImpl(
      sodium: sodium,
      seed: seed,
      secretKeyBytes: secretKeyBytes,
      publicKeyBytes: publicKeyBytes,
      implementation: sodium.crypto_box_seed_keypair,
    );
  }

  @override
  Uint8List easy({
    required Uint8List message,
    required Uint8List nonce,
    required Uint8List publicKey,
    required SecureKey secretKey,
  }) {
    validateNonce(nonce);
    validatePublicKey(publicKey);
    validateSecretKey(secretKey);

    return sodiumScope(sodium, (scope) {
      final dataPtr = scope.alloc<UnsignedChar>(message.length + macBytes)
        ..fill(List<int>.filled(macBytes, 0))
        ..fill(message, offset: macBytes);
      final noncePtr = scope.copyList<UnsignedChar>(nonce);
      final publicKeyPtr = scope.copyList<UnsignedChar>(publicKey);

      final result = secretKey.runUnlockedNative(
        sodium,
        (secretKeyPtr) => sodium.crypto_box_easy(
          dataPtr.ptr,
          dataPtr.viewAt(macBytes).ptr,
          message.length,
          noncePtr.ptr,
          publicKeyPtr.ptr,
          secretKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return scope.takeBytes(dataPtr);
    });
  }

  @override
  Uint8List openEasy({
    required Uint8List cipherText,
    required Uint8List nonce,
    required Uint8List publicKey,
    required SecureKey secretKey,
  }) {
    validateEasyCipherText(cipherText);
    validateNonce(nonce);
    validatePublicKey(publicKey);
    validateSecretKey(secretKey);

    return sodiumScope(sodium, (scope) {
      final dataPtr = scope.copyList<UnsignedChar>(
        cipherText,
        memoryProtection: .readWrite,
      );
      final noncePtr = scope.copyList<UnsignedChar>(nonce);
      final publicKeyPtr = scope.copyList<UnsignedChar>(publicKey);

      final result = secretKey.runUnlockedNative(
        sodium,
        (secretKeyPtr) => sodium.crypto_box_open_easy(
          dataPtr.viewAt(macBytes).ptr,
          dataPtr.ptr,
          dataPtr.count,
          noncePtr.ptr,
          publicKeyPtr.ptr,
          secretKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return Uint8List.sublistView(
        scope.takeBytes<Uint8List>(dataPtr),
        macBytes,
      );
    });
  }

  @override
  DetachedCipherResult detached({
    required Uint8List message,
    required Uint8List nonce,
    required Uint8List publicKey,
    required SecureKey secretKey,
  }) {
    validateNonce(nonce);
    validatePublicKey(publicKey);
    validateSecretKey(secretKey);

    return sodiumScope(sodium, (scope) {
      final dataPtr = scope.copyList<UnsignedChar>(
        message,
        memoryProtection: .readWrite,
      );
      final noncePtr = scope.copyList<UnsignedChar>(nonce);
      final publicKeyPtr = scope.copyList<UnsignedChar>(publicKey);
      final macPtr = scope.alloc<UnsignedChar>(macBytes);

      final result = secretKey.runUnlockedNative(
        sodium,
        (secretKeyPtr) => sodium.crypto_box_detached(
          dataPtr.ptr,
          macPtr.ptr,
          dataPtr.ptr,
          dataPtr.count,
          noncePtr.ptr,
          publicKeyPtr.ptr,
          secretKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return DetachedCipherResult(
        cipherText: scope.takeBytes(dataPtr),
        mac: scope.takeBytes(macPtr),
      );
    });
  }

  @override
  Uint8List openDetached({
    required Uint8List cipherText,
    required Uint8List mac,
    required Uint8List nonce,
    required Uint8List publicKey,
    required SecureKey secretKey,
  }) {
    validateMac(mac);
    validateNonce(nonce);
    validatePublicKey(publicKey);
    validateSecretKey(secretKey);

    return sodiumScope(sodium, (scope) {
      final dataPtr = scope.copyList<UnsignedChar>(
        cipherText,
        memoryProtection: .readWrite,
      );
      final macPtr = scope.copyList<UnsignedChar>(mac);
      final noncePtr = scope.copyList<UnsignedChar>(nonce);
      final publicKeyPtr = scope.copyList<UnsignedChar>(publicKey);

      final result = secretKey.runUnlockedNative(
        sodium,
        (secretKeyPtr) => sodium.crypto_box_open_detached(
          dataPtr.ptr,
          dataPtr.ptr,
          macPtr.ptr,
          dataPtr.count,
          noncePtr.ptr,
          publicKeyPtr.ptr,
          secretKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return scope.takeBytes(dataPtr);
    });
  }

  @override
  PrecalculatedBox precalculate({
    required Uint8List publicKey,
    required SecureKey secretKey,
  }) {
    validatePublicKey(publicKey);
    validateSecretKey(secretKey);

    return sodiumScope(sodium, (scope) {
      final publicKeyPtr = scope.copyList<UnsignedChar>(publicKey);
      final sharedKey = scope.allocSecureKey(sodium.crypto_box_beforenmbytes());

      final result = sharedKey.runUnlockedNative(
        (sharedKeyPtr) => secretKey.runUnlockedNative(
          sodium,
          (secretKeyPtr) => sodium.crypto_box_beforenm(
            sharedKeyPtr.ptr,
            publicKeyPtr.ptr,
            secretKeyPtr.ptr,
          ),
        ),
        writable: true,
      );
      SodiumException.checkSucceededInt(result);

      return PrecalculatedBoxFFI(this, scope.takeSecureKey(sharedKey));
    });
  }

  @override
  Uint8List seal({required Uint8List message, required Uint8List publicKey}) {
    validatePublicKey(publicKey);

    return sodiumScope(sodium, (scope) {
      final dataPtr = scope.alloc<UnsignedChar>(message.length + sealBytes)
        ..fill(List<int>.filled(sealBytes, 0))
        ..fill(message, offset: sealBytes);
      final publicKeyPtr = scope.copyList<UnsignedChar>(publicKey);

      final result = sodium.crypto_box_seal(
        dataPtr.ptr,
        dataPtr.viewAt(sealBytes).ptr,
        message.length,
        publicKeyPtr.ptr,
      );
      SodiumException.checkSucceededInt(result);

      return scope.takeBytes(dataPtr);
    });
  }

  @override
  Uint8List sealOpen({
    required Uint8List cipherText,
    required Uint8List publicKey,
    required SecureKey secretKey,
  }) {
    validateSealCipherText(cipherText);
    validatePublicKey(publicKey);
    validateSecretKey(secretKey);

    return sodiumScope(sodium, (scope) {
      final dataPtr = scope.copyList<UnsignedChar>(
        cipherText,
        memoryProtection: .readWrite,
      );
      final publicKeyPtr = scope.copyList<UnsignedChar>(publicKey);

      final result = secretKey.runUnlockedNative(
        sodium,
        (secretKeyPtr) => sodium.crypto_box_seal_open(
          dataPtr.viewAt(sealBytes).ptr,
          dataPtr.ptr,
          dataPtr.count,
          publicKeyPtr.ptr,
          secretKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return Uint8List.sublistView(
        scope.takeBytes<Uint8List>(dataPtr),
        sealBytes,
      );
    });
  }
}
