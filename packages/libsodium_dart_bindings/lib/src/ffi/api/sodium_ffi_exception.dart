class SodiumFFIException implements Exception {
  static void checkSucceeded(num result) {
    if (result != 0) {
      throw SodiumFFIException();
    }
  }

  @override
  String toString() => 'A libsodium crypto operation has failed';
}
