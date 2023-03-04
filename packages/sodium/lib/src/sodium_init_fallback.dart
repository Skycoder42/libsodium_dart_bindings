// ignore_for_file: deprecated_member_use_from_same_package

import 'api/sodium.dart';

/// Static class to obtain a [Sodium] instance.
///
/// **Important:** This API is is different depending on whether it is used from
/// the VM or in transpiled JavaScript Code. See the specific implementations
/// for more details.
abstract class SodiumInit {
  const SodiumInit._(); // coverage:ignore-line

  // coverage:ignore-start
  /// Creates a [Sodium] instance for the loaded libsodium.
  ///
  /// The [libsodium] parameter must be a loaded
  /// `[lib]sodium.[so|dll|dylib|a|lib|js]`- depending on your platform. Please
  /// refer to the README for more details on loading the library.
  @Deprecated('Use SodiumInit.init2 instead')
  static Future<Sodium> init(dynamic libsodium) => throw UnsupportedError(
        'The current platform does support neither dart:ffi nor dart:js',
      );
  // coverage:ignore-end

  /// Creates a [Sodium] instance for the loaded libsodium returned by the
  /// callback.
  ///
  /// The [getLibsodium] parameter must be a factory method that returns a
  /// loaded `[lib]sodium.[so|dll|dylib|a|lib|js]`- depending on your platform.
  /// Please refer to the README for more details on loading the library.
  ///
  /// Unlike the [init] method, this one enables the use of
  /// [Sodium.runIsolated]. Use it preferably.
  static Future<Sodium> init2(dynamic Function() getLibsodium) =>
      throw UnsupportedError(
        'The current platform does support neither dart:ffi nor dart:js',
      );
}
