@TestOn('js')

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/js/api/sumo/crypto_sumo_js.dart';
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
}
