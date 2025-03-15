import 'package:meta/meta.dart';

/// Exception that is thrown if a lowlevel libsodium operation fails.
class SodiumException implements Exception {
  /// The original error message, if one existed.
  ///
  /// This is always null for the dart vm, but might contain more details when
  /// using JS. You should not rely on this to provide anything meaningful, it
  /// simply exists for completness.
  final String? originalMessage;

  /// Default constructor.
  SodiumException([this.originalMessage]);

  /// @nodoc
  @internal
  static void checkSucceededInt(int result) {
    if (result != 0) {
      throw SodiumException();
    }
  }

  /// @nodoc
  @internal
  static void checkSucceededInitInt(int result) {
    // Result will be 0 if first init and 1 if second and so on.
    if (result != 0 && result != 1) {
      throw SodiumException();
    }
  }

  /// @nodoc
  @internal
  // ignore: avoid_positional_boolean_parameters
  static void checkSucceededBool(bool result) {
    if (!result) {
      throw SodiumException();
    }
  }

  /// @nodoc
  @internal
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
