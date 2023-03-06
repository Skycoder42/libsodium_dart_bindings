import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sumo/pwhash.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../test_data.dart';
import '../../../test_validator.dart';

class MockPwhash extends Mock with PwHashValidations implements Pwhash {}

void main() {
  group('PwHashValidations', () {
    late MockPwhash sutMock;

    setUp(() {
      sutMock = MockPwhash();
    });

    testCheckInRange(
      'validateOutLen',
      minSource: () => sutMock.bytesMin,
      maxSource: () => sutMock.bytesMax,
      sut: (value) => sutMock.validateOutLen(value),
    );

    testCheckIsSame(
      'validatePasswordHash',
      source: () => sutMock.strBytes,
      sut: (value) => sutMock.validatePasswordHash(Int8List(value)),
    );

    testData<Tuple2<int, bool>>(
      'validatePasswordHashStr asserts if value is not in range',
      const [
        Tuple2(3, false),
        Tuple2(5, false),
        Tuple2(1, false),
        Tuple2(0, true),
        Tuple2(6, true),
      ],
      (fixture) {
        when(() => sutMock.strBytes).thenReturn(5);

        final exceptionMatcher = throwsA(isA<RangeError>());
        expect(
          () => sutMock.validatePasswordHashStr(
            'x' * fixture.item1,
          ),
          fixture.item2 ? exceptionMatcher : isNot(exceptionMatcher),
        );
        verify(() => sutMock.strBytes);
      },
    );

    testCheckInRange(
      'validatePassword',
      minSource: () => sutMock.passwdMin,
      maxSource: () => sutMock.passwdMax,
      sut: (value) => sutMock.validatePassword(Int8List(value)),
    );

    testCheckIsSame(
      'validateSalt',
      source: () => sutMock.saltBytes,
      sut: (value) => sutMock.validateSalt(Uint8List(value)),
    );

    testCheckInRange(
      'validateOpsLimit',
      minSource: () => sutMock.opsLimitMin,
      maxSource: () => sutMock.opsLimitMax,
      sut: (value) => sutMock.validateOpsLimit(value),
    );

    testCheckInRange(
      'validateMemLimit',
      minSource: () => sutMock.memLimitMin,
      maxSource: () => sutMock.memLimitMax,
      sut: (value) => sutMock.validateMemLimit(value),
    );
  });
}
