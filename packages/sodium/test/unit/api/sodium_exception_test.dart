import 'package:sodium/src/api/sodium_exception.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../test_data.dart';

void main() {
  test('can hold original message', () {
    const message = 'msg';
    final sut = SodiumException(message);
    expect(sut.originalMessage, message);
  });

  testData<Tuple2<int, bool>>(
    'checkSucceededInt asserts for non zero values',
    const [
      Tuple2(0, false),
      Tuple2(1, true),
      Tuple2(-1, true),
      Tuple2(666, true),
    ],
    (fixture) {
      final exceptionMatcher = throwsA(isA<SodiumException>());
      expect(
        () => SodiumException.checkSucceededInt(fixture.item1),
        fixture.item2 ? exceptionMatcher : isNot(exceptionMatcher),
      );
    },
  );

  testData<Tuple2<int, bool>>(
    'checkSucceededInitInt asserts for non zero and non one values',
    const [
      Tuple2(0, false),
      Tuple2(1, false),
      Tuple2(-1, true),
      Tuple2(666, true),
    ],
    (fixture) {
      final exceptionMatcher = throwsA(isA<SodiumException>());
      expect(
        () => SodiumException.checkSucceededInitInt(fixture.item1),
        fixture.item2 ? exceptionMatcher : isNot(exceptionMatcher),
      );
    },
  );

  testData<Tuple2<bool, bool>>(
    'checkSucceededBool asserts for false value',
    const [
      Tuple2(true, false),
      Tuple2(false, true),
    ],
    (fixture) {
      final exceptionMatcher = throwsA(isA<SodiumException>());
      expect(
        () => SodiumException.checkSucceededBool(fixture.item1),
        fixture.item2 ? exceptionMatcher : isNot(exceptionMatcher),
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
