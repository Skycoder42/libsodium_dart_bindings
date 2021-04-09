class SodiumException implements Exception {
  static void checkSucceededInt(
    int result,
  ) {
    if (result != 0) {
      throw SodiumException();
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

  // coverage:ignore-start
  @override
  String toString() => 'A low-level libsodium operation has failed';
  // coverage:ignore-end
}
