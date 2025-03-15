import 'package:meta/meta.dart';

/// @nodoc
@internal
abstract class Validations {
  const Validations._(); // coverage:ignore-line

  /// @nodoc
  static void checkInRange(
    int value,
    int minValue,
    int maxValue,
    String name,
  ) => RangeError.checkValueInInterval(value, minValue, maxValue, name);

  /// @nodoc
  static void checkIsSame(int value, int expected, String name) {
    if (value != expected) {
      throw RangeError.value(
        value,
        name,
        'Only allowed value is $expected, but was',
      );
    }
  }

  /// @nodoc
  static void checkIsAny(int value, List<int> expected, String name) {
    if (!expected.contains(value)) {
      throw RangeError.value(
        value,
        name,
        'Only allowed values are $expected, but was',
      );
    }
  }

  /// @nodoc
  static void checkAtLeast(int value, int minValue, String name) {
    if (value < minValue) {
      throw RangeError.value(
        value,
        name,
        'Must be at least $minValue, but was',
      );
    }
  }

  /// @nodoc
  static void checkAtMost(int value, int maxValue, String name) {
    if (value > maxValue) {
      throw RangeError.value(value, name, 'Must be at most $maxValue, but was');
    }
    checkAtLeast(value, 0, name);
  }

  static void checkIsUint64(BigInt value, String name) {
    if (value.isNegative || value.bitLength > 64) {
      throw RangeError.range(
        value.toInt(),
        0,
        null,
        name,
        'Must be a valid 64bit unsigned integer, but was',
      );
    }
  }
}
