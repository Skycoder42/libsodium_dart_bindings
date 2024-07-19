@TestOn('js')
library sign_sumo_js_test;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/sumo/sign_sumo_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:test/test.dart';

import '../../../../secure_key_fake.dart';

import '../../sodium_js_mock.dart';

void main() {
  final mockSodium = MockLibSodiumJS();

  late SignSumoJS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);

    sut = SignSumoJS(mockSodium.asLibSodiumJS);
  });

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_sign_PUBLICKEYBYTES).thenReturn(5);
      when(() => mockSodium.crypto_sign_SECRETKEYBYTES).thenReturn(5);
      when(() => mockSodium.crypto_sign_SEEDBYTES).thenReturn(5);
    });

    group('skToSeed', () {
      test('asserts if secretKey is invalid', () {
        expect(
          () => sut.skToSeed(SecureKeyFake.empty(10)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_SECRETKEYBYTES);
      });

      test('calls crypto_sign_ed25519_sk_to_seed with correct arguments', () {
        when(
          () => mockSodium.crypto_sign_ed25519_sk_to_seed(any()),
        ).thenReturn(Uint8List(0).toJS);

        final secretKey = List.generate(5, (index) => 30 + index);

        sut.skToSeed(SecureKeyFake(secretKey));

        verify(
          () => mockSodium.crypto_sign_ed25519_sk_to_seed(
            Uint8List.fromList(secretKey).toJS,
          ),
        );
      });

      test('returns seed of the secret key', () {
        final seed = List.generate(5, (index) => 100 - index);
        when(
          () => mockSodium.crypto_sign_ed25519_sk_to_seed(any()),
        ).thenReturn(Uint8List.fromList(seed).toJS);

        final result = sut.skToSeed(SecureKeyFake.empty(5));

        expect(result.extractBytes(), seed);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_sign_ed25519_sk_to_seed(any()),
        ).thenThrow(JSError());

        expect(
          () => sut.skToSeed(SecureKeyFake.empty(5)),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('skToPk', () {
      test('asserts if secretKey is invalid', () {
        expect(
          () => sut.skToPk(SecureKeyFake.empty(10)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_SECRETKEYBYTES);
      });

      test('calls crypto_sign_ed25519_sk_to_pk with correct arguments', () {
        when(
          () => mockSodium.crypto_sign_ed25519_sk_to_pk(any()),
        ).thenReturn(Uint8List(0).toJS);

        final secretKey = List.generate(5, (index) => 30 + index);

        sut.skToPk(SecureKeyFake(secretKey));

        verify(
          () => mockSodium.crypto_sign_ed25519_sk_to_pk(
            Uint8List.fromList(secretKey).toJS,
          ),
        );
      });

      test('returns the public key of the secret key', () {
        final publicKey = List.generate(5, (index) => 100 - index);
        when(
          () => mockSodium.crypto_sign_ed25519_sk_to_pk(any()),
        ).thenReturn(Uint8List.fromList(publicKey).toJS);

        final result = sut.skToPk(SecureKeyFake.empty(5));

        expect(result, publicKey);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_sign_ed25519_sk_to_pk(any()),
        ).thenThrow(JSError());

        expect(
          () => sut.skToPk(SecureKeyFake.empty(5)),
          throwsA(isA<SodiumException>()),
        );
      });
    });
  });
}
