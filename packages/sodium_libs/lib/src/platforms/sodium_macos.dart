import 'dart:ffi';

import 'package:sodium/sodium.dart';
import 'package:sodium/sodium_sumo.dart';
import '../sodium_platform.dart';

/// macOS platform implementation of SodiumPlatform
class SodiumMacos extends SodiumPlatform {
  /// Registers the [SodiumMacos] as [SodiumPlatform.instance]
  static void registerWith() {
    SodiumPlatform.instance = SodiumMacos();
  }

  @override
  Future<Sodium> loadSodium() async => await SodiumInit.init();

  @override
  Future<SodiumSumo> loadSodiumSumo() async => await SodiumSumoInit.init();
}
