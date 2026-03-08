import 'dart:async';

import 'api/sumo/sodium_sumo.dart';

/// Static class to obtain a [SodiumSumo] instance.
///
/// This initializer requires you to use the sumo variant of libsodium, which
/// is the variant with the full API, including internals and rarely used APIs.
///
/// See https://libsodium.gitbook.io/doc/advanced for some of the advanced APIs
sealed class SodiumSumoInit {
  /// Creates a new [SodiumSumo] instance for the bundled libsodium.
  static FutureOr<SodiumSumo> init() => throw UnsupportedError(
    'The current platform does support neither dart:ffi nor dart:js',
  );
}
