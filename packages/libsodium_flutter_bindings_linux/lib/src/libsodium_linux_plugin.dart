import 'dart:ffi';

import 'package:libsodium_dart_bindings/libsodium_dart_bindings.ffi.dart';
import 'package:libsodium_flutter_bindings_platform_interface/libsodium_flutter_bindings_platform_interface.dart';

class LibsodiumLinuxPlugin extends LibsodiumPlatform {
  static void registerWith() {
    LibsodiumPlatform.instance = LibsodiumLinuxPlugin();
  }

  @override
  Future<SodiumFFI> loadLibrary() {
    final libsodium = DynamicLibrary.process();
    return Future.value(SodiumFFI(libsodium));
  }
}
