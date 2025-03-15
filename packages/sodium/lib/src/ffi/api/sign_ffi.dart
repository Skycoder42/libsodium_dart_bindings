import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/key_pair.dart';
import '../../api/secure_key.dart';
import '../../api/sign.dart';
import '../../api/sodium_exception.dart';
import '../bindings/libsodium.ffi.dart';
import '../bindings/memory_protection.dart';
import '../bindings/secure_key_native.dart';
import '../bindings/sodium_pointer.dart';
import 'helpers/keygen_mixin.dart';
import 'helpers/sign/signature_consumer_ffi.dart';
import 'helpers/sign/verification_consumer_ffi.dart';

/// @nodoc
@internal
class SignFFI with SignValidations, KeygenMixin implements Sign {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  SignFFI(this.sodium);

  @override
  int get publicKeyBytes => sodium.crypto_sign_publickeybytes();

  @override
  int get secretKeyBytes => sodium.crypto_sign_secretkeybytes();

  @override
  int get bytes => sodium.crypto_sign_bytes();

  @override
  int get seedBytes => sodium.crypto_sign_seedbytes();

  @override
  KeyPair keyPair() => keyPairImpl(
    sodium: sodium,
    secretKeyBytes: secretKeyBytes,
    publicKeyBytes: publicKeyBytes,
    implementation: sodium.crypto_sign_keypair,
  );

  @override
  KeyPair seedKeyPair(SecureKey seed) {
    validateSeed(seed);
    return seedKeyPairImpl(
      sodium: sodium,
      seed: seed,
      secretKeyBytes: secretKeyBytes,
      publicKeyBytes: publicKeyBytes,
      implementation: sodium.crypto_sign_seed_keypair,
    );
  }

  @override
  @pragma('vm:entry-point')
  Uint8List call({required Uint8List message, required SecureKey secretKey}) {
    validateSecretKey(secretKey);

    SodiumPointer<UnsignedChar>? dataPtr;
    try {
      dataPtr =
          SodiumPointer.alloc(sodium, count: message.length + bytes)
            ..fill(List<int>.filled(bytes, 0))
            ..fill(message, offset: bytes);

      final result = secretKey.runUnlockedNative(
        sodium,
        (secretKeyPtr) => sodium.crypto_sign(
          dataPtr!.ptr,
          nullptr,
          dataPtr.viewAt(bytes).ptr,
          message.length,
          secretKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return dataPtr.asListView(owned: true);
    } catch (_) {
      dataPtr?.dispose();
      rethrow;
    }
  }

  @override
  Uint8List open({
    required Uint8List signedMessage,
    required Uint8List publicKey,
  }) {
    validateSignedMessage(signedMessage);
    validatePublicKey(publicKey);

    SodiumPointer<UnsignedChar>? dataPtr;
    SodiumPointer<UnsignedChar>? publicKeyPtr;
    try {
      dataPtr = signedMessage.toSodiumPointer(sodium);
      publicKeyPtr = publicKey.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = sodium.crypto_sign_open(
        dataPtr.viewAt(bytes).ptr,
        nullptr,
        dataPtr.ptr,
        dataPtr.count,
        publicKeyPtr.ptr,
      );
      SodiumException.checkSucceededInt(result);

      return Uint8List.sublistView(
        dataPtr.asListView<Uint8List>(owned: true),
        bytes,
      );
    } catch (_) {
      dataPtr?.dispose();
      rethrow;
    } finally {
      publicKeyPtr?.dispose();
    }
  }

  @override
  Uint8List detached({
    required Uint8List message,
    required SecureKey secretKey,
  }) {
    validateSecretKey(secretKey);

    SodiumPointer<UnsignedChar>? messagePtr;
    SodiumPointer<UnsignedChar>? signaturePtr;
    try {
      messagePtr = message.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      signaturePtr = SodiumPointer.alloc(sodium, count: bytes);

      final result = secretKey.runUnlockedNative(
        sodium,
        (secretKeyPtr) => sodium.crypto_sign_detached(
          signaturePtr!.ptr,
          nullptr,
          messagePtr!.ptr,
          messagePtr.count,
          secretKeyPtr.ptr,
        ),
      );
      SodiumException.checkSucceededInt(result);

      return signaturePtr.asListView(owned: true);
    } catch (_) {
      signaturePtr?.dispose();
      rethrow;
    } finally {
      messagePtr?.dispose();
    }
  }

  @override
  bool verifyDetached({
    required Uint8List message,
    required Uint8List signature,
    required Uint8List publicKey,
  }) {
    validateSignature(signature);
    validatePublicKey(publicKey);

    SodiumPointer<UnsignedChar>? messagePtr;
    SodiumPointer<UnsignedChar>? signaturePtr;
    SodiumPointer<UnsignedChar>? publicKeyPtr;
    try {
      messagePtr = message.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      signaturePtr = signature.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      publicKeyPtr = publicKey.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );

      final result = sodium.crypto_sign_verify_detached(
        signaturePtr.ptr,
        messagePtr.ptr,
        messagePtr.count,
        publicKeyPtr.ptr,
      );

      return result == 0;
    } finally {
      messagePtr?.dispose();
      signaturePtr?.dispose();
      publicKeyPtr?.dispose();
    }
  }

  @override
  SignatureConsumer createConsumer({required SecureKey secretKey}) {
    validateSecretKey(secretKey);

    return SignatureConsumerFFI(sodium: sodium, secretKey: secretKey);
  }

  @override
  VerificationConsumer createVerifyConsumer({
    required Uint8List signature,
    required Uint8List publicKey,
  }) {
    validateSignature(signature);
    validatePublicKey(publicKey);

    return VerificationConsumerFFI(
      sodium: sodium,
      signature: signature,
      publicKey: publicKey,
    );
  }
}
