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
  ///
  /// By default, the native library automatically get initialized. If you do
  /// not want to initialize it, set [initNative] to false. This can be useful
  /// if you need multiple instances of [Sodium].
  static Future<Sodium> init(dynamic libsodium, {bool initNative = true}) =>
      throw UnsupportedError(
        'The current platform does support neither dart:ffi nor dart:js',
      );
}
