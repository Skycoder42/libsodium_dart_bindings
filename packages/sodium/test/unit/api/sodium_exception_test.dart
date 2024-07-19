import 'package:sodium/src/api/sodium_exception.dart';
import 'package:test/test.dart';

import '../../test_data.dart';

void main() {
  test('can hold original message', () {
    const message = 'msg';
    final sut = SodiumException(message);
    expect(sut.originalMessage, message);
  });

  testData<(int, bool)>(
    'checkSucceededInt asserts for non zero values',
    const [
      (0, false),
      (1, true),
      (-1, true),
      (666, true),
    ],
    (fixture) {
      final exceptionMatcher = throwsA(isA<SodiumException>());
      expect(
        () => SodiumException.checkSucceededInt(fixture.$1),
        fixture.$2 ? exceptionMatcher : isNot(exceptionMatcher),
      );
    },
  );

  testData<(int, bool)>(
    'checkSucceededInitInt asserts for non zero and non one values',
    const [
      (0, false),
      (1, false),
      (-1, true),
      (666, true),
    ],
    (fixture) {
      final exceptionMatcher = throwsA(isA<SodiumException>());
      expect(
        () => SodiumException.checkSucceededInitInt(fixture.$1),
        fixture.$2 ? exceptionMatcher : isNot(exceptionMatcher),
      );
    },
  );

  testData<(bool, bool)>(
    'checkSucceededBool asserts for false value',
    const [
      (true, false),
      (false, true),
    ],
    (fixture) {
      final exceptionMatcher = throwsA(isA<SodiumException>());
      expect(
        () => SodiumException.checkSucceededBool(fixture.$1),
        fixture.$2 ? exceptionMatcher : isNot(exceptionMatcher),
      );
    },
  );

  group('checkSucceededObject', () {
    test('asserts for null values', () {
      expect(
        () => SodiumException.checkSucceededObject<String>(null),
        throwsA(isA<SodiumException>()),
      );
    });

    test('returns value for non null values', () {
      const testData = 'test';
      final res = SodiumException.checkSucceededObject<String>(testData);
      expect(res, testData);
    });
  });
}
