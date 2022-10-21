import 'dart:ffi';

import 'package:sodium/sodium_sumo.dart';
import '../sodium_platform.dart';

/// Android platform implementation of SodiumPlatform
class SodiumAndroid extends SodiumPlatform {
  /// Registers the [SodiumAndroid] as [SodiumPlatform.instance]
  static void registerWith() {
    SodiumPlatform.instance = SodiumAndroid();
  }

  @override
  Future<Sodium> loadSodium() => SodiumSumoInit.init(
        DynamicLibrary.open('libsodium.so'),
      );
}
