@TestOn('js')
library crypto_sumo_js_test;

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/js/api/sumo/crypto_sumo_js.dart';
import 'package:sodium/src/js/api/sumo/pwhash_js.dart';
import 'package:sodium/src/js/api/sumo/scalarmult_js.dart';
import 'package:sodium/src/js/api/sumo/sign_sumo_js.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:test/test.dart';

class MockLibSodiumJS extends Mock implements LibSodiumJS {}

void main() {
  final mockSodium = MockLibSodiumJS();

  late CryptoSumoJS sut;

  setUp(() {
    reset(mockSodium);

    sut = CryptoSumoJS(mockSodium);
  });

  test('sign returns SignSumoJS instance', () {
    expect(
      sut.sign,
      isA<SignSumoJS>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });

  test('pwhash returns PwhashJS instance', () {
    expect(
      sut.pwhash,
      isA<PwhashJS>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });

  test('scalarmult returns ScalarmultSumoJS instance', () {
    expect(
      sut.scalarmult,
      isA<ScalarmultJS>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });
}
