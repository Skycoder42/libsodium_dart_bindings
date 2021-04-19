import 'package:sodium/src/api/validations.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../test_data.dart';

void main() {
  testData<Tuple4<int, int, int, bool>>(
    'checkInRange throws if not in range',
    const [
      Tuple4(5, 0, 10, false),
      Tuple4(-5, 0, 10, true),
      Tuple4(15, 0, 10, true),
    ],
    (fixture) {
      final matcher = throwsA(isA<RangeError>());
      expect(
        () => Validations.checkInRange(
          fixture.item1,
          fixture.item2,
          fixture.item3,
          fixture.toString(),
        ),
        fixture.item4 ? matcher : isNot(matcher),
      );
    },
  );

  testData<Tuple3<int, int, bool>>(
    'checkIsSame throws if not the same value',
    const [
      Tuple3(5, 5, false),
      Tuple3(-5, 5, true),
    ],
    (fixture) {
      final matcher = throwsA(isA<RangeError>());
      expect(
        () => Validations.checkIsSame(
          fixture.item1,
          fixture.item2,
          fixture.toString(),
        ),
        fixture.item3 ? matcher : isNot(matcher),
      );
    },
  );

  testData<Tuple3<int, int, bool>>(
    'checkAtLeast throws if not at least the minimum value',
    const [
      Tuple3(5, 5, false),
      Tuple3(10, 5, false),
      Tuple3(4, 5, true),
    ],
    (fixture) {
      final matcher = throwsA(isA<RangeError>());
      expect(
        () => Validations.checkAtLeast(
          fixture.item1,
          fixture.item2,
          fixture.toString(),
        ),
        fixture.item3 ? matcher : isNot(matcher),
      );
    },
  );
}
