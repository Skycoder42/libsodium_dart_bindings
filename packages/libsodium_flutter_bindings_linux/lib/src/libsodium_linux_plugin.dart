import 'dart:ffi';

import 'package:sodium/sodium.dart';
import 'package:libsodium_flutter_bindings_platform_interface/libsodium_flutter_bindings_platform_interface.dart';

class LibsodiumLinuxPlugin extends LibsodiumPlatform {
  static void registerWith() {
    LibsodiumPlatform.instance = LibsodiumLinuxPlugin();
  }

  @override
  Future<Sodium> loadSodium() => SodiumFFIInit.init(DynamicLibrary.process());
}
