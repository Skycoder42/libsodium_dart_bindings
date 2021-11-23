@OnPlatform(<String, dynamic>{'!js': Skip('Requires dart:js')})

import 'package:test/test.dart';

import './js_test_common.dart';

void main() {
  JsTestRunner(isSumoTest: true).setupTests();
}
