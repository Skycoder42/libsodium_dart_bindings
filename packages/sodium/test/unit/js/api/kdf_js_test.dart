@TestOn('js')
library kdf_js_test;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/kdf_js.dart';
import 'package:sodium/src/js/bindings/js_big_int_x.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';

import '../sodium_js_mock.dart';

void main() {
  final mockSodium = MockLibSodiumJS();

  late KdfJS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(BigInt.zero.toJS);
  });

  setUp(() {
    reset(mockSodium);

    sut = KdfJS(mockSodium.asLibSodiumJS);
  });

  testConstantsMapping([
    (
      () => mockSodium.crypto_kdf_BYTES_MIN,
      () => sut.bytesMin,
      'bytesMin',
    ),
    (
      () => mockSodium.crypto_kdf_BYTES_MAX,
      () => sut.bytesMax,
      'bytesMax',
    ),
    (
      () => mockSodium.crypto_kdf_CONTEXTBYTES,
      () => sut.contextBytes,
      'contextBytes',
    ),
    (
      () => mockSodium.crypto_kdf_KEYBYTES,
      () => sut.keyBytes,
      'keyBytes',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_kdf_BYTES_MIN).thenReturn(5);
      when(() => mockSodium.crypto_kdf_BYTES_MAX).thenReturn(15);
      when(() => mockSodium.crypto_kdf_CONTEXTBYTES).thenReturn(5);
      when(() => mockSodium.crypto_kdf_KEYBYTES).thenReturn(5);
    });

    testKeygen(
      mockSodium: mockSodium,
      runKeygen: () => sut.keygen(),
      keygenNative: mockSodium.crypto_kdf_keygen,
    );

    group('deriveFromKey', () {
      test('asserts if masterKey is invalid', () {
        expect(
          () => sut.deriveFromKey(
            masterKey: SecureKeyFake.empty(10),
            context: 'X' * 5,
            subkeyId: BigInt.zero,
            subkeyLen: 10,
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_kdf_KEYBYTES);
      });

      test('asserts if context is invalid', () {
        expect(
          () => sut.deriveFromKey(
            masterKey: SecureKeyFake.empty(5),
            context: 'X' * 10,
            subkeyId: BigInt.zero,
            subkeyLen: 10,
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_kdf_CONTEXTBYTES);
      });

      test('asserts if subkeyLen is invalid', () {
        expect(
          () => sut.deriveFromKey(
            masterKey: SecureKeyFake.empty(5),
            context: 'X' * 5,
            subkeyId: BigInt.zero,
            subkeyLen: 20,
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_kdf_BYTES_MIN);
        verify(() => mockSodium.crypto_kdf_BYTES_MAX);
      });

      test('calls crypto_kdf_derive_from_key with correct arguments', () {
        when(
          () => mockSodium.crypto_kdf_derive_from_key(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0).toJS);

        final masterKey = List.generate(5, (index) => index * 2);
        const context = 'TEST';
        final subkeyId = BigInt.from(42);
        const subkeyLen = 10;

        sut.deriveFromKey(
          masterKey: SecureKeyFake(masterKey),
          context: context,
          subkeyId: subkeyId,
          subkeyLen: subkeyLen,
        );

        verify(
          () => mockSodium.crypto_kdf_derive_from_key(
            subkeyLen,
            subkeyId.toJS,
            context,
            Uint8List.fromList(masterKey).toJS,
          ),
        );
      });

      test('returns derieved key', () {
        final subkey = List.generate(10, (index) => 100 - index);
        when(
          () => mockSodium.crypto_kdf_derive_from_key(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List.fromList(subkey).toJS);

        final result = sut.deriveFromKey(
          masterKey: SecureKeyFake.empty(5),
          context: 'test',
          subkeyId: BigInt.zero,
          subkeyLen: 10,
        );

        expect(result.extractBytes(), subkey);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_kdf_derive_from_key(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenThrow(JSError());

        expect(
          () => sut.deriveFromKey(
            masterKey: SecureKeyFake.empty(5),
            context: 'test',
            subkeyId: BigInt.zero,
            subkeyLen: 10,
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });
  });
}
