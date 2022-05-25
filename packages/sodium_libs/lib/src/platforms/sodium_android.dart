import 'dart:ffi';

import 'package:sodium/sodium.dart';
import '../sodium_platform.dart';

/// Android platform implementation of SodiumPlatform
class SodiumAndroid extends SodiumPlatform {
  /// Registers the [SodiumAndroid] as [SodiumPlatform.instance]
  static void registerWith() {
    SodiumPlatform.instance = SodiumAndroid();
  }

  @override
  Future<Sodium> loadSodium({bool initNative = true}) => SodiumInit.init(
        DynamicLibrary.open('libsodium.so'),
      );
}
