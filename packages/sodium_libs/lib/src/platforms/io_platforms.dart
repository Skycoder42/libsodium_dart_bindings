import 'dart:io';

import '../sodium_platform.dart';
import 'sodium_android.dart';
import 'sodium_linux.dart';
import 'sodium_windows.dart';

abstract class Platforms {
  const Platforms._();

  static void registerPlatformPlugin() {
    if (Platform.isAndroid) {
      SodiumPlatform.instance = SodiumAndroid();
    } else if (Platform.isLinux) {
      SodiumPlatform.instance = SodiumLinux();
    } else if (Platform.isWindows) {
      SodiumPlatform.instance = SodiumWindows();
    }
  }
}
