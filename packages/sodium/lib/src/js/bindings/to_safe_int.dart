@JS()
library to_safe_int;

import 'package:js/js.dart';

@JS('Number.MAX_SAFE_INTEGER')
external num _maxSafeInteger;

extension ToSafeIntX on num {
  static int get maxSafeInteger => _maxSafeInteger.toInt();

  int toSafeUInt() {
    if (this < 0) {
      return maxSafeInteger;
    } else {
      return toSafeInt();
    }
  }

  int toSafeInt() {
    if (this > maxSafeInteger) {
      return maxSafeInteger;
    } else {
      return toInt();
    }
  }
}
