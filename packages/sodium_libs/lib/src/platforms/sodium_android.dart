import 'dart:ffi';

import 'package:sodium/sodium.dart';
import '../sodium_platform.dart';

class SodiumAndroid extends SodiumPlatform {
  static void registerWith() {
    SodiumPlatform.instance = SodiumAndroid();
  }

  @override
  Future<Sodium> loadSodium({bool initNative = true}) => SodiumInit.init(
        DynamicLibrary.open('libsodium.so'),
      );
}
