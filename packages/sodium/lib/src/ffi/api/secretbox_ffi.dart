import 'dart:typed_data';

import 'package:sodium/src/api/secure_key.dart';
import 'package:sodium/src/ffi/api/secure_key_ffi.dart';

import '../../api/secret_box.dart';
import '../bindings/libsodium.ffi.dart';

class SecretBoxFII with SecretBoxValidations implements SecretBox {
  final LibSodiumFFI sodium;

  SecretBoxFII(this.sodium);

  @override
  int get keyBytes => sodium.crypto_secretbox_keybytes();

  @override
  int get macBytes => sodium.crypto_secretbox_macbytes();

  @override
  int get nonceBytes => sodium.crypto_secretbox_noncebytes();

  @override
  SecureKey keygen() {
    final key = SecureKeyFFI.alloc(sodium, keyBytes);
    try {
      key.runUnlockedRaw(
        (pointer) => sodium.crypto_secretbox_keygen(pointer.ptr),
        writable: true,
      );
      return key;
    } catch (e) {
      key.dispose();
      rethrow;
    }
  }

  @override
  Uint8List easy({
    required Uint8List message,
    required Uint8List nonce,
    required SecureKey key,
  }) {
    validateNonce(nonce);
    validateKey(key);
  }

  @override
  DetachedSecretBoxResult detached(
      {required Uint8List message,
      required Uint8List nonce,
      required SecureKey key}) {
    // TODO: implement detached
    throw UnimplementedError();
  }

  @override
  Uint8List openDetached(
      {required Uint8List ciphertext,
      required Uint8List mac,
      required Uint8List nonce,
      required SecureKey key}) {
    // TODO: implement openDetached
    throw UnimplementedError();
  }

  @override
  Uint8List openEasy(
      {required Uint8List ciphertext,
      required Uint8List nonce,
      required SecureKey key}) {
    // TODO: implement openEasy
    throw UnimplementedError();
  }
}
