import 'dart:async';

import '../api/sodium.dart';
import 'api/sodium_js.dart';
import 'bindings/sodium.js.dart';

abstract class SodiumJSInit {
  const SodiumJSInit._();

  static Future<Sodium> init(dynamic sodiumJsObject) =>
      initFromSodiumJS(sodiumJsObject as LibSodiumJS);

  static Future<Sodium> initFromSodiumJS(LibSodiumJS libsodium) =>
      Future.value(SodiumJS(libsodium));
}
