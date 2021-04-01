import 'dart:async';
import 'dart:html';

import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:libsodium_dart_bindings/src/api/crypto.dart';
import 'package:libsodium_dart_bindings/src/js/api/crypto_js.dart';

abstract class SodiumJSInit {
  const SodiumJSInit._();

  static late final Completer<void> _jsLoadedCompleter = Completer<void>();

  static Future<Crypto> init() async {
    setProperty(
      window,
      'sodium',
      jsify(<String, dynamic>{
        'onload': allowInterop(sodiumOnLoaded),
      }),
    );
    await _jsLoadedCompleter.future;
    return CrypoJS();
  }

  static void sodiumOnLoaded(dynamic sodium) {
    setProperty(window, 'sodiumReady', sodium);
    if (!_jsLoadedCompleter.isCompleted) {
      _jsLoadedCompleter.complete();
    }
  }
}
