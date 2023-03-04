@TestOn('js')
library js_test;

// ignore: test_library_import
import 'package:sodium/sodium.dart';
import 'package:test/test.dart';

import 'js_test_common.dart';
// ignore: conditional_uri_does_not_exist
import 'sodium.js.fake.dart' if (dart.library.js) 'binaries/js/sodium.js.dart'
    as sodium_js;
import 'test_runner.dart';

class JsTestRunner extends TestRunner with JsLoaderMixin {
  @override
  String get sodiumJsSrc => sodium_js.sodiumJsSrc;

  @override
  Future<Sodium> loadSodium() async => SodiumInit.init2(loadSodiumJs);
}

void main() {
  JsTestRunner().setupTests();
}
