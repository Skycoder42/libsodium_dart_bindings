import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sumo/scalarmult.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../../../test_validator.dart';

class MockScalarmult extends Mock
    with ScalarmultValidations
    implements Scalarmult {}

void main() {
  group('$ScalarmultValidations', () {
    late MockScalarmult sutMock;

    setUp(() {
      sutMock = MockScalarmult();
    });

    testCheckIsSame(
      'validatePublicKey',
      source: () => sutMock.bytes,
      sut: (value) => sutMock.validatePublicKey(Uint8List(value)),
    );

    testCheckIsSame(
      'validateSecretKey',
      source: () => sutMock.scalarBytes,
      sut: (value) => sutMock.validateSecretKey(SecureKeyFake.empty(value)),
    );
  });
}
