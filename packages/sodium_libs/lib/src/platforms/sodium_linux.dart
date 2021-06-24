import 'dart:ffi';

import 'package:sodium/sodium.dart';
import '../sodium_platform.dart';

class SodiumLinux extends SodiumPlatform {
  @override
  Future<Sodium> loadSodium() => SodiumInit.init(DynamicLibrary.process());
}
