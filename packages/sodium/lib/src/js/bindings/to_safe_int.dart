@JS()
library to_safe_int;

import 'package:js/js.dart';

@JS('Number.MAX_SAFE_INTEGER')
external num _maxSafeInteger;

/// Extension on [num] to allow safe integer conversions.
extension ToSafeIntX on num {
  /// The maximum possible value of an usigned 32bit integer.
  static const uint32SafeMax = 0xFFFFFFFF;

  /// The maximum possible value of an unsigned integer in JavaScript.
  static int get maxSafeInteger => _maxSafeInteger.toInt();

  /// Converts the number to a valid uint32 value.
  ///
  /// If the value is below 0 or above [uint32SafeMax], an overflow is assumend
  /// and [uint32SafeMax] is returned. Otherwise, the value of [this] is
  /// returned as [int].
  int toSafeUInt32() {
    if (this < 0 || this > uint32SafeMax) {
      return uint32SafeMax;
    } else {
      return toInt();
    }
  }

  /// Converts the number to a valid uint64 value.
  ///
  /// If the value is below 0 or above [maxSafeInteger], an overflow is assumend
  /// and [maxSafeInteger] is returned. Otherwise, the value of [this] is
  /// returned as [int].
  int toSafeUInt64() {
    if (this < 0 || this > maxSafeInteger) {
      return maxSafeInteger;
    } else {
      return toInt();
    }
  }
}
