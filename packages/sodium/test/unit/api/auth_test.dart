import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/auth.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../secure_key_fake.dart';
import '../../test_data.dart';

class MockAuth extends Mock with AuthValidations implements Auth {}

void main() {
  group('AuthValidations', () {
    late MockAuth sutMock;

    setUp(() {
      sutMock = MockAuth();
    });

    testData<Tuple2<int, bool>>(
      'validateTag asserts if value is not in range',
      const [
        Tuple2(5, false),
        Tuple2(4, true),
        Tuple2(6, true),
      ],
      (fixture) {
        when(() => sutMock.bytes).thenReturn(5);

        final exceptionMatcher = throwsA(isA<RangeError>());
        expect(
          () => sutMock.validateTag(Uint8List(fixture.item1)),
          fixture.item2 ? exceptionMatcher : isNot(exceptionMatcher),
        );
        verify(() => sutMock.bytes);
      },
    );

    testData<Tuple2<int, bool>>(
      'validateKey asserts if value is not in range',
      const [
        Tuple2(5, false),
        Tuple2(4, true),
        Tuple2(6, true),
      ],
      (fixture) {
        when(() => sutMock.keyBytes).thenReturn(5);

        final exceptionMatcher = throwsA(isA<RangeError>());
        expect(
          () => sutMock.validateKey(SecureKeyFake(Uint8List(fixture.item1))),
          fixture.item2 ? exceptionMatcher : isNot(exceptionMatcher),
        );
        verify(() => sutMock.keyBytes);
      },
    );
  });
}
