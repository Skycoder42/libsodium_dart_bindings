import 'dart:io';

import '../sodium_platform.dart';
import 'sodium_linux.dart';
import 'sodium_windows.dart';

abstract class Platforms {
  const Platforms._();

  static void registerPlatformPlugin() {
    if (Platform.isLinux) {
      SodiumPlatform.instance = SodiumLinux();
    } else if (Platform.isWindows) {
      SodiumPlatform.instance = SodiumWindows();
    }
  }
}
