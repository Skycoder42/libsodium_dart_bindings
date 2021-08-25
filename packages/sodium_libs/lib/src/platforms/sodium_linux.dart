import 'dart:ffi';

import 'package:meta/meta.dart';
import 'package:sodium/sodium.dart';
import '../sodium_platform.dart';

@internal
class SodiumLinux extends SodiumPlatform {
  @override
  Future<Sodium> loadSodium({bool initNative = true}) => SodiumInit.init(
        DynamicLibrary.process(),
      );

  @override
  String get updateHint =>
      'Please update your distribution to get the latest available version.';
}
