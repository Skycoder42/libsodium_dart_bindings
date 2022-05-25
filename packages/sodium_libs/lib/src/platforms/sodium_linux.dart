import 'dart:ffi';

import 'package:sodium/sodium.dart';
import '../sodium_platform.dart';

/// Linux platform implementation of SodiumPlatform
class SodiumLinux extends SodiumPlatform {
  /// Registers the [SodiumLinux] as [SodiumPlatform.instance]
  static void registerWith() {
    SodiumPlatform.instance = SodiumLinux();
  }

  @override
  Future<Sodium> loadSodium({bool initNative = true}) => SodiumInit.init(
        DynamicLibrary.process(),
      );

  @override
  String get updateHint =>
      'Please update your distribution to get the latest available version.';
}
