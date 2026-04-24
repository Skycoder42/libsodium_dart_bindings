// ignore_for_file: unnecessary_lambdas to catch member access errors

@TestOn('js')
library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/kem_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';
import '../sodium_js_mock.dart';

void main() {
  final mockSodium = MockLibSodiumJS();

  late KemJS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);

    sut = KemJS(mockSodium.asLibSodiumJS);
  });

  testConstantsMapping([
    (
      () => mockSodium.crypto_kem_PUBLICKEYBYTES,
      () => sut.publicKeyBytes,
      'publicKeyBytes',
    ),
    (
      () => mockSodium.crypto_kem_SECRETKEYBYTES,
      () => sut.secretKeyBytes,
      'secretKeyBytes',
    ),
    (
      () => mockSodium.crypto_kem_CIPHERTEXTBYTES,
      () => sut.ciphertextBytes,
      'ciphertextBytes',
    ),
    (
      () => mockSodium.crypto_kem_SHAREDSECRETBYTES,
      () => sut.sharedSecretBytes,
      'sharedSecretBytes',
    ),
    (() => mockSodium.crypto_kem_SEEDBYTES, () => sut.seedBytes, 'seedBytes'),
  ]);

  test('maps primitive correctly', () {
    when(() => mockSodium.crypto_kem_primitive()).thenReturn('xwing');

    expect(sut.primitive, 'xwing');
    verify(() => mockSodium.crypto_kem_primitive());
  });

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_kem_PUBLICKEYBYTES).thenReturn(5);
      when(() => mockSodium.crypto_kem_SECRETKEYBYTES).thenReturn(5);
      when(() => mockSodium.crypto_kem_CIPHERTEXTBYTES).thenReturn(5);
      when(() => mockSodium.crypto_kem_SHAREDSECRETBYTES).thenReturn(5);
      when(() => mockSodium.crypto_kem_SEEDBYTES).thenReturn(5);
    });

    testKeypair(
      mockSodium: mockSodium,
      runKeypair: () => sut.keyPair(),
      keypairNative: mockSodium.crypto_kem_keypair,
    );

    testSeedKeypair(
      mockSodium: mockSodium,
      runSeedKeypair: (seed) => sut.seedKeyPair(seed),
      seedBytesNative: () => mockSodium.crypto_kem_SEEDBYTES,
      seedKeypairNative: mockSodium.crypto_kem_seed_keypair,
    );

    group('enc', () {
      test('asserts if publicKey is invalid', () {
        expect(
          () => sut.enc(publicKey: Uint8List(10)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_kem_PUBLICKEYBYTES);
      });

      test('calls crypto_kem_enc with correct arguments', () {
        when(() => mockSodium.crypto_kem_enc(any())).thenReturn(
          KemEncResult(
            ciphertext: Uint8List(0).toJS,
            sharedSecret: Uint8List(0).toJS,
          ),
        );

        final publicKey = List.generate(5, (i) => i);
        sut.enc(publicKey: Uint8List.fromList(publicKey));

        verify(
          () => mockSodium.crypto_kem_enc(Uint8List.fromList(publicKey).toJS),
        );
      });

      test('returns enc result', () {
        final ctData = List.generate(5, (i) => i + 10);
        final ssData = List.generate(5, (i) => i + 20);

        when(() => mockSodium.crypto_kem_enc(any())).thenReturn(
          KemEncResult(
            ciphertext: Uint8List.fromList(ctData).toJS,
            sharedSecret: Uint8List.fromList(ssData).toJS,
          ),
        );

        final result = sut.enc(publicKey: Uint8List(5));

        expect(result.ciphertext, ctData);
        expect(result.sharedSecret.extractBytes(), ssData);
      });

      test('throws exception on failure', () {
        when(() => mockSodium.crypto_kem_enc(any())).thenThrow(JSError());

        expect(
          () => sut.enc(publicKey: Uint8List(5)),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('dec', () {
      test('asserts if ciphertext is invalid', () {
        expect(
          () => sut.dec(
            ciphertext: Uint8List(10),
            secretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_kem_CIPHERTEXTBYTES);
      });

      test('asserts if secretKey is invalid', () {
        expect(
          () => sut.dec(
            ciphertext: Uint8List(5),
            secretKey: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_kem_SECRETKEYBYTES);
      });

      test('calls crypto_kem_dec with correct arguments', () {
        when(
          () => mockSodium.crypto_kem_dec(any(), any()),
        ).thenReturn(Uint8List(0).toJS);

        final ctData = List.generate(5, (i) => i);
        final skData = List.generate(5, (i) => i + 50);

        sut.dec(
          ciphertext: Uint8List.fromList(ctData),
          secretKey: SecureKeyFake(skData),
        );

        verify(
          () => mockSodium.crypto_kem_dec(
            Uint8List.fromList(ctData).toJS,
            Uint8List.fromList(skData).toJS,
          ),
        );
      });

      test('returns shared secret', () {
        final ssData = List.generate(5, (i) => i + 30);

        when(
          () => mockSodium.crypto_kem_dec(any(), any()),
        ).thenReturn(Uint8List.fromList(ssData).toJS);

        final result = sut.dec(
          ciphertext: Uint8List(5),
          secretKey: SecureKeyFake.empty(5),
        );

        expect(result.extractBytes(), ssData);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_kem_dec(any(), any()),
        ).thenThrow(JSError());

        expect(
          () => sut.dec(
            ciphertext: Uint8List(5),
            secretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });
  });
}
