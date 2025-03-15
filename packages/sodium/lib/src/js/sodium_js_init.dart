// ignore_for_file: deprecated_member_use_from_same_package

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

  /// Creates a [Sodium] instance for the loaded libsodium returned by the
  /// callback.
  ///
  /// The [getLibsodium] parameter must be a factory method that returns a
  /// loaded `[lib]sodium.[so|dll|dylib|a|lib|js]`- depending on your platform.
  /// Please refer to the README for more details on loading the library.
  static Future<Sodium> init(
    FutureOr<dynamic> Function() getLibsodium,
  ) =>
      initFromSodiumJS(
        () async => (await getLibsodium()) as LibSodiumJS,
      );

  /// Creates a [Sodium] instance for the loaded libsodium returned by the
  /// callback as [LibSodiumJS].
  ///
  /// The [getLibsodium] parameter must be a factory method that returns a
  /// loaded `sodium.js`. Please refer to the README for more details on loading
  /// the library.
  static Future<Sodium> initFromSodiumJS(
    FutureOr<LibSodiumJS> Function() getLibsodium,
  ) async =>
      SodiumJS(await getLibsodium());
}
