import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/secret_stream.dart';
import 'package:test/test.dart';

import '../../secure_key_fake.dart';
import '../../test_validator.dart';

class MockSecretStream extends Mock
    with SecretStreamValidations
    implements SecretStream {}

void main() {
  group('SecretBoxValidations', () {
    late MockSecretStream sutMock;

    setUp(() {
      sutMock = MockSecretStream();
    });

    testCheckIsSame(
      'validateKey',
      source: () => sutMock.keyBytes,
      sut: (value) => sutMock.validateKey(SecureKeyFake.empty(value)),
    );
  });
}
