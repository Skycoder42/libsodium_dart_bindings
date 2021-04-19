@JS()
library to_safe_int;

import 'package:js/js.dart';

@JS('Number.MAX_SAFE_INTEGER')
external num _maxSafeInteger;

extension ToSafeIntX on num {
  static const uint32Max = 0xFFFFFFFF;

  static int get maxSafeInteger => _maxSafeInteger.toInt();

  int toSafeUInt32() {
    if (this < 0 || this > uint32Max) {
      return uint32Max;
    } else {
      return toInt();
    }
  }

  int toSafeUInt64() {
    if (this < 0 || this > maxSafeInteger) {
      return maxSafeInteger;
    } else {
      return toInt();
    }
  }
}
