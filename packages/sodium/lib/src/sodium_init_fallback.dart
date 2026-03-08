import 'dart:async';

import 'api/sodium.dart';

/// Static class to obtain a [Sodium] instance.
sealed class SodiumInit {
  /// Creates a new [Sodium] instance for the bundled libsodium.
  static FutureOr<Sodium> init() => throw UnsupportedError(
    'The current platform does support neither dart:ffi nor dart:js_interop',
  );
}
