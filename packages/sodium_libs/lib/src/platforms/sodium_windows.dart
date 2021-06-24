import 'dart:ffi';

import 'package:sodium/sodium.dart';
import '../sodium_platform.dart';

class SodiumWindows extends SodiumPlatform {
  @override
  Future<Sodium> loadSodium() =>
      SodiumInit.init(DynamicLibrary.open('libsodium.dll'));
}
