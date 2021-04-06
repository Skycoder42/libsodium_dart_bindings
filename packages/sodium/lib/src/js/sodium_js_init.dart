import 'dart:async';
import 'dart:html';
import 'dart:js';

import 'package:js/js.dart';
import 'package:js/js_util.dart';

import '../api/sodium.dart';
import 'api/sodium_js.dart';

abstract class SodiumJSInit {
  const SodiumJSInit._();

  static late final Completer<JsObject> _jsLoadedCompleter =
      Completer<JsObject>();

  static Future<Sodium> init() async {
    setProperty(
      window,
      'sodium',
      jsify(<String, dynamic>{
        'onload': allowInterop(sodiumOnLoaded),
      }),
    );

    return SodiumJS(await _jsLoadedCompleter.future);
  }

  static void sodiumOnLoaded(dynamic sodium) {
    if (!_jsLoadedCompleter.isCompleted) {
      _jsLoadedCompleter.complete(sodium as JsObject);
    }
  }
}
