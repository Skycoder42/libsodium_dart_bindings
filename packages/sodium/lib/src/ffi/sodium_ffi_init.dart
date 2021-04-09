import 'dart:ffi';

import '../api/sodium.dart';
import '../api/sodium_exception.dart';
import 'api/sodium_ffi.dart';
import 'bindings/libsodium.ffi.dart';

abstract class SodiumFFIInit {
  const SodiumFFIInit._(); // coverage:ignore-line

  // coverage:ignore-start
  static Future<Sodium> init(DynamicLibrary dylib) =>
      initFromSodiumFFI(LibSodiumFFI(dylib));
  // coverage:ignore-end

  static Future<Sodium> initFromSodiumFFI(LibSodiumFFI sodium) {
    final result = sodium.sodium_init();
    SodiumException.checkSucceededInt(result);
    return Future.value(SodiumFFI(sodium));
  }
}
