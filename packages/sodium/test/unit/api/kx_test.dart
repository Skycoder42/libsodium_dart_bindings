// ignore_for_file: unnecessary_lambdas for mocking

import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/kx.dart';
import 'package:sodium/src/api/secure_key.dart';
import 'package:test/test.dart';

import '../../secure_key_fake.dart';
import '../../test_validator.dart';

class MockKx extends Mock with KxValidations implements Kx {}

class MockSecureKey extends Mock implements SecureKey {}

void main() {
  group('SessionKeys', () {
    final mockRx = MockSecureKey();
    final mockTx = MockSecureKey();

    late SessionKeys sut;

    setUp(() {
      reset(mockRx);
      reset(mockTx);

      sut = SessionKeys(rx: mockRx, tx: mockTx);
    });

    test('dispose calls dispose an rx and tx', () {
      sut.dispose();

      verify(() => mockRx.dispose());
      verify(() => mockTx.dispose());
    });
  });

  group('KdfValidations', () {
    late MockKx sutMock;

    setUp(() {
      sutMock = MockKx();
    });

    testCheckIsSame(
      'validatePublicKey',
      source: () => sutMock.publicKeyBytes,
      sut: (value) => sutMock.validatePublicKey(Uint8List(value), 'test'),
    );

    testCheckIsSame(
      'validateSecretKey',
      source: () => sutMock.secretKeyBytes,
      sut: (value) =>
          sutMock.validateSecretKey(SecureKeyFake.empty(value), 'test'),
    );

    testCheckIsSame(
      'validateSeed',
      source: () => sutMock.seedBytes,
      sut: (value) => sutMock.validateSeed(SecureKeyFake.empty(value)),
    );
  });
}
