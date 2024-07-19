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
  Future<Sodium> loadSodium() => SodiumInit.init(
        () => DynamicLibrary.open('libsodium.dll'),
      );

  @override
  Future<SodiumSumo> loadSodiumSumo() => SodiumSumoInit.init(
        () => DynamicLibrary.open('libsodium.dll'),
      );
}
