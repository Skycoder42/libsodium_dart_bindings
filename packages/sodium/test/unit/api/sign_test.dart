// ignore_for_file: unnecessary_lambdas for mocking

import 'dart:async';
import 'dart:typed_data';

import 'package:dart_test_tools/test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sign.dart';
import 'package:test/test.dart';

import '../../secure_key_fake.dart';
import '../../test_validator.dart';

class MockSign extends Mock with SignValidations implements Sign {}

class MockSignatureConsumer extends Mock implements SignatureConsumer {}

class MockVerificationConsumer extends Mock implements VerificationConsumer {}

void main() {
  setUpAll(() {
    registerFallbackValue(SecureKeyFake.empty(0));
    registerFallbackValue(const Stream<Uint8List>.empty());
    registerFallbackValue(Uint8List(0));
  });

  group('SignValidations', () {
    late MockSign sutMock;

    setUp(() {
      sutMock = MockSign();
    });

    testCheckIsSame(
      'validatePublicKey',
      source: () => sutMock.publicKeyBytes,
      sut: (value) => sutMock.validatePublicKey(Uint8List(value)),
    );

    testCheckIsSame(
      'validateSecretKey',
      source: () => sutMock.secretKeyBytes,
      sut: (value) => sutMock.validateSecretKey(SecureKeyFake.empty(value)),
    );

    testCheckIsSame(
      'validateSignature',
      source: () => sutMock.bytes,
      sut: (value) => sutMock.validateSignature(Uint8List(value)),
    );

    testCheckAtLeast(
      'validateSignedMessage',
      source: () => sutMock.bytes,
      sut: (value) => sutMock.validateSignedMessage(Uint8List(value)),
    );

    testCheckIsSame(
      'validateSeed',
      source: () => sutMock.seedBytes,
      sut: (value) => sutMock.validateSeed(SecureKeyFake.empty(value)),
    );

    test('stream pipes messages into consumer', () async {
      final mockConsumer = MockSignatureConsumer();

      const messageStream = Stream<Uint8List>.empty();
      final secretKey = SecureKeyFake(List.generate(15, (index) => index));
      final signature = Uint8List.fromList(
        List.generate(5, (index) => 100 + index),
      );

      when(
        () => sutMock.createConsumer(secretKey: any(named: 'secretKey')),
      ).thenReturn(mockConsumer);
      when(() => mockConsumer.addStream(any())).thenReturnAsync(null);
      when(() => mockConsumer.close()).thenReturnAsync(signature);

      final res = await sutMock.stream(
        messages: messageStream,
        secretKey: secretKey,
      );

      expect(res, signature);
      verifyInOrder([
        () => sutMock.createConsumer(secretKey: secretKey),
        () => mockConsumer.addStream(messageStream),
        () => mockConsumer.close(),
      ]);
    });

    test('verifyStream pipes messages into consumer', () async {
      final mockConsumer = MockVerificationConsumer();

      const messageStream = Stream<Uint8List>.empty();
      final publicKey = Uint8List.fromList(List.generate(15, (index) => index));
      final signature = Uint8List.fromList(
        List.generate(5, (index) => 100 + index),
      );

      when(
        () => sutMock.createVerifyConsumer(
          publicKey: any(named: 'publicKey'),
          signature: any(named: 'signature'),
        ),
      ).thenReturn(mockConsumer);
      when(() => mockConsumer.addStream(any())).thenReturnAsync(null);
      when(() => mockConsumer.close()).thenReturnAsync(true);

      final res = await sutMock.verifyStream(
        messages: messageStream,
        signature: signature,
        publicKey: publicKey,
      );

      expect(res, isTrue);
      verifyInOrder([
        () => sutMock.createVerifyConsumer(
          publicKey: publicKey,
          signature: signature,
        ),
        () => mockConsumer.addStream(messageStream),
        () => mockConsumer.close(),
      ]);
    });
  });
}
