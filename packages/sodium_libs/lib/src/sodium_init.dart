import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:sodium/sodium.dart' as sodium;
import 'package:synchronized/synchronized.dart';

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

  static final _instanceLock = Lock();
  static sodium.Sodium? _instance;

  const SodiumInit._(); // coverage:ignore-line

  /// Ensures that the correct platform plugin is registered
  ///
  /// This method is automatically called by [init] and usually does not need
  /// to be called manually. However, If you are working with [SodiumPlatform],
  /// You should call this method to make sure the correct
  /// [SodiumPlatform.instance] is available.
  ///
  /// **Note:** This method only applies to Dart-VM targets. On the web, the
  /// registration happens automatically.
  static void ensurePlatformRegistered() {
    if (!SodiumPlatform.isRegistered) {
      Platforms.registerPlatformPlugin();
    }
  }

  /// Creates a new [Sodium] instance and initializes it
  ///
  /// Internally, this method ensures the correct [SodiumPlatform] is available
  /// and then uses [SodiumPlatform.loadSodium] to create an instance.
  ///
  /// In addition, when not running in release mode, it also performs a version
  /// check on the library to ensure you are using the correct native binary on
  /// platforms, where the binary is fetched dynamically.
  ///
  /// **Note:** Calling this method multiple times will always return the same
  /// instance.
  static Future<sodium.Sodium> init() => _instanceLock.synchronized(() async {
        if (_instance != null) {
          return _instance!;
        }
        WidgetsFlutterBinding.ensureInitialized();
        ensurePlatformRegistered();
        _instance = await SodiumPlatform.instance.loadSodium();
        if (!kReleaseMode) {
          if (_instance!.version < _expectedVersion) {
            // ignore: avoid_print
            print(
              'WARNING: The embedded libsodium is outdated! '
              'Expected $_expectedVersion, but was ${_instance!.version}}. '
              '${SodiumPlatform.instance.updateHint}',
            );
          }
        }
        return _instance!;
      });
}
