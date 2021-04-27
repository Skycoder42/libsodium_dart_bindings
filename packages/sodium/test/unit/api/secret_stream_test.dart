import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/secret_stream.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../secure_key_fake.dart';
import '../../test_data.dart';

class MockSecretStream extends Mock
    with SecretStreamValidations
    implements SecretStream {}

void main() {
  group('SecretBoxValidations', () {
    late MockSecretStream sutMock;

    setUp(() {
      sutMock = MockSecretStream();
    });

    testData<Tuple2<int, bool>>(
      'validateNonce asserts if value is not in range',
      const [
        Tuple2(5, false),
        Tuple2(4, true),
        Tuple2(6, true),
      ],
      (fixture) {
        when(() => sutMock.keyBytes).thenReturn(5);

        final exceptionMatcher = throwsA(isA<RangeError>());
        expect(
          () => sutMock.validateKey(SecureKeyFake.empty(fixture.item1)),
          fixture.item2 ? exceptionMatcher : isNot(exceptionMatcher),
        );
        verify(() => sutMock.keyBytes);
      },
    );
  });
}
