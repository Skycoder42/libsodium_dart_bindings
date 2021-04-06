import 'dart:ffi';

import '../api/sodium.dart';
import '../api/sodium_exception.dart';
import 'api/sodium_ffi.dart';
import 'bindings/libsodium.ffi.dart';

abstract class SodiumFFIInit {
  const SodiumFFIInit._();

  static Future<Sodium> init(DynamicLibrary dylib) =>
      initFromSodiumFFI(LibSodiumFFI(dylib));

  static Future<Sodium> initFromSodiumFFI(LibSodiumFFI sodium) {
    final result = sodium.sodium_init();
    SodiumException.checkSucceededInt(result);
    return Future.value(SodiumFFI(sodium));
  }
}
