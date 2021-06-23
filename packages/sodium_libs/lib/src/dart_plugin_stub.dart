import 'dart:io';

import 'package:sodium_libs_windows/sodium_libs_windows.dart';

void registerDartPlugins() {
  if (Platform.isWindows) {
    SodiumWindows.registerWith();
  }
}
