import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/box.dart';
import '../../api/detached_cipher_result.dart';
import '../../api/key_pair.dart';
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
class PrecalculatedBoxFFI implements PrecalculatedBox {
  /// @nodoc
  final BoxFFI box;

  /// @nodoc
  final SecureKeyFFI sharedKey;

  /// @nodoc
  PrecalculatedBoxFFI(this.box, this.sharedKey);

  @override
  Uint8List easy({required Uint8List message, required Uint8List nonce}) {
    box.validateNonce(nonce);

    SodiumPointer<UnsignedChar>? dataPtr;
    SodiumPointer<UnsignedChar>? noncePtr;
    try {
      dataPtr =
          SodiumPointer.alloc(box.sodium, count: message.length + box.macBytes)
            ..fill(List<int>.filled(box.macBytes, 0))
            ..fill(message, offset: box.macBytes);
      noncePtr = nonce.toSodiumPointer(
        box.sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = sharedKey.runUnlockedNative(
        (sharedKeyPtr) => box.sodium.crypto_box_easy_afternm(
          dataPtr!.ptr,
          dataPtr.viewAt(box.macBytes).ptr,
          message.length,
          noncePtr!.ptr,
          sharedKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return dataPtr.asListView(owned: true);
    } catch (_) {
      dataPtr?.dispose();
      rethrow;
    } finally {
      noncePtr?.dispose();
    }
  }

  @override
  Uint8List openEasy({
    required Uint8List cipherText,
    required Uint8List nonce,
  }) {
    box
      ..validateEasyCipherText(cipherText)
      ..validateNonce(nonce);

    SodiumPointer<UnsignedChar>? dataPtr;
    SodiumPointer<UnsignedChar>? noncePtr;
    try {
      dataPtr = cipherText.toSodiumPointer(box.sodium);
      noncePtr = nonce.toSodiumPointer(
        box.sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = sharedKey.runUnlockedNative(
        (sharedKeyPtr) => box.sodium.crypto_box_open_easy_afternm(
          dataPtr!.viewAt(box.macBytes).ptr,
          dataPtr.ptr,
          dataPtr.count,
          noncePtr!.ptr,
          sharedKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return Uint8List.sublistView(
        dataPtr.asListView<Uint8List>(owned: true),
        box.macBytes,
      );
    } catch (_) {
      dataPtr?.dispose();
      rethrow;
    } finally {
      noncePtr?.dispose();
    }
  }

  @override
  DetachedCipherResult detached({
    required Uint8List message,
    required Uint8List nonce,
  }) {
    box.validateNonce(nonce);

    SodiumPointer<UnsignedChar>? dataPtr;
    SodiumPointer<UnsignedChar>? noncePtr;
    SodiumPointer<UnsignedChar>? macPtr;
    try {
      dataPtr = message.toSodiumPointer(box.sodium);
      noncePtr = nonce.toSodiumPointer(
        box.sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      macPtr = SodiumPointer.alloc(box.sodium, count: box.macBytes);

      final result = sharedKey.runUnlockedNative(
        (sharedKeyPtr) => box.sodium.crypto_box_detached_afternm(
          dataPtr!.ptr,
          macPtr!.ptr,
          dataPtr.ptr,
          dataPtr.count,
          noncePtr!.ptr,
          sharedKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return DetachedCipherResult(
        cipherText: dataPtr.asListView(owned: true),
        mac: macPtr.asListView(owned: true),
      );
    } catch (_) {
      dataPtr?.dispose();
      macPtr?.dispose();
      rethrow;
    } finally {
      noncePtr?.dispose();
    }
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

    SodiumPointer<UnsignedChar>? dataPtr;
    SodiumPointer<UnsignedChar>? macPtr;
    SodiumPointer<UnsignedChar>? noncePtr;
    try {
      dataPtr = cipherText.toSodiumPointer(box.sodium);
      macPtr = mac.toSodiumPointer(
        box.sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      noncePtr = nonce.toSodiumPointer(
        box.sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = sharedKey.runUnlockedNative(
        (sharedKeyPtr) => box.sodium.crypto_box_open_detached_afternm(
          dataPtr!.ptr,
          dataPtr.ptr,
          macPtr!.ptr,
          dataPtr.count,
          noncePtr!.ptr,
          sharedKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return dataPtr.asListView(owned: true);
    } catch (_) {
      dataPtr?.dispose();
      rethrow;
    } finally {
      macPtr?.dispose();
      noncePtr?.dispose();
    }
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
  BoxFFI(this.sodium);

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

    SodiumPointer<UnsignedChar>? dataPtr;
    SodiumPointer<UnsignedChar>? noncePtr;
    SodiumPointer<UnsignedChar>? publicKeyPtr;
    try {
      dataPtr = SodiumPointer.alloc(sodium, count: message.length + macBytes)
        ..fill(List<int>.filled(macBytes, 0))
        ..fill(message, offset: macBytes);
      noncePtr = nonce.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      publicKeyPtr = publicKey.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = secretKey.runUnlockedNative(
        sodium,
        (secretKeyPtr) => sodium.crypto_box_easy(
          dataPtr!.ptr,
          dataPtr.viewAt(macBytes).ptr,
          message.length,
          noncePtr!.ptr,
          publicKeyPtr!.ptr,
          secretKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return dataPtr.asListView(owned: true);
    } catch (_) {
      dataPtr?.dispose();
      rethrow;
    } finally {
      noncePtr?.dispose();
      publicKeyPtr?.dispose();
    }
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

    SodiumPointer<UnsignedChar>? dataPtr;
    SodiumPointer<UnsignedChar>? noncePtr;
    SodiumPointer<UnsignedChar>? publicKeyPtr;
    try {
      dataPtr = cipherText.toSodiumPointer(sodium);
      noncePtr = nonce.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      publicKeyPtr = publicKey.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = secretKey.runUnlockedNative(
        sodium,
        (secretKeyPtr) => sodium.crypto_box_open_easy(
          dataPtr!.viewAt(macBytes).ptr,
          dataPtr.ptr,
          dataPtr.count,
          noncePtr!.ptr,
          publicKeyPtr!.ptr,
          secretKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return Uint8List.sublistView(
        dataPtr.asListView<Uint8List>(owned: true),
        macBytes,
      );
    } catch (_) {
      dataPtr?.dispose();
      rethrow;
    } finally {
      noncePtr?.dispose();
      publicKeyPtr?.dispose();
    }
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

    SodiumPointer<UnsignedChar>? dataPtr;
    SodiumPointer<UnsignedChar>? noncePtr;
    SodiumPointer<UnsignedChar>? publicKeyPtr;
    SodiumPointer<UnsignedChar>? macPtr;
    try {
      dataPtr = message.toSodiumPointer(sodium);
      noncePtr = nonce.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      publicKeyPtr = publicKey.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      macPtr = SodiumPointer.alloc(sodium, count: macBytes);

      final result = secretKey.runUnlockedNative(
        sodium,
        (secretKeyPtr) => sodium.crypto_box_detached(
          dataPtr!.ptr,
          macPtr!.ptr,
          dataPtr.ptr,
          dataPtr.count,
          noncePtr!.ptr,
          publicKeyPtr!.ptr,
          secretKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return DetachedCipherResult(
        cipherText: dataPtr.asListView(owned: true),
        mac: macPtr.asListView(owned: true),
      );
    } catch (_) {
      dataPtr?.dispose();
      macPtr?.dispose();
      rethrow;
    } finally {
      noncePtr?.dispose();
      publicKeyPtr?.dispose();
    }
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

    SodiumPointer<UnsignedChar>? dataPtr;
    SodiumPointer<UnsignedChar>? macPtr;
    SodiumPointer<UnsignedChar>? noncePtr;
    SodiumPointer<UnsignedChar>? publicKeyPtr;
    try {
      dataPtr = cipherText.toSodiumPointer(sodium);
      macPtr = mac.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      noncePtr = nonce.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      publicKeyPtr = publicKey.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = secretKey.runUnlockedNative(
        sodium,
        (secretKeyPtr) => sodium.crypto_box_open_detached(
          dataPtr!.ptr,
          dataPtr.ptr,
          macPtr!.ptr,
          dataPtr.count,
          noncePtr!.ptr,
          publicKeyPtr!.ptr,
          secretKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return dataPtr.asListView(owned: true);
    } catch (_) {
      dataPtr?.dispose();
      rethrow;
    } finally {
      macPtr?.dispose();
      noncePtr?.dispose();
      publicKeyPtr?.dispose();
    }
  }

  @override
  PrecalculatedBox precalculate({
    required Uint8List publicKey,
    required SecureKey secretKey,
  }) {
    validatePublicKey(publicKey);
    validateSecretKey(secretKey);

    SecureKeyFFI? sharedKey;
    SodiumPointer<UnsignedChar>? publicKeyPtr;
    try {
      publicKeyPtr = publicKey.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      sharedKey = SecureKeyFFI.alloc(sodium, sodium.crypto_box_beforenmbytes());

      final result = sharedKey.runUnlockedNative(
        (sharedKeyPtr) => secretKey.runUnlockedNative(
          sodium,
          (secretKeyPtr) => sodium.crypto_box_beforenm(
            sharedKeyPtr.ptr,
            publicKeyPtr!.ptr,
            secretKeyPtr.ptr,
          ),
        ),
        writable: true,
      );
      SodiumException.checkSucceededInt(result);

      return PrecalculatedBoxFFI(this, sharedKey);
    } catch (e) {
      sharedKey?.dispose();
      rethrow;
    } finally {
      publicKeyPtr?.dispose();
    }
  }

  @override
  Uint8List seal({required Uint8List message, required Uint8List publicKey}) {
    validatePublicKey(publicKey);

    SodiumPointer<UnsignedChar>? dataPtr;
    SodiumPointer<UnsignedChar>? publicKeyPtr;
    try {
      dataPtr = SodiumPointer.alloc(sodium, count: message.length + sealBytes)
        ..fill(List<int>.filled(sealBytes, 0))
        ..fill(message, offset: sealBytes);
      publicKeyPtr = publicKey.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = sodium.crypto_box_seal(
        dataPtr.ptr,
        dataPtr.viewAt(sealBytes).ptr,
        message.length,
        publicKeyPtr.ptr,
      );
      SodiumException.checkSucceededInt(result);

      return dataPtr.asListView(owned: true);
    } catch (_) {
      dataPtr?.dispose();
      rethrow;
    } finally {
      publicKeyPtr?.dispose();
    }
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

    SodiumPointer<UnsignedChar>? dataPtr;
    SodiumPointer<UnsignedChar>? publicKeyPtr;
    try {
      dataPtr = cipherText.toSodiumPointer(sodium);
      publicKeyPtr = publicKey.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = secretKey.runUnlockedNative(
        sodium,
        (secretKeyPtr) => sodium.crypto_box_seal_open(
          dataPtr!.viewAt(sealBytes).ptr,
          dataPtr.ptr,
          dataPtr.count,
          publicKeyPtr!.ptr,
          secretKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return Uint8List.sublistView(
        dataPtr.asListView<Uint8List>(owned: true),
        sealBytes,
      );
    } catch (_) {
      dataPtr?.dispose();
      rethrow;
    } finally {
      publicKeyPtr?.dispose();
    }
  }
}
