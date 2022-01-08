import 'dart:ffi';

import 'package:sodium/sodium.dart';
import '../sodium_platform.dart';

class SodiumLinux extends SodiumPlatform {
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
