import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:sodium/sodium.dart' as sodium;
import 'package:sodium/sodium_sumo.dart' as sodium_sumo;
import 'package:synchronized/synchronized.dart';

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

  /// Creates a new [sodium_sumo.SodiumSumo] instance and initializes it
  ///
  /// Internally, this method ensures the correct [SodiumPlatform] is available
  /// and then uses [SodiumPlatform.loadSodium] to create an instance.
  ///
  /// [SodiumPlatform.loadSodium] will automatically load a sumo variant if the
  /// given binary does support the sumo APIs. If that is not the case, this
  /// method will throw a [sodium.SodiumException].
  ///
  /// In addition, when not running in release mode, it also performs a version
  /// check on the library to ensure you are using the correct native binary on
  /// platforms, where the binary is fetched dynamically.
  ///
  /// **Note:** Calling this method multiple times will always return the same
  /// instance.
  static Future<sodium_sumo.SodiumSumo> initSumo() async {
    final sodiumInstance = await init();

    if (sodiumInstance is! sodium_sumo.SodiumSumo) {
      throw sodium.SodiumException(
        'The libsodium binary currently in use does not support the '
        'sodium sumo APIs! Please replace it with a variant that does support '
        'the sumo APIs.',
      );
    }

    return sodiumInstance;
  }
}
