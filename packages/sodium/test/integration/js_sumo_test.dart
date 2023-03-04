@TestOn('js')
library js_sumo_test;

// ignore: test_library_import
import 'package:sodium/sodium_sumo.dart';
import 'package:test/test.dart';

import './js_test_common.dart';
import 'sodium_sumo.js.fake.dart'
// ignore: conditional_uri_does_not_exist
    if (dart.library.js) 'binaries/js/sodium_sumo.js.dart' as sodium_sumo_js;
import 'test_runner.dart';

class JsSumoTestRunner extends SumoTestRunner with JsLoaderMixin {
  @override
  String get sodiumJsSrc => sodium_sumo_js.sodiumJsSrc;

  @override
  Future<SodiumSumo> loadSodium() async =>
      SodiumSumoInit.init(await loadSodiumJs());
}

void main() {
  JsSumoTestRunner().setupTests();
}
