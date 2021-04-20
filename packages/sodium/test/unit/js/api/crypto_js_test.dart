import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/js/api/crypto_js.dart';
import 'package:sodium/src/js/api/pwhash_js.dart';
import 'package:sodium/src/js/api/secret_box_js.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:test/test.dart';

class MockLibSodiumJS extends Mock implements LibSodiumJS {}

void main() {
  final mockSodium = MockLibSodiumJS();

  late CryptoJS sut;

  setUp(() {
    reset(mockSodium);

    sut = CryptoJS(mockSodium);
  });

  test('secretBox returns SecretBoxJS instance', () {
    expect(
      sut.secretBox,
      isA<SecretBoxJS>().having(
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
}
