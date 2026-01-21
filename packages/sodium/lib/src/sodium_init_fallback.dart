import 'dart:async';

import 'api/sodium.dart';

/// Static class to obtain a [Sodium] instance.
///
/// **Important:** This API is is different depending on whether it is used from
/// the VM or in transpiled JavaScript Code. See the specific implementations
/// for more details.
abstract class SodiumInit {
  const SodiumInit._(); // coverage:ignore-line

  /// Creates a new [Sodium] instance for the bundled libsodium.
  static FutureOr<Sodium> init([dynamic initializer]) => throw UnsupportedError(
    'The current platform does support neither dart:ffi nor dart:js',
  );
}
