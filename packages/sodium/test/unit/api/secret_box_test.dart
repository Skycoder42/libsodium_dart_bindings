import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/secret_box.dart';
import 'package:test/test.dart';

import '../../secure_key_fake.dart';
import '../../test_validator.dart';

class MockSecretBox extends Mock
    with SecretBoxValidations
    implements SecretBox {}

void main() {
  group('SecretBoxValidations', () {
    late MockSecretBox sutMock;

    setUp(() {
      sutMock = MockSecretBox();
    });

    testCheckIsSame(
      'validateNonce',
      source: () => sutMock.nonceBytes,
      sut: (value) => sutMock.validateNonce(Uint8List(value)),
    );

    testCheckIsSame(
      'validateKey',
      source: () => sutMock.keyBytes,
      sut: (value) => sutMock.validateKey(SecureKeyFake.empty(value)),
    );

    testCheckIsSame(
      'validateMac',
      source: () => sutMock.macBytes,
      sut: (value) => sutMock.validateMac(Uint8List(value)),
    );

    testCheckAtLeast(
      'validateEasyCipherText',
      source: () => sutMock.macBytes,
      sut: (value) => sutMock.validateEasyCipherText(Uint8List(value)),
    );
  });
}
