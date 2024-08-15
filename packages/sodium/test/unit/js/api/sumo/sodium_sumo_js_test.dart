@TestOn('js')
library sodium_sumo_js_test;

import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/js/api/sumo/crypto_sumo_js.dart';
import 'package:sodium/src/js/api/sumo/sodium_sumo_js.dart';
import 'package:test/test.dart';

import '../../sodium_js_mock.dart';

void main() {
  final mockSodium = MockLibSodiumJS();

  late SodiumSumoJS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);

    sut = SodiumSumoJS(mockSodium.asLibSodiumJS);
  });

  test('crypto returns CryptoSumoJS instance', () {
    expect(
      sut.crypto,
      isA<CryptoSumoJS>().having(
        (p) => p.sodium,
        'sodium',
        sut.sodium,
      ),
    );
  });

  group('runIsolated', () {
    test('invokes the given callback with a sodium sumo instance', () async {
      final isSodium = await sut.runIsolated(
        (sodium, secureKeys, keyPairs) => sodium is SodiumSumoJS,
      );

      expect(isSodium, isTrue);
    });
  });
}
