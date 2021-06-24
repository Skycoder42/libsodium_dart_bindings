import 'package:flutter/widgets.dart';
import 'package:platform_info/platform_info.dart';
import 'package:sodium/sodium.dart' as sodium;

import 'platforms/sodium_linux.dart';
import 'platforms/sodium_windows.dart';
import 'sodium_platform.dart';

abstract class SodiumInit {
  const SodiumInit._(); // coverage:ignore-line

  static void registerPlugins() {
    if (SodiumPlatform.isRegistered) {
      return;
    }

    platform.when(
      io: () => platform.when(
        linux: () => SodiumPlatform.instance = SodiumLinux(),
        windows: () => SodiumPlatform.instance = SodiumWindows(),
      ),
    );
  }

  static Future<sodium.Sodium> init() {
    WidgetsFlutterBinding.ensureInitialized();
    registerPlugins();
    return SodiumPlatform.instance.loadSodium();
  }
}
