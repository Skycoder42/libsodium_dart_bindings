@JS()
library sodium_libs_plugin_web;

import 'dart:async';
import 'dart:html';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:sodium/sodium.dart' show Sodium;
import 'package:sodium/sodium.js.dart';

import '../sodium_platform.dart';

@JS()
@anonymous
class _SodiumBrowserInit {
  external void Function(LibSodiumJS sodium) get onload;

  external factory _SodiumBrowserInit({
    void Function(LibSodiumJS sodium) onload,
  });
}

/// Web platform implementation of SodiumPlatform
class SodiumWeb extends SodiumPlatform {
  /// Registers the [SodiumWeb] as [SodiumPlatform.instance]
  static void registerWith([Registrar? registrar]) {
    SodiumPlatform.instance = SodiumWeb();
  }

  @override
  Future<Sodium> loadSodium() async {
    // check if sodium was already loaded
    final sodium = getProperty<LibSodiumJS?>(window, 'sodium');
    if (sodium != null) {
      return _sodiumInit(sodium);
    }

    // if not, overwrite sodium window property with custom onload
    final completer = Completer<LibSodiumJS>();
    setProperty(
      window,
      'sodium',
      _SodiumBrowserInit(
        onload: allowInterop(completer.complete),
      ),
    );

    // ... and add the sodium script to the page
    final script = ScriptElement()
      ..type = 'text/javascript'
      ..async = true
      // ignore: unsafe_html
      ..src = 'sodium.js';
    document.body!.append(script);

    return _sodiumInit(await completer.future);
  }

  Future<Sodium> _sodiumInit(LibSodiumJS sodium) {
    // ignore: avoid_dynamic_calls
    if (hasProperty(sodium, 'crypto_sign_ed25519_sk_to_seed')) {
      return SodiumSumoInit.initFromSodiumJS(sodium);
    } else {
      return SodiumInit.initFromSodiumJS(sodium);
    }
  }

  @override
  String get updateHint =>
      'Please run `flutter pub run sodium_libs:update_web` again.';
}
