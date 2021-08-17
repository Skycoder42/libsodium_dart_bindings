@JS()
library sodium_libs_plugin_web;

import 'dart:async';
import 'dart:html';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:meta/meta.dart';
import 'package:sodium/sodium.dart';

import '../sodium_platform.dart';

@JS()
@anonymous
class _SodiumBrowserInit {
  external void Function(dynamic sodium) get onload;

  external factory _SodiumBrowserInit({void Function(dynamic sodium) onload});
}

@internal
class SodiumWeb extends SodiumPlatform {
  static void registerWith([Registrar? registrar]) {
    SodiumPlatform.instance = SodiumWeb();
  }

  @override
  Future<Sodium> loadSodium({bool initNative = true}) async {
    final completer = Completer<dynamic>();

    setProperty(
      window,
      'sodium',
      _SodiumBrowserInit(
        onload: allowInterop(completer.complete),
      ),
    );

    final script = ScriptElement()
      ..type = 'text/javascript'
      ..async = true
      // ignore: unsafe_html
      ..src = 'sodium.js';
    document.head!.append(script);

    return SodiumInit.init(
      await completer.future,
      initNative: initNative,
    );
  }

  @override
  String get updateHint =>
      'Please run `flutter pub run sodium_libs:update_web` again.';
}
