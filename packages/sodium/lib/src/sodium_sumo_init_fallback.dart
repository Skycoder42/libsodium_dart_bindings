import 'api/sumo/sodium_sumo.dart';

/// Static class to obtain a [SodiumSumo] instance.
///
/// **Important:** This API is is different depending on whether it is used from
/// the VM or in transpiled JavaScript Code. See the specific implementations
/// for more details.
///
/// This initializer requires you to use the sumo variant of libsodium, which
/// is the variant with the full API, including internals and rarely used APIs.
///
/// See https://libsodium.gitbook.io/doc/advanced for some of the advanced APIs
abstract class SodiumSumoInit {
  const SodiumSumoInit._(); // coverage:ignore-line

  /// Creates a [SodiumSumo] instance for the loaded libsodium.
  ///
  /// The [libsodium] parameter must be a loaded sumo variant of
  /// `[lib]sodium.[so|dll|dylib|a|lib|js]`- depending on your platform. Please
  /// refer to the README for more details on loading the library.
  static Future<SodiumSumo> init(dynamic libsodium) => throw UnsupportedError(
        'The current platform does support neither dart:ffi nor dart:js',
      );
}
