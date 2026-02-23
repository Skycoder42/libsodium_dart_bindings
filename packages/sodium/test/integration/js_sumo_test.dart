// ignore_for_file: unnecessary_ignore for conditional import

@TestOn('js')
library;

import 'package:sodium/sodium_sumo.dart';
import 'package:test/test.dart';

import './js_test_common.dart';
import 'sodium_sumo.js.fake.dart'
    // ignore: conditional_uri_does_not_exist is generated
    if (dart.library.js) 'binaries/js/sodium_sumo.js.dart'
    as sodium_sumo_js;
import 'test_runner.dart';

class JsSumoTestRunner extends SumoTestRunner with JsLoaderMixin {
  @override
  String get sodiumJsSrc => sodium_sumo_js.sodiumJsSrc;

  @override
  Future<SodiumSumo> loadSodium() => SodiumSumoInit.init(loadSodiumJs);
}

void main() {
  JsSumoTestRunner().setupTests();
}
