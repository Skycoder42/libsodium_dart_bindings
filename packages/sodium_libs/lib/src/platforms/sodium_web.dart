@JS()
library sodium_libs_plugin_web;

import 'dart:async';
import 'dart:html';

import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:sodium/sodium.dart';

import '../sodium_platform.dart';

@JS()
@anonymous
class _SodiumBrowserInit {
  external void Function(dynamic sodium) get onload;

  external factory _SodiumBrowserInit({void Function(dynamic sodium) onload});
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
    final dynamic sodium = getProperty<dynamic>(window, 'sodium');
    if (sodium != null) {
      return SodiumInit.init(sodium);
    }

    // if not, overwrite sodium window property with custom onload
    final completer = Completer<dynamic>();
    setProperty(
      window,
      'sodium',
      _SodiumBrowserInit(
        onload: allowInterop(completer.complete),
      ),
    );

    // ... add the sodium script to the page
    final script = ScriptElement()
      ..type = 'text/javascript'
      ..async = true
      // ignore: unsafe_html
      ..src = 'sodium.js';
    document.body!.append(script);

    return SodiumInit.init(await completer.future);
  }

  @override
  String get updateHint =>
      'Please run `flutter pub run sodium_libs:update_web` again.';
}
