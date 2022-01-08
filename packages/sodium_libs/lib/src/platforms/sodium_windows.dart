import 'dart:ffi';

import 'package:sodium/sodium.dart';
import '../sodium_platform.dart';

class SodiumWindows extends SodiumPlatform {
  static void registerWith() {
    SodiumPlatform.instance = SodiumWindows();
  }

  @override
  Future<Sodium> loadSodium({bool initNative = true}) => SodiumInit.init(
        DynamicLibrary.open('libsodium.dll'),
      );

  @override
  String get updateHint => 'Please run `flutter clean` and rebuild the project '
      'to automatically update the embedded binaries';
}
