import 'dart:async';

import '../api/sodium.dart';
import 'api/sodium_js.dart';
import 'bindings/sodium.js.dart';

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
    @Deprecated('initNative is deprecated and will be ignored.')
        bool initNative = true,
  }) =>
      initFromSodiumJS(libsodium as LibSodiumJS);

  /// Creates a [Sodium] instance for the loaded libsodium as [LibSodiumJS].
  ///
  /// The [sodiumJsObject] parameter must be a loaded `sodium.js` -
  /// depending on your platform. Please refer to the README for more details
  /// on loading the library.
  static Future<Sodium> initFromSodiumJS(LibSodiumJS libsodium) =>
      Future.value(SodiumJS(libsodium));
}
