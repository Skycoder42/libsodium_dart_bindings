@TestOn('js')

import 'package:test/test.dart';

import 'js_test_common.dart';
// ignore: conditional_uri_does_not_exist
import 'sodium.js.fake.dart' if (dart.library.js) 'binaries/js/sodium.js.dart';

void main() {
  JsTestRunner(
    sodiumJsSrc: sodiumJsSrc,
    isSumoTest: false,
  ).setupTests();
}
