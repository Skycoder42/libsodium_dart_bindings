import 'package:sodium/src/api/helpers/validations.dart';
import 'package:test/test.dart';

import '../../../test_data.dart';

void main() {
  testData<(int, int, int, bool)>(
    'checkInRange throws if not in range',
    const [
      (5, 0, 10, false),
      (-5, 0, 10, true),
      (15, 0, 10, true),
    ],
    (fixture) {
      final matcher = throwsA(isA<RangeError>());
      expect(
        () => Validations.checkInRange(
          fixture.$1,
          fixture.$2,
          fixture.$3,
          fixture.toString(),
        ),
        fixture.$4 ? matcher : isNot(matcher),
      );
    },
  );

  testData<(int, int, bool)>(
    'checkIsSame throws if not the same value',
    const [
      (5, 5, false),
      (-5, 5, true),
    ],
    (fixture) {
      final matcher = throwsA(isA<RangeError>());
      expect(
        () => Validations.checkIsSame(
          fixture.$1,
          fixture.$2,
          fixture.toString(),
        ),
        fixture.$3 ? matcher : isNot(matcher),
      );
    },
  );

  testData<(int, int, bool)>(
    'checkAtLeast throws if not at least the minimum value',
    const [
      (5, 5, false),
      (10, 5, false),
      (4, 5, true),
    ],
    (fixture) {
      final matcher = throwsA(isA<RangeError>());
      expect(
        () => Validations.checkAtLeast(
          fixture.$1,
          fixture.$2,
          fixture.toString(),
        ),
        fixture.$3 ? matcher : isNot(matcher),
      );
    },
  );
}
