import 'dart:ffi';

import 'package:sodium/sodium.dart';
import 'package:sodium/sodium_sumo.dart';
import '../sodium_platform.dart';

/// Android platform implementation of SodiumPlatform
class SodiumAndroid extends SodiumPlatform {
  /// Registers the [SodiumAndroid] as [SodiumPlatform.instance]
  static void registerWith() {
    SodiumPlatform.instance = SodiumAndroid();
  }

  @override
  Future<Sodium> loadSodium() => SodiumInit.init2(
        () => DynamicLibrary.open('libsodium.so'),
      );

  @override
  Future<SodiumSumo> loadSodiumSumo() => SodiumSumoInit.init2(
        () => DynamicLibrary.open('libsodium.so'),
      );
}
