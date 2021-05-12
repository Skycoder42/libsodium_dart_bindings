import 'dart:async';
import 'dart:typed_data';

import 'key_pair.dart';
import 'secure_key.dart';

abstract class SignatureConsumer implements StreamConsumer<Uint8List> {
  const SignatureConsumer._(); // coverage:ignore-line

  Future<Uint8List> get signature;

  @override
  Future<Uint8List> close();
}

abstract class VerificationConsumer implements StreamConsumer<Uint8List> {
  const VerificationConsumer._(); // coverage:ignore-line

  Future<bool> get signatureValid;

  @override
  Future<bool> close();
}

abstract class Sign {
  const Sign._(); // coverage:ignore-line

  int get publicKeyBytes;
  int get secretKeyBytes;
  int get bytes;
  int get seedBytes;

  KeyPair keyPair();

  KeyPair seedKeyPair(SecureKey seed);

  Uint8List call({
    required Uint8List message,
    required SecureKey secretKey,
  });

  Uint8List? open({
    required Uint8List signedMessage,
    required Uint8List publicKey,
  });

  Uint8List detached({
    required Uint8List message,
    required SecureKey secretKey,
  });

  bool verifyDetached({
    required Uint8List message,
    required Uint8List signature,
    required Uint8List publicKey,
  });

  SignatureConsumer createConsumer(SecureKey secretKey);

  VerificationConsumer createVerifyConsumer({
    required Uint8List signature,
    required Uint8List publicKey,
  });

  Future<Uint8List> stream({
    required Stream<Uint8List> message,
    required SecureKey secretKey,
  });

  Future<bool> verifyStream({
    required Stream<Uint8List> message,
    required Uint8List signature,
    required Uint8List publicKey,
  });
}
