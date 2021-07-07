import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:sodium/sodium.dart' as sodium;

import 'platforms/stub_platforms.dart'
    if (dart.library.ffi) 'platforms/io_platforms.dart'
    if (dart.library.js) 'platforms/js_platforms.dart';
import 'sodium_platform.dart';

/// Static class to obtain a [Sodium] instance.
///
/// This is a static wrapper around [SodiumPlatform], which simplifies loading
/// the [Sodium] instance and makes sure, the current platform plugin has been
/// correcly loaded. Use [init] to obtain a [Sodium] instance.
abstract class SodiumInit {
  static const _expectedVersion = sodium.SodiumVersion(10, 3, '1.0.18');

  const SodiumInit._(); // coverage:ignore-line

  static void registerPlugins() {
    if (!SodiumPlatform.isRegistered) {
      Platforms.registerPlatformPlugin();
    }
  }

  static Future<sodium.Sodium> init() async {
    WidgetsFlutterBinding.ensureInitialized();
    registerPlugins();
    final instance = await SodiumPlatform.instance.loadSodium();
    if (!kReleaseMode) {
      if (instance.version < _expectedVersion) {
        // ignore: avoid_print
        print(
          'WARNING: The embedded libsodium is outdated! '
          'Expected $_expectedVersion, but was ${instance.version}}. '
          '${SodiumPlatform.instance.updateHint}',
        );
      }
    }
    return instance;
  }
}
