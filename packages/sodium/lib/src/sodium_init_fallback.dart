import 'api/sodium.dart';

/// Static class to obtain a [Sodium] instance.
///
/// **Important:** This API is is different depending on whether it is used from
/// the VM or in transpiled JavaScript Code. See the specific implementations
/// for more details.
abstract class SodiumInit {
  const SodiumInit._(); // coverage:ignore-line

  /// Creates a [Sodium] instance for the loaded libsodium.
  ///
  /// The [libsodium] parameter must be a loaded
  /// `[lib]sodium.[so|dll|dylib|a|lib|js]`- depending on your platform. Please
  /// refer to the README for more details on loading the library.
  static Future<Sodium> init(
    dynamic libsodium, {
    @Deprecated('initNative is no longer required and will be ignored. '
        'Initializing native sodium multiple times is ok.')
        bool initNative = true,
  }) =>
      throw UnsupportedError(
        'The current platform does support neither dart:ffi nor dart:js',
      );
}
