import 'package:meta/meta.dart';

import '../api/sodium_exception.dart';
import '../api/sumo/sodium_sumo.dart';
import 'api/sumo/sodium_sumo_ffi.dart';
import 'bindings/libsodium.ffi.wrapper.dart';

/// Static class to obtain a [SodiumSumo] instance.
///
/// This initializer requires you to use the sumo variant of libsodium, which
/// is the variant with the full API, including internals and rarely used APIs.
///
/// See https://libsodium.gitbook.io/doc/advanced for some of the advanced APIs
sealed class SodiumSumoInit {
  // coverage:ignore-start
  /// Creates a new [SodiumSumo] instance for the bundled libsodium.
  static SodiumSumo init() => initFromFFI(const LibSodiumFFI());
  // coverage:ignore-end

  /// @nodoc
  @visibleForTesting
  static SodiumSumo initFromFFI(LibSodiumFFI libSodiumFFI) {
    final result = libSodiumFFI.sodium_init();
    SodiumException.checkSucceededInitInt(result);
    return SodiumSumoFFI(libSodiumFFI);
  }
}
