@TestOn('js')

import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/js/api/sumo/crypto_sumo_js.dart';
import 'package:sodium/src/js/api/sumo/sodium_sumo_js.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:test/test.dart';

class MockLibSodiumJS extends Mock implements LibSodiumJS {}

void main() {
  final mockSodium = MockLibSodiumJS();

  late SodiumSumoJS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);

    sut = SodiumSumoJS(mockSodium);
  });

  test('crypto returns CryptoSumoJS instance', () {
    expect(
      sut.crypto,
      isA<CryptoSumoJS>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });
}
