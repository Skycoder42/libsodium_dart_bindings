// ignore_for_file: unnecessary_ignore for conditional import

@TestOn('js')
library;

import 'dart:async';

import 'package:sodium/sodium.dart';
import 'package:test/test.dart';

import 'js_test_common.dart';
import 'sodium.js.fake.dart'
    if (dart.library.js) 'binaries/js/sodium.js.dart'
    as sodium_js;
import 'test_runner.dart';

class JsTestRunner extends TestRunner with JsLoaderMixin {
  @override
  String get sodiumJsSrc => sodium_js.sodiumJsSrc;

  @override
  FutureOr<Sodium> loadSodium() => SodiumInit.init(loadSodiumJs);
}

void main() {
  JsTestRunner().setupTests();
}
