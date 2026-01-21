import 'package:meta/meta.dart';

import '../api/sodium.dart';
import '../api/sodium_exception.dart';
import 'api/sodium_ffi.dart';
import 'bindings/libsodium.ffi.wrapper.dart';

/// Static class to obtain a [Sodium] instance.
///
/// **Important:** This API is is different depending on whether it is used from
/// the VM or in transpiled JavaScript Code. See the specific implementations
/// for more details.
abstract class SodiumInit {
  const SodiumInit._(); // coverage:ignore-line

  // coverage:ignore-start
  /// Creates a new [Sodium] instance for the bundled libsodium.
  static Sodium init() => initFromFFI(const LibSodiumFFI());
  // coverage:ignore-end

  /// @nodoc
  @visibleForTesting
  static Sodium initFromFFI(LibSodiumFFI libSodiumFFI) {
    final result = libSodiumFFI.sodium_init();
    SodiumException.checkSucceededInitInt(result);
    return SodiumFFI(libSodiumFFI);
  }
}
