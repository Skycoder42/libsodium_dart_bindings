import 'package:meta/meta.dart';

@internal
abstract class Validations {
  const Validations._();

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
        'is not allows. The only allowed value is $expected',
      );
    }
  }

  static void checkAtLeast(int value, int minValue, String name) {
    if (value < minValue) {
      throw RangeError.value(
        value,
        name,
        'must be at least $minValue',
      );
    }
  }
}
