import 'dart:ffi';

import 'package:sodium/sodium.dart';
import 'package:sodium/sodium_sumo.dart';
import '../sodium_platform.dart';

/// iOS platform implementation of SodiumPlatform
class SodiumIos extends SodiumPlatform {
  /// Registers the [SodiumIos] as [SodiumPlatform.instance]
  static void registerWith() {
    SodiumPlatform.instance = SodiumIos();
  }

  @override
  Future<Sodium> loadSodium() => SodiumInit.init2(DynamicLibrary.process);

  @override
  Future<SodiumSumo> loadSodiumSumo() =>
      SodiumSumoInit.init2(DynamicLibrary.process);
}
