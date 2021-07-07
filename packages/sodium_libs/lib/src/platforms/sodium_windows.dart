import 'dart:ffi';

import 'package:meta/meta.dart';
import 'package:sodium/sodium.dart';
import '../sodium_platform.dart';

@internal
class SodiumWindows extends SodiumPlatform {
  @override
  Future<Sodium> loadSodium() =>
      SodiumInit.init(DynamicLibrary.open('libsodium.dll'));

  @override
  String get updateHint => 'Please run `flutter clean` and rebuild the project '
      'to automatically update the embedded binaries';
}
