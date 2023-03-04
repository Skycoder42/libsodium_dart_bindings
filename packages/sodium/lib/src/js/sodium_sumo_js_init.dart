// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';

import '../api/sumo/sodium_sumo.dart';
import 'api/sumo/sodium_sumo_js.dart';
import 'bindings/sodium.js.dart';

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

  // coverage:ignore-start
  /// Creates a [SodiumSumo] instance for the loaded libsodium.
  ///
  /// The [libsodium] parameter must be a loaded sumo variant of
  /// `[lib]sodium.[so|dll|dylib|a|lib|js]`- depending on your platform. Please
  /// refer to the README for more details on loading the library.
  @Deprecated('Use SodiumSumoInit.init2 instead')
  static Future<SodiumSumo> init(dynamic libsodium) =>
      initFromSodiumJS(libsodium as LibSodiumJS);

  /// Creates a [SodiumSumo] instance for the loaded libsodium as [LibSodiumJS].
  ///
  /// The [libsodium] parameter must be a loaded sumo variant of
  /// `sodium.js`. Please refer to the README for more details on loading the
  /// library.
  @Deprecated('Use SodiumSumoInit.initFromSodiumJS2 instead')
  static Future<SodiumSumo> initFromSodiumJS(LibSodiumJS libsodium) =>
      Future.value(SodiumSumoJS(libsodium));
  // coverage:ignore-end

  /// Creates a [SodiumSumo] instance for the loaded libsodium returned by the
  /// callback.
  ///
  /// The [getLibsodium] parameter must be a factory method that returns a
  /// loaded sumo variant of `[lib]sodium.[so|dll|dylib|a|lib|js]`- depending on
  /// your platform. Please refer to the README for more details on loading the
  /// library.
  ///
  /// Unlike the [init] method, this one enables the use of
  /// [SodiumSumo.runIsolated]. Use it preferably.
  static Future<SodiumSumo> init2(
    FutureOr<dynamic> Function() getLibsodium,
  ) async =>
      initFromSodiumJS2(
        () async => (await getLibsodium()) as LibSodiumJS,
      );

  /// Creates a [SodiumSumo] instance for the loaded libsodium returned by the
  /// callback as [LibSodiumJS].
  ///
  /// The [getLibsodium] parameter must be a factory method that returns a
  /// loaded sumo variant of `sodium.js`. Please refer to the README for more
  /// details on loading the library.
  ///
  /// Unlike the [initFromSodiumJS] method, this one enables the use of
  /// [SodiumSumo.runIsolated]. Use it preferably.
  static Future<SodiumSumo> initFromSodiumJS2(
    FutureOr<LibSodiumJS> Function() getLibsodium,
  ) async =>
      SodiumSumoJS(await getLibsodium());
}
