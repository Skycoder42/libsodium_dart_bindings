import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sumo/pwhash.dart';
import 'package:test/test.dart';

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

    testData<(int, bool)>(
      'validatePasswordHashStr asserts if value is not in range',
      const [
        (3, false),
        (5, false),
        (1, false),
        (0, true),
        (6, true),
      ],
      (fixture) {
        when(() => sutMock.strBytes).thenReturn(5);

        final exceptionMatcher = throwsA(isA<RangeError>());
        expect(
          () => sutMock.validatePasswordHashStr(
            'x' * fixture.$1,
          ),
          fixture.$2 ? exceptionMatcher : isNot(exceptionMatcher),
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
