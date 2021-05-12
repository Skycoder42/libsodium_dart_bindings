import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/js/api/auth_js.dart';
import 'package:sodium/src/js/api/box_js.dart';
import 'package:sodium/src/js/api/crypto_js.dart';
import 'package:sodium/src/js/api/pwhash_js.dart';
import 'package:sodium/src/js/api/secret_box_js.dart';
import 'package:sodium/src/js/api/secret_stream_js.dart';
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

  test('secretStream returns SecretStreamJS instance', () {
    expect(
      sut.secretStream,
      isA<SecretStreamJS>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });

  test('auth returns AuthJS instance', () {
    expect(
      sut.auth,
      isA<AuthJS>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });

  test('box returns BoxJS instance', () {
    expect(
      sut.box,
      isA<BoxJS>().having(
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
