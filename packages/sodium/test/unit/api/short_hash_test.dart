import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/short_hash.dart';
import 'package:test/test.dart';

import '../../secure_key_fake.dart';
import '../../test_validator.dart';

class MockShortHash extends Mock
    with ShortHashValidations
    implements ShortHash {}

void main() {
  group('ShortHashValidations', () {
    late MockShortHash sutMock;

    setUp(() {
      sutMock = MockShortHash();
    });

    testCheckIsSame(
      'validateKey',
      source: () => sutMock.keyBytes,
      sut: (value) => sutMock.validateKey(SecureKeyFake.empty(value)),
    );
  });
}
