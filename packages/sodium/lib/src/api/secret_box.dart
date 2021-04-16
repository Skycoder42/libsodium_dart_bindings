import 'dart:typed_data';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'secret_box.freezed.dart';

@freezed
class DetachedSecretBoxResult with _$DetachedSecretBoxResult {
  const factory DetachedSecretBoxResult({
    required Uint8List cipher,
    required Uint8List mac,
  }) = _DetachedSecretBoxResult;
}

abstract class SecretBox {
  const SecretBox._(); // coverage:ignore-line

  int get keyBytes;
  int get macBytes;
  int get nonceBytes;

  // crypto_secretbox_primitive

  Uint8List keygen();

  Uint8List easy({
    required Uint8List message,
    required Uint8List nonce,
    required Uint8List key,
  });

  Uint8List openEasy({
    required Uint8List ciphertext,
    required Uint8List nonce,
    required Uint8List key,
  });

  DetachedSecretBoxResult detached({
    required Uint8List message,
    required Uint8List nonce,
    required Uint8List key,
  });

  Uint8List openDetached({
    required Uint8List ciphertext,
    required Uint8List mac,
    required Uint8List nonce,
    required Uint8List key,
  });
}

@internal
mixin SecretBoxValidations implements SecretBox {
  void validateNonce(Uint8List nonce) => RangeError.checkValueInInterval(
        nonce.length,
        nonceBytes,
        nonceBytes,
        'nonce',
      );

  void validateKey(Uint8List key) => RangeError.checkValueInInterval(
        key.length,
        keyBytes,
        keyBytes,
        'key',
      );

  void validateMac(Uint8List mac) => RangeError.checkValueInInterval(
        mac.length,
        macBytes,
        macBytes,
        'mac',
      );
}
