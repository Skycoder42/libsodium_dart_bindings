@TestOn('js')
library;

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/js/api/sumo/crypto_sumo_js.dart';
import 'package:sodium/src/js/api/sumo/pwhash_js.dart';
import 'package:sodium/src/js/api/sumo/scalarmult_js.dart';
import 'package:sodium/src/js/api/sumo/sign_sumo_js.dart';
import 'package:test/test.dart';

import '../../sodium_js_mock.dart';

void main() {
  final mockSodium = MockLibSodiumJS();

  late CryptoSumoJS sut;

  setUp(() {
    reset(mockSodium);

    sut = CryptoSumoJS(mockSodium.asLibSodiumJS);
  });

  test('sign returns SignSumoJS instance', () {
    expect(
      sut.sign,
      isA<SignSumoJS>().having((p) => p.sodium, 'sodium', sut.sodium),
    );
  });

  test('pwhash returns PwhashJS instance', () {
    expect(
      sut.pwhash,
      isA<PwhashJS>().having((p) => p.sodium, 'sodium', sut.sodium),
    );
  });

  test('scalarmult returns ScalarmultSumoJS instance', () {
    expect(
      sut.scalarmult,
      isA<ScalarmultJS>().having((p) => p.sodium, 'sodium', sut.sodium),
    );
  });
}
