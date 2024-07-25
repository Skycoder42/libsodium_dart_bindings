import 'dart:async';
import 'dart:js_interop';

import 'package:meta/meta.dart';
// ignore: no_self_package_imports
import 'package:sodium/sodium.js.dart';
import 'package:web/web.dart';

extension type SodiumBrowserInit._(JSObject _) implements JSObject {
  external JSFunction get onload;

  external SodiumBrowserInit({
    JSFunction onload,
  });
}

@JS()
external SodiumBrowserInit? get sodium;

@JS()
external set sodium(SodiumBrowserInit? value);

mixin JsLoaderMixin {
  String get sodiumJsSrc;

  @protected
  Future<LibSodiumJS> loadSodiumJs() async {
    final completer = Completer<LibSodiumJS>();

    void onload(LibSodiumJS sodium) => completer.complete(sodium);

    sodium = SodiumBrowserInit(
      onload: onload.toJS,
    );

    final script = HTMLScriptElement()..text = sodiumJsSrc;
    document.head!.append(script);

    return completer.future;
  }
}
