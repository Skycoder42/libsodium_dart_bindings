import 'package:meta/meta.dart';

@internal
abstract class Validations {
  const Validations._(); // coverage:ignore-line

  static void checkInRange(
    int value,
    int minValue,
    int maxValue,
    String name,
  ) =>
      RangeError.checkValueInInterval(value, minValue, maxValue, name);

  static void checkIsSame(int value, int expected, String name) {
    if (value != expected) {
      throw RangeError.value(
        value,
        name,
        'Only allowed value is $expected, but was',
      );
    }
  }

  static void checkAtLeast(int value, int minValue, String name) {
    if (value < minValue) {
      throw RangeError.value(
        value,
        name,
        'Must be at least $minValue, but was',
      );
    }
  }

  static void checkAtMost(int value, int maxValue, String name) {
    if (value > maxValue) {
      throw RangeError.value(
        value,
        name,
        'Must be at most $maxValue, but was',
      );
    }
    checkAtLeast(value, 0, name);
  }
}
