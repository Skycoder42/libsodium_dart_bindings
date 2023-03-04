import 'dart:ffi';

import '../api/sodium_exception.dart';
import '../api/sumo/sodium_sumo.dart';
import 'api/helpers/isolates/libsodiumffi_factory.dart';
import 'api/sumo/sodium_sumo_ffi.dart';
import 'bindings/libsodium.ffi.dart';

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
  static Future<SodiumSumo> init(DynamicLibrary libsodium) =>
      initFromSodiumFFI(LibSodiumFFI(libsodium));
  // coverage:ignore-end

  /// Creates a [SodiumSumo] instance for the loaded libsodium as
  /// [LibSodiumFFI].
  ///
  /// Helper function that you can use if you can't provide a [DynamicLibrary]
  /// for loading libsodium. Instead, you can pass the [LibSodiumFFI] native
  /// interface, which is the raw dart interface to access the C library.
  ///
  /// Please note that [LibSodiumFFI] is not documented, as it is an auto
  /// generated binding, which simply mimics the C interface in dart, as
  /// required by [dart:ffi].
  static Future<SodiumSumo> initFromSodiumFFI(LibSodiumFFI sodium) {
    final result = sodium.sodium_init();
    SodiumException.checkSucceededInitInt(result);
    return Future.value(SodiumSumoFFI(sodium));
  }

  /// Creates a [SodiumSumo] instance for the loaded libsodium.
  ///
  /// The [libsodium] parameter must be a loaded sumo variant of
  /// `[lib]sodium.[so|dll|dylib|a|lib|js]`- depending on your platform. Please
  /// refer to the README for more details on loading the library.
  ///
  /// Unlike the [init] method, this one accepts a callback used to create the
  /// [DynamicLibrary]. This enables the [Sodium.runIsolated] method.
  static Future<SodiumSumo> initWithIsolates(
    DynamicLibraryFactory getLibsodium,
  ) =>
      initFromSodiumFFIWithIsolates(
        () async => LibSodiumFFI(await getLibsodium()),
      );

  /// Creates a [SodiumSumo] instance for the loaded libsodium as
  /// [LibSodiumFFI].
  ///
  /// Helper function that you can use if you can't provide a [DynamicLibrary]
  /// for loading libsodium. Instead, you can pass the [LibSodiumFFI] native
  /// interface, which is the raw dart interface to access the C library.
  ///
  /// Please note that [LibSodiumFFI] is not documented, as it is an auto
  /// generated binding, which simply mimics the C interface in dart, as
  /// required by [dart:ffi].
  ///
  /// Unlike the [init] method, this one accepts a callback used to create the
  /// [LibSodiumFFI]. This enables the [Sodium.runIsolated] method.
  static Future<SodiumSumo> initFromSodiumFFIWithIsolates(
    LibSodiumFFIFactory getSodium,
  ) async =>
      Future.value(
        SodiumSumoFFI.fromFactory(() async {
          final sodium = await getSodium();
          final result = sodium.sodium_init();
          SodiumException.checkSucceededInitInt(result);
          return sodium;
        }),
      );
}
