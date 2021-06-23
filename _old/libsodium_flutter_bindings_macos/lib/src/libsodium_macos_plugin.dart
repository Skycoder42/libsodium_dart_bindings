import 'dart:ffi';

import 'package:sodium/sodium.dart';
import 'package:libsodium_flutter_bindings_platform_interface/libsodium_flutter_bindings_platform_interface.dart';

class LibsodiumMacosPlugin extends LibsodiumPlatform {
  static void registerWith() {
    LibsodiumPlatform.instance = LibsodiumMacosPlugin();
  }

  @override
  Future<Sodium> loadSodium() => SodiumFFIInit.init(DynamicLibrary.process());
}
