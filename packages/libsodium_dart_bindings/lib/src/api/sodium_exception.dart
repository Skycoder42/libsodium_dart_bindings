class SodiumException implements Exception {
  static void checkSucceededInt(
    int result, {
    bool lax = false,
  }) {
    if (lax) {
      if (result < 0) {
        throw SodiumException();
      }
    } else {
      if (result != 0) {
        throw SodiumException();
      }
    }
  }

  // ignore: avoid_positional_boolean_parameters
  static void checkSucceededBool(bool result) {
    if (!result) {
      throw SodiumException();
    }
  }

  static T checkSucceededObject<T extends Object>(T? result) {
    if (result == null) {
      throw SodiumException();
    }
    return result;
  }

  @override
  String toString() => 'A libsodium crypto operation has failed';
}
