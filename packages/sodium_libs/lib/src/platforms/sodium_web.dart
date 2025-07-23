import 'dart:async';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:sodium/sodium.dart' show Sodium;
import 'package:sodium/sodium.js.dart';
import 'package:sodium/sodium_sumo.dart' show SodiumSumo;
import 'package:web/web.dart';

import '../sodium_platform.dart';
import '../sodium_sumo_unavailable.dart';

extension type _SodiumBrowserInit._(JSObject _) implements JSObject {
  external JSFunction get onload;

  external _SodiumBrowserInit({JSFunction onload});
}

@JS('sodium')
external _SodiumBrowserInit? get _sodium;

@JS('sodium')
external set _sodium(_SodiumBrowserInit? value);

/// Web platform implementation of SodiumPlatform
class SodiumWeb extends SodiumPlatform {
  /// Registers the [SodiumWeb] as [SodiumPlatform.instance]
  static void registerWith([Registrar? registrar]) {
    SodiumPlatform.instance = SodiumWeb();
  }

  @override
  Future<Sodium> loadSodium() => SodiumInit.initFromSodiumJS(_loadLibSodiumJS);

  @override
  Future<SodiumSumo> loadSodiumSumo() =>
      SodiumSumoInit.initFromSodiumJS(() async {
        final libSodiumJs = await _loadLibSodiumJS();
        if (libSodiumJs.has('crypto_sign_ed25519_sk_to_seed')) {
          return libSodiumJs;
        } else {
          throw SodiumSumoUnavailable(
            details:
                'JS-API for sumo-method crypto_sign_ed25519_sk_to_seed '
                'is missing.',
          );
        }
      });

  Future<LibSodiumJS> _loadLibSodiumJS() {
    // check if sodium was already loaded
    if (_sodium.isA<JSObject>()) {
      final sodiumObj = _sodium! as JSObject;
      if (sodiumObj.has('ready')) {
        final sodium = sodiumObj as LibSodiumJS;
        return sodium.ready.toDart.then((_) => sodium);
      }
    }

    // if not, overwrite sodium window property with custom onload
    final completer = Completer<LibSodiumJS>();
    void onload(LibSodiumJS sodium) => completer.complete(sodium);
    _sodium = _SodiumBrowserInit(onload: onload.toJS);

    // ... and add the sodium script to the page
    final script = HTMLScriptElement()
      ..type = 'text/javascript'
      ..async = true
      ..src = 'sodium.js';
    document.body!.append(script);

    return completer.future;
  }

  @override
  String get updateHint =>
      'Please run `flutter pub run sodium_libs:update_web` again.';
}
