extension NumX on num {
  static const maxSafeInteger = 9007199254740991;

  int toSafeInt() {
    final val = toInt();
    if (val < 0 || val > maxSafeInteger) {
      return maxSafeInteger;
    } else {
      return val;
    }
  }
}
