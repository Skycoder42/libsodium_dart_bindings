import 'dart:ffi';

import 'package:sodium/sodium.dart';
import 'package:sodium_libs_platform_interface/sodium_libs_platform_interface.dart';

class SodiumWindows extends SodiumPlatform {
  static var _registered = false;

  static void registerWith() {
    assert(!_registered, 'Cannot call SodiumWindows.registerWith twice');
    SodiumPlatform.instance = SodiumWindows();
    _registered = true;
  }

  @override
  Future<Sodium> loadSodium() async {
    return SodiumInit.init(DynamicLibrary.open("libsodium.dll"));
  }
}
