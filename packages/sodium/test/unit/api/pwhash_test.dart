import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/pwhash.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../test_data.dart';

class MockPwhash extends Mock with PwHashValidations implements Pwhash {}

void main() {
  group('PwHashValidations', () {
    late MockPwhash sutMock;

    setUp(() {
      sutMock = MockPwhash();
    });

    testData<Tuple2<int, bool>>(
      'validateOutLen asserts if value is not in range',
      const [
        Tuple2(0, false),
        Tuple2(5, false),
        Tuple2(10, false),
        Tuple2(-1, true),
        Tuple2(11, true),
      ],
      (fixture) {
        when(() => sutMock.bytesMin).thenReturn(0);
        when(() => sutMock.bytesMax).thenReturn(10);

        final exceptionMatcher = throwsA(isA<RangeError>());
        expect(
          () => sutMock.validateOutLen(fixture.item1),
          fixture.item2 ? exceptionMatcher : isNot(exceptionMatcher),
        );
        verify(() => sutMock.bytesMin);
        verify(() => sutMock.bytesMax);
      },
    );

    testData<Tuple2<int, bool>>(
      'validatepasswordHash asserts if value is not in range',
      const [
        Tuple2(5, false),
        Tuple2(4, true),
        Tuple2(6, true),
      ],
      (fixture) {
        when(() => sutMock.strBytes).thenReturn(5);

        final exceptionMatcher = throwsA(isA<RangeError>());
        expect(
          () => sutMock.validatePasswordHash(Int8List(fixture.item1)),
          fixture.item2 ? exceptionMatcher : isNot(exceptionMatcher),
        );
        verify(() => sutMock.strBytes);
      },
    );

    testData<Tuple2<int, bool>>(
      'validatePassword asserts if value is not in range',
      const [
        Tuple2(1, false),
        Tuple2(5, false),
        Tuple2(10, false),
        Tuple2(0, true),
        Tuple2(11, true),
      ],
      (fixture) {
        when(() => sutMock.passwdMin).thenReturn(1);
        when(() => sutMock.passwdMax).thenReturn(10);

        final exceptionMatcher = throwsA(isA<RangeError>());
        expect(
          () => sutMock.validatePassword(Int8List(fixture.item1)),
          fixture.item2 ? exceptionMatcher : isNot(exceptionMatcher),
        );
        verify(() => sutMock.passwdMin);
        verify(() => sutMock.passwdMax);
      },
    );

    testData<Tuple2<int, bool>>(
      'validateSalt asserts if value is not in range',
      const [
        Tuple2(5, false),
        Tuple2(4, true),
        Tuple2(6, true),
      ],
      (fixture) {
        when(() => sutMock.saltBytes).thenReturn(5);

        final exceptionMatcher = throwsA(isA<RangeError>());
        expect(
          () => sutMock.validateSalt(Uint8List(fixture.item1)),
          fixture.item2 ? exceptionMatcher : isNot(exceptionMatcher),
        );
        verify(() => sutMock.saltBytes);
      },
    );

    testData<Tuple2<int, bool>>(
      'validateOpsLimit asserts if value is not in range',
      const [
        Tuple2(0, false),
        Tuple2(5, false),
        Tuple2(10, false),
        Tuple2(-1, true),
        Tuple2(11, true),
      ],
      (fixture) {
        when(() => sutMock.opsLimitMin).thenReturn(0);
        when(() => sutMock.opsLimitMax).thenReturn(10);

        final exceptionMatcher = throwsA(isA<RangeError>());
        expect(
          () => sutMock.validateOpsLimit(fixture.item1),
          fixture.item2 ? exceptionMatcher : isNot(exceptionMatcher),
        );
        verify(() => sutMock.opsLimitMin);
        verify(() => sutMock.opsLimitMax);
      },
    );

    testData<Tuple2<int, bool>>(
      'validateMemLimit asserts if value is not in range',
      const [
        Tuple2(0, false),
        Tuple2(5, false),
        Tuple2(10, false),
        Tuple2(-1, true),
        Tuple2(11, true),
      ],
      (fixture) {
        when(() => sutMock.memLimitMin).thenReturn(0);
        when(() => sutMock.memLimitMax).thenReturn(10);

        final exceptionMatcher = throwsA(isA<RangeError>());
        expect(
          () => sutMock.validateMemLimit(fixture.item1),
          fixture.item2 ? exceptionMatcher : isNot(exceptionMatcher),
        );
        verify(() => sutMock.memLimitMin);
        verify(() => sutMock.memLimitMax);
      },
    );
  });
}
