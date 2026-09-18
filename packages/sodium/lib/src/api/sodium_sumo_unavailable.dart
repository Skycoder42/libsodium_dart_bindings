/// @docImport '../../sodium_sumo.dart';
library;

import 'sodium_exception.dart';

/// Exception that is thrown when the sumo variant of libsodium is not available
///
/// This can happen when trying to load [SodiumSumo] on the web, but only the
/// normal variant of sodium.js is available.
class SodiumSumoUnavailable([super.originalMessage]) extends SodiumException {
  /// Default constructor.
  this;

  @override
  String toString() =>
      'SodiumSumoUnavailable: The current platform implementation '
      'does not support the advanced sodium sumo APIs';
}
