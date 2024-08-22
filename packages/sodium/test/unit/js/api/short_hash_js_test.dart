@TestOn('js')
library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/short_hash_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';

import '../sodium_js_mock.dart';

void main() {
  final mockSodium = MockLibSodiumJS();

  late ShortHashJS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);

    sut = ShortHashJS(mockSodium.asLibSodiumJS);
  });

  testConstantsMapping([
    (
      () => mockSodium.crypto_shorthash_BYTES,
      () => sut.bytes,
      'bytes',
    ),
    (
      () => mockSodium.crypto_shorthash_KEYBYTES,
      () => sut.keyBytes,
      'keyBytes',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_shorthash_KEYBYTES).thenReturn(5);
    });

    testKeygen(
      mockSodium: mockSodium,
      runKeygen: () => sut.keygen(),
      keygenNative: mockSodium.crypto_shorthash_keygen,
    );

    group('call', () {
      test('asserts if key is invalid', () {
        expect(
          () => sut(
            message: Uint8List(0),
            key: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_shorthash_KEYBYTES);
      });

      test('calls crypto_generichash with correct arguments', () {
        when(
          () => mockSodium.crypto_shorthash(
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0).toJS);

        final key = List.generate(5, (index) => index * 10);
        final message = List.generate(20, (index) => index * 2);

        sut(
          message: Uint8List.fromList(message),
          key: SecureKeyFake(key),
        );

        verify(
          () => mockSodium.crypto_shorthash(
            Uint8List.fromList(message).toJS,
            Uint8List.fromList(key).toJS,
          ),
        );
      });

      test('returns calculated hash', () {
        final hash = List.generate(5, (index) => 10 + index);
        when(
          () => mockSodium.crypto_shorthash(
            any(),
            any(),
          ),
        ).thenReturn(Uint8List.fromList(hash).toJS);

        final result = sut(
          message: Uint8List(10),
          key: SecureKeyFake.empty(5),
        );

        expect(result, hash);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_shorthash(
            any(),
            any(),
          ),
        ).thenThrow(JSError());

        expect(
          () => sut(
            message: Uint8List(15),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });
  });
}
