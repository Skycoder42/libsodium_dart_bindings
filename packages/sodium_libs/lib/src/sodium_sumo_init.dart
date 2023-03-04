import 'package:flutter/foundation.dart';
import 'package:sodium/sodium_sumo.dart' show SodiumSumo;
import 'package:synchronized/synchronized.dart';

import 'sodium_platform.dart';
import 'sodium_sumo_unavailable.dart';
import 'version_check.dart';

/// Static class to obtain a [SodiumSumo] instance.
///
/// This is a static wrapper around [SodiumPlatform], which simplifies loading
/// the [SodiumSumo] instance and makes sure, the current platform plugin has
/// been correctly loaded. Use [init] to obtain a [SodiumSumo] instance.
abstract class SodiumSumoInit {
  static final _instanceLock = Lock();
  static SodiumSumo? _instance;

  const SodiumSumoInit._(); // coverage:ignore-line

  /// Creates a new [SodiumSumo] instance and initializes it
  ///
  /// Internally, this method ensures the correct [SodiumPlatform] is available
  /// and then uses [SodiumPlatform.loadSodiumSumo] to create an instance. If
  /// the [SodiumPlatform] implementation does not support the advanced sumo
  /// APIs, this method will throw a [SodiumSumoUnavailable] exception.
  ///
  /// In addition, when not running in release mode, it also performs a version
  /// check on the library to ensure you are using the correct native binary on
  /// platforms, where the binary is fetched dynamically.
  ///
  /// **Note:** Calling this method multiple times will always return the same
  /// instance.
  static Future<SodiumSumo> init() => _instanceLock.synchronized(() async {
        if (_instance != null) {
          return _instance!;
        }

        _instance = await SodiumPlatform.instance.loadSodiumSumo();

        if (!kReleaseMode) {
          VersionCheck.check(SodiumPlatform.instance, _instance!);
        }

        return _instance!;
      });
}
