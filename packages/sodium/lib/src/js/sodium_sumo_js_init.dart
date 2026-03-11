import 'dart:async';
import 'dart:js_interop_unsafe';

import 'package:meta/meta.dart';

import '../api/sodium_sumo_unavailable.dart';
import '../api/sumo/sodium_sumo.dart';
import 'api/sumo/sodium_sumo_js.dart';
import 'bindings/lib_sodium_js_loader.dart';
import 'bindings/sodium.js.dart';

/// Static class to obtain a [SodiumSumo] instance.
///
/// This initializer requires you to use the sumo variant of libsodium, which
/// is the variant with the full API, including internals and rarely used APIs.
///
/// See https://libsodium.gitbook.io/doc/advanced for some of the advanced APIs
sealed class SodiumSumoInit {
  /// Creates a new [SodiumSumo] instance for the bundled libsodium.
  ///
  /// This method will wait for sodium.js to load and then return the
  /// initialized instance. It will then check if the sodium.js that was loaded
  /// is actually a sumo variant and either return it or throw a
  /// [SodiumSumoUnavailable] exception.
  static Future<SodiumSumo> init() async =>
      initFromJS(await LibSodiumJSLoader.loadLibSodiumJS());

  /// @nodoc
  @visibleForTesting
  static SodiumSumo initFromJS(LibSodiumJS libSodiumJS) {
    if (libSodiumJS.has('crypto_sign_ed25519_sk_to_seed')) {
      return SodiumSumoJS(libSodiumJS);
    } else {
      throw SodiumSumoUnavailable(
        'JS-API for sumo-method crypto_sign_ed25519_sk_to_seed '
        'is missing.',
      );
    }
  }
}
