// ignore_for_file: unnecessary_ignore for conditional import

@TestOn('js')
library;

import 'package:sodium/sodium.dart';
import 'package:test/test.dart';

import 'js_test_common.dart';
import 'sodium.js.fake.dart'
    // ignore: conditional_uri_does_not_exist is downloaded
    if (dart.library.js) 'binaries/js/sodium.js.dart'
    as sodium_js;
import 'test_runner.dart';

class JsTestRunner extends TestRunner with JsLoaderMixin {
  @override
  String get sodiumJsSrc => sodium_js.sodiumJsSrc;

  @override
  Future<Sodium> loadSodium() => SodiumInit.init(loadSodiumJs);
}

void main() {
  JsTestRunner().setupTests();
}
