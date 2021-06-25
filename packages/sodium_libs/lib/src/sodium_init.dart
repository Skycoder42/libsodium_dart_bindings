import 'package:flutter/widgets.dart';
import 'package:sodium/sodium.dart' as sodium;

import 'platforms/stub_platforms.dart'
    if (dart.library.ffi) 'platforms/io_platforms.dart'
    if (dart.library.js) 'platforms/js_platforms.dart';
import 'sodium_platform.dart';

abstract class SodiumInit {
  const SodiumInit._(); // coverage:ignore-line

  static void registerPlugins() {
    if (!SodiumPlatform.isRegistered) {
      Platforms.registerPlatformPlugin();
    }
  }

  static Future<sodium.Sodium> init() {
    WidgetsFlutterBinding.ensureInitialized();
    registerPlugins();
    return SodiumPlatform.instance.loadSodium();
  }
}
