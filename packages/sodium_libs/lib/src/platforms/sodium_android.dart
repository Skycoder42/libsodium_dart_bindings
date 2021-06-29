import 'dart:ffi';

import 'package:meta/meta.dart';
import 'package:sodium/sodium.dart';
import '../sodium_platform.dart';

@internal
class SodiumAndroid extends SodiumPlatform {
  @override
  Future<Sodium> loadSodium() =>
      SodiumInit.init(DynamicLibrary.open('libsodium.so'));
}
