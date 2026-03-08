import 'dart:async';

import 'package:meta/meta.dart';

import '../api/sodium.dart';
import 'api/sodium_js.dart';
import 'bindings/lib_sodium_js_loader.dart';
import 'bindings/sodium.js.dart';

/// Static class to obtain a [Sodium] instance.
sealed class SodiumInit {
  // coverage:ignore-start
  /// Creates a new [Sodium] instance for the bundled libsodium.
  ///
  /// This method will wait for sodium.js to load and then return the
  /// initialized instance.
  static Future<Sodium> init() async =>
      initFromJS(await LibSodiumJSLoader.loadLibSodiumJS());

  // coverage:ignore-end

  /// @nodoc
  @visibleForTesting
  static Sodium initFromJS(LibSodiumJS libSodiumJS) => SodiumJS(libSodiumJS);
}
