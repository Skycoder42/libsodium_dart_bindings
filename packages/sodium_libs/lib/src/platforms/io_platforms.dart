import 'dart:io';

import '../sodium_platform.dart';
import 'sodium_android.dart';
import 'sodium_ios.dart';
import 'sodium_linux.dart';
import 'sodium_macos.dart';
import 'sodium_windows.dart';

abstract class Platforms {
  const Platforms._();

  static void registerPlatformPlugin() {
    if (Platform.isAndroid) {
      SodiumPlatform.instance = SodiumAndroid();
    } else if (Platform.isIOS) {
      SodiumPlatform.instance = SodiumIos();
    } else if (Platform.isLinux) {
      SodiumPlatform.instance = SodiumLinux();
    } else if (Platform.isWindows) {
      SodiumPlatform.instance = SodiumWindows();
    } else if (Platform.isMacOS) {
      SodiumPlatform.instance = SodiumMacos();
    }
  }
}
