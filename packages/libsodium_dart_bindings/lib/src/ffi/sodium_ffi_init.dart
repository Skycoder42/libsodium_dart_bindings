import 'dart:ffi';

import 'package:libsodium_dart_bindings/src/api/crypto.dart';
import 'package:libsodium_dart_bindings/src/ffi/api/crypto_ffi.dart';
import '../api/sodium_exception.dart';
import 'bindings/sodium.ffi.dart';

abstract class SodiumFFIInit {
  const SodiumFFIInit._();

  static Future<Crypto> init(DynamicLibrary dylib) =>
      initFromSodiumFFI(SodiumFFI(dylib));

  static Future<Crypto> initFromSodiumFFI(SodiumFFI sodium) {
    final result = sodium.sodium_init();
    SodiumException.checkSucceededInt(result);
    return Future.value(CryptoFFI(sodium));
  }
}
