import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/auth.dart';
import 'package:test/test.dart';

import '../../secure_key_fake.dart';
import '../../test_validator.dart';

class MockAuth extends Mock with AuthValidations implements Auth {}

void main() {
  group('AuthValidations', () {
    late MockAuth sutMock;

    setUp(() {
      sutMock = MockAuth();
    });

    testCheckIsSame(
      'validateTag',
      source: () => sutMock.bytes,
      sut: (value) => sutMock.validateTag(Uint8List(value)),
    );

    testCheckIsSame(
      'validateKey',
      source: () => sutMock.keyBytes,
      sut: (value) => sutMock.validateKey(SecureKeyFake.empty(value)),
    );
  });
}
