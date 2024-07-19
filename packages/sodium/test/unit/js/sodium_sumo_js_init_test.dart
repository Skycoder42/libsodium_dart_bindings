@TestOn('js')
library sodium_sumo_js_init_test;

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/js/api/sodium_js.dart';
import 'package:sodium/src/js/sodium_sumo_js_init.dart';
import 'package:test/test.dart';

import 'sodium_js_mock.dart';

void main() {
  final mockSodium = MockLibSodiumJS();

  setUp(() {
    reset(mockSodium);
  });

  test('initFromSodiumJS returns SodiumJS instance', () async {
    final libSodium = mockSodium.asLibSodiumJS;
    final sodium = await SodiumSumoInit.initFromSodiumJS(() => libSodium);

    expect(
      sodium,
      isA<SodiumJS>().having(
        (p) => p.sodium,
        'sodium',
        libSodium,
      ),
    );
  });

  test('init returns SodiumJS instance', () async {
    final libSodium = mockSodium.asLibSodiumJS;
    final sodium = await SodiumSumoInit.init(() => libSodium);

    expect(
      sodium,
      isA<SodiumJS>().having(
        (p) => p.sodium,
        'sodium',
        libSodium,
      ),
    );
  });
}
