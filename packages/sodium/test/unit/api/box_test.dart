import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/box.dart';
import 'package:test/test.dart';

import '../../secure_key_fake.dart';
import '../../test_validator.dart';

class MockBox extends Mock with BoxValidations implements Box {}

void main() {
  group('BoxValidations', () {
    late MockBox sutMock;

    setUp(() {
      sutMock = MockBox();
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
      'validateMac',
      source: () => sutMock.macBytes,
      sut: (value) => sutMock.validateMac(Uint8List(value)),
    );

    testCheckIsSame(
      'validateNonce',
      source: () => sutMock.nonceBytes,
      sut: (value) => sutMock.validateNonce(Uint8List(value)),
    );

    testCheckIsSame(
      'validateSeed',
      source: () => sutMock.seedBytes,
      sut: (value) => sutMock.validateSeed(SecureKeyFake.empty(value)),
    );

    testCheckAtLeast(
      'validateEasyCipherText',
      source: () => sutMock.macBytes,
      sut: (value) => sutMock.validateEasyCipherText(Uint8List(value)),
    );

    testCheckAtLeast(
      'validateSealCipherText',
      source: () => sutMock.sealBytes,
      sut: (value) => sutMock.validateSealCipherText(Uint8List(value)),
    );
  });
}
