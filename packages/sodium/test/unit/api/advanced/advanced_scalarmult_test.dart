import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/advanced/advanced_scalar_mult.dart';
import 'package:sodium/src/api/secure_key.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../../../test_validator.dart';

class MockAdvancedScalarMult extends Mock
    with AdvancedScalarMultValidations
    implements AdvancedScalarMult {}

class MockSecureKey extends Mock implements SecureKey {}

void main() {
  group('AdvancedScalarMultValidations', () {
    late MockAdvancedScalarMult sutMock;

    setUp(() {
      sutMock = MockAdvancedScalarMult();
    });

    testCheckIsSame(
      'validatePublicKey',
      source: () => sutMock.bytes,
      sut: (value) => sutMock.validatePublicKey(Uint8List(value)),
    );

    testCheckIsSame(
      'validateSecretKey',
      source: () => sutMock.scalarBytes,
      sut: (value) => sutMock.validateSecretKey(
        SecureKeyFake.empty(value),
      ),
    );
  });
}
