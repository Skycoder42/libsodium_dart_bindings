import 'dart:ffi';

import 'package:sodium/sodium.dart';
import 'package:sodium/sodium_sumo.dart';
import '../sodium_platform.dart';

/// Windows platform implementation of SodiumPlatform
class SodiumWindows extends SodiumPlatform {
  /// Registers the [SodiumWindows] as [SodiumPlatform.instance]
  static void registerWith() {
    SodiumPlatform.instance = SodiumWindows();
  }

  @override
  Future<Sodium> loadSodium() async => await SodiumInit.init();

  @override
  Future<SodiumSumo> loadSodiumSumo() async => await SodiumSumoInit.init();
}
