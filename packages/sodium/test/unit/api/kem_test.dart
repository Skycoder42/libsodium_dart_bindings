import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/kem.dart';
import 'package:test/test.dart';

import '../../secure_key_fake.dart';
import '../../test_validator.dart';

class MockKem extends Mock with KemValidations implements Kem {}

void main() {
  group('KemValidations', () {
    late MockKem sutMock;

    setUp(() {
      sutMock = MockKem();
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
      'validateCiphertext',
      source: () => sutMock.ciphertextBytes,
      sut: (value) => sutMock.validateCiphertext(Uint8List(value)),
    );

    testCheckIsSame(
      'validateSeed',
      source: () => sutMock.seedBytes,
      sut: (value) => sutMock.validateSeed(SecureKeyFake.empty(value)),
    );
  });
}
