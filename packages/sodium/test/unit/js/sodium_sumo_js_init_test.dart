@TestOn('js')
library;

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/js/api/sumo/sodium_sumo_js.dart';
import 'package:sodium/src/js/sodium_sumo_js_init.dart';
import 'package:test/test.dart';

import 'sodium_js_mock.dart';

void main() {
  final mockSodium = MockLibSodiumJS();

  setUp(() {
    reset(mockSodium);
  });

  test('init returns SodiumSumoJS instance', () {
    final libSodium = mockSodium.asLibSodiumJS;
    final sodium = SodiumSumoInit.initFromJS(libSodium);

    expect(
      sodium,
      isA<SodiumSumoJS>().having((p) => p.sodium, 'sodium', libSodium),
    );
  });
}
