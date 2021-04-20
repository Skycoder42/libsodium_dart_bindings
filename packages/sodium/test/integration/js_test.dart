@JS()
library js_test;

import 'dart:async';
import 'dart:html';

import 'package:js/js.dart';
import 'package:js/js_util.dart';
import 'package:sodium/sodium.dart';
import 'package:sodium/sodium.js.dart';

import 'test_runner.dart';

// ignore: directives_ordering
import 'sodium.js.fake.dart' if (dart.library.js) 'binaries/js/sodium.js.dart';

@JS()
@anonymous
class SodiumInit {
  external void Function(dynamic sodium) get onload;

  external factory SodiumInit({void Function(LibSodiumJS sodium) onload});
}

class JsTestRunner extends TestRunner {
  @override
  Future<Sodium> loadSodium() async {
    final completer = Completer<LibSodiumJS>();

    setProperty(
      window,
      'sodium',
      SodiumInit(
        onload: allowInterop(completer.complete),
      ),
    );

    final script = ScriptElement()..text = sodiumJsSrc;
    document.head!.append(script);

    return SodiumJSInit.init(await completer.future);
  }
}

void main() {
  JsTestRunner().setupTests();
}
