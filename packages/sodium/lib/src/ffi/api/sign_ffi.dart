import 'dart:typed_data';

import '../../api/key_pair.dart';
import '../../api/secure_key.dart';
import '../../api/sign.dart';
import '../bindings/libsodium.ffi.dart';

class SignFFI implements Sign {
  final LibSodiumFFI sodium;

  SignFFI(this.sodium);

  @override
  // TODO: implement bytes
  int get bytes => throw UnimplementedError();

  @override
  Uint8List call({required Uint8List message, required SecureKey secretKey}) {
    // TODO: implement call
    throw UnimplementedError();
  }

  @override
  SignatureConsumer createConsumer(SecureKey secretKey) {
    // TODO: implement createConsumer
    throw UnimplementedError();
  }

  @override
  VerificationConsumer createVerifyConsumer(
      {required Uint8List signature, required Uint8List publicKey}) {
    // TODO: implement createVerifyConsumer
    throw UnimplementedError();
  }

  @override
  Uint8List detached(
      {required Uint8List message, required SecureKey secretKey}) {
    // TODO: implement detached
    throw UnimplementedError();
  }

  @override
  KeyPair keyPair() {
    // TODO: implement keyPair
    throw UnimplementedError();
  }

  @override
  Uint8List? open(
      {required Uint8List signedMessage, required Uint8List publicKey}) {
    // TODO: implement open
    throw UnimplementedError();
  }

  @override
  // TODO: implement publicKeyBytes
  int get publicKeyBytes => throw UnimplementedError();

  @override
  // TODO: implement secretKeyBytes
  int get secretKeyBytes => throw UnimplementedError();

  @override
  // TODO: implement seedBytes
  int get seedBytes => throw UnimplementedError();

  @override
  KeyPair seedKeyPair(SecureKey seed) {
    // TODO: implement seedKeyPair
    throw UnimplementedError();
  }

  @override
  Future<Uint8List> stream(
      {required Stream<Uint8List> message, required SecureKey secretKey}) {
    // TODO: implement stream
    throw UnimplementedError();
  }

  @override
  bool verifyDetached(
      {required Uint8List message,
      required Uint8List signature,
      required Uint8List publicKey}) {
    // TODO: implement verifyDetached
    throw UnimplementedError();
  }

  @override
  Future<bool> verifyStream(
      {required Stream<Uint8List> message,
      required Uint8List signature,
      required Uint8List publicKey}) {
    // TODO: implement verifyStream
    throw UnimplementedError();
  }
}
