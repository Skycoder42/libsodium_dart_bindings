import 'dart:ffi';

import 'package:libsodium_dart_bindings/src/api/sodium.dart';
import 'package:libsodium_dart_bindings/src/ffi/api/sodium_ffi.dart';
import '../api/sodium_exception.dart';
import 'bindings/sodium.ffi.dart' as sodium_ffi;

abstract class SodiumFFIInit {
  const SodiumFFIInit._();

  static Future<Sodium> init(DynamicLibrary dylib) =>
      initFromSodiumFFI(sodium_ffi.SodiumFFI(dylib));

  static Future<Sodium> initFromSodiumFFI(sodium_ffi.SodiumFFI sodium) {
    final result = sodium.sodium_init();
    SodiumException.checkSucceededInt(result);
    return Future.value(SodiumFFI(sodium));
  }
}
