extension ToSafeIntX on num {
  static const maxSafeInteger = 9007199254740991;

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
