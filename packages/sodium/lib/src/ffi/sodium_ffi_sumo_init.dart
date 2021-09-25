import 'dart:ffi';

import '../api/advanced/advanced_sodium.dart';
import '../api/sodium.dart';
import '../api/sodium_exception.dart';
import 'api/advanced/advanced_sodium_ffi.dart';
import 'bindings/libsodium.ffi.dart';

/// Static class to obtain a [Sodium] instance.
///
/// **Important:** This API is is different depending on whether it is used from
/// the VM or in transpiled JavaScript Code. See the specific implementations
/// for more details.
abstract class SodiumInit {
  const SodiumInit._(); // coverage:ignore-line

  // coverage:ignore-start
  /// Creates an [AdvancedSodium] instance for the loaded libsodium with
  /// both standard and advanced features available.
  ///
  /// The [libsodium] parameter must be a loaded
  /// `[lib]sodium.[so|dll|dylib|a|lib|js]`- depending on your platform. Please
  /// refer to the README for more details on loading the library.
  static Future<AdvancedSodium> initSumo(DynamicLibrary libsodium) {
    final sodium = LibSodiumFFI(libsodium);
    final result = sodium.sodium_init();
    SodiumException.checkSucceededInitInt(result);
    return Future.value(AdvancedSodiumFFI(sodium));
  }
  // coverage:ignore-end
}
