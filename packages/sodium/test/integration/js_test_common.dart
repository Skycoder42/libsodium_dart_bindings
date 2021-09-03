@JS()
library js_test;

import 'dart:async';
import 'dart:html';

import 'package:js/js.dart';
import 'package:js/js_util.dart';
// dart_pre_commit:ignore-library-import
import 'package:sodium/sodium.dart';
// dart_pre_commit:ignore-library-import
import 'package:sodium/sodium.js.dart';

import 'test_runner.dart';

// ignore: directives_ordering
import 'sodium.js.fake.dart' if (dart.library.js) 'binaries/js/sodium.js.dart';

@JS()
@anonymous
class SodiumBrowserInit {
  external void Function(dynamic sodium) get onload;

  external factory SodiumBrowserInit({
    void Function(LibSodiumJS sodium) onload,
  });
}

class JsTestRunner extends TestRunner {
  JsTestRunner({required bool isSumoTest}) : super(isSumoTest: isSumoTest);

  @override
  Future<Sodium> loadSodium() async {
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

    return SodiumInit.init(await completer.future);
  }
}
