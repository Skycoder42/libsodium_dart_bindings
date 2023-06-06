@JS()
library js_test;

import 'dart:async';
import 'dart:html';

import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:meta/meta.dart';
// ignore: no_self_package_imports
import 'package:sodium/sodium.js.dart';

@JS()
@anonymous
class SodiumBrowserInit {
  external void Function(dynamic sodium) get onload;

  external factory SodiumBrowserInit({
    void Function(LibSodiumJS sodium) onload,
  });
}

mixin JsLoaderMixin {
  String get sodiumJsSrc;

  @protected
  Future<LibSodiumJS> loadSodiumJs() async {
    final completer = Completer<LibSodiumJS>();

    setProperty(
      window,
      'sodium',
      SodiumBrowserInit(
        onload: allowInterop(completer.complete),
      ),
    );

    final script = ScriptElement()..text = sodiumJsSrc;
    document.head!.append(script);

    return completer.future;
  }
}
