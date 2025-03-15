@TestOn('js')
library;

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/js/api/aead_chacha20poly1305_js.dart';
import 'package:sodium/src/js/api/aead_xchacha20poly1305ietf_js.dart';
import 'package:sodium/src/js/api/auth_js.dart';
import 'package:sodium/src/js/api/box_js.dart';
import 'package:sodium/src/js/api/crypto_js.dart';
import 'package:sodium/src/js/api/generic_hash_js.dart';
import 'package:sodium/src/js/api/kdf_js.dart';
import 'package:sodium/src/js/api/kx_js.dart';
import 'package:sodium/src/js/api/secret_box_js.dart';
import 'package:sodium/src/js/api/secret_stream_js.dart';
import 'package:sodium/src/js/api/short_hash_js.dart';
import 'package:sodium/src/js/api/sign_js.dart';
import 'package:test/test.dart';

import '../sodium_js_mock.dart';

void main() {
  final mockSodium = MockLibSodiumJS();

  late CryptoJS sut;

  setUp(() {
    reset(mockSodium);

    sut = CryptoJS(mockSodium.asLibSodiumJS);
  });

  test('secretBox returns SecretBoxJS instance', () {
    expect(
      sut.secretBox,
      isA<SecretBoxJS>().having((p) => p.sodium, 'sodium', sut.sodium),
    );
  });

  test('secretStream returns SecretStreamJS instance', () {
    expect(
      sut.secretStream,
      isA<SecretStreamJS>().having((p) => p.sodium, 'sodium', sut.sodium),
    );
  });

  test('aeadChaCha20Poly1305 returns AeadChacha20Poly1305JS instance', () {
    expect(
      sut.aeadChaCha20Poly1305,
      isA<AeadChaCha20Poly1305JS>().having(
        (p) => p.sodium,
        'sodium',
        sut.sodium,
      ),
    );
  });

  test(
    'aeadXChaCha20Poly1305IETF returns AeadXChaCha20Poly1305IEFTJS instance',
    () {
      expect(
        sut.aeadXChaCha20Poly1305IETF,
        isA<AeadXChaCha20Poly1305IEFTJS>().having(
          (p) => p.sodium,
          'sodium',
          sut.sodium,
        ),
      );
    },
  );

  test('auth returns AuthJS instance', () {
    expect(
      sut.auth,
      isA<AuthJS>().having((p) => p.sodium, 'sodium', sut.sodium),
    );
  });

  test('box returns BoxJS instance', () {
    expect(sut.box, isA<BoxJS>().having((p) => p.sodium, 'sodium', sut.sodium));
  });

  test('sign returns SignJS instance', () {
    expect(
      sut.sign,
      isA<SignJS>().having((p) => p.sodium, 'sodium', sut.sodium),
    );
  });

  test('genericHash returns GenericHashJS instance', () {
    expect(
      sut.genericHash,
      isA<GenericHashJS>().having((p) => p.sodium, 'sodium', sut.sodium),
    );
  });

  test('shortHash returns ShortHashJS instance', () {
    expect(
      sut.shortHash,
      isA<ShortHashJS>().having((p) => p.sodium, 'sodium', sut.sodium),
    );
  });

  test('kdf returns KdfJS instance', () {
    expect(sut.kdf, isA<KdfJS>().having((p) => p.sodium, 'sodium', sut.sodium));
  });

  test('kx returns KxJS instance', () {
    expect(sut.kx, isA<KxJS>().having((p) => p.sodium, 'sodium', sut.sodium));
  });
}
