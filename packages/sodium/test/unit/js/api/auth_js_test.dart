import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/auth_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';

class MockLibSodiumJS extends Mock implements LibSodiumJS {}

void main() {
  final mockSodium = MockLibSodiumJS();

  late AuthJS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);

    sut = AuthJS(mockSodium);
  });

  testConstantsMapping([
    Tuple3(
      () => mockSodium.crypto_auth_BYTES,
      () => sut.bytes,
      'bytes',
    ),
    Tuple3(
      () => mockSodium.crypto_auth_KEYBYTES,
      () => sut.keyBytes,
      'keyBytes',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_auth_BYTES).thenReturn(5);
      when(() => mockSodium.crypto_auth_KEYBYTES).thenReturn(5);
    });

    group('keygen', () {
      test('calls crypto_auth_keygen on generated key', () {
        when(() => mockSodium.crypto_auth_keygen()).thenReturn(Uint8List(0));

        sut.keygen();

        verify(() => mockSodium.crypto_auth_keygen());
      });

      test('returns generated key', () {
        final testData = List.generate(5, (index) => index);
        when(() => mockSodium.crypto_auth_keygen())
            .thenReturn(Uint8List.fromList(testData));

        final res = sut.keygen();

        expect(res.extractBytes(), testData);
      });

      test('throws SodiumException on JsError', () {
        when(() => mockSodium.crypto_auth_keygen()).thenThrow(JsError());

        expect(() => sut.keygen(), throwsA(isA<SodiumException>()));
      });
    });

    group('call', () {
      test('asserts if key is invalid', () {
        expect(
          () => sut(
            message: Uint8List(0),
            key: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_auth_KEYBYTES);
      });

      test('calls crypto_auth with correct arguments', () {
        when(
          () => mockSodium.crypto_auth(
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0));

        final message = List.generate(20, (index) => index * 2);
        final key = List.generate(5, (index) => index);

        sut(
          message: Uint8List.fromList(message),
          key: SecureKeyFake(key),
        );

        verify(
          () => mockSodium.crypto_auth(
            Uint8List.fromList(message),
            Uint8List.fromList(key),
          ),
        );
      });

      test('returns authentication tag', () {
        final tag = List.generate(5, (index) => 10 + index);
        when(
          () => mockSodium.crypto_auth(
            any(),
            any(),
          ),
        ).thenReturn(Uint8List.fromList(tag));

        final result = sut(
          message: Uint8List(10),
          key: SecureKeyFake.empty(5),
        );

        expect(result, tag);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_auth(
            any(),
            any(),
          ),
        ).thenThrow(JsError());

        expect(
          () => sut(
            message: Uint8List(15),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('verify', () {
      test('asserts if tag is invalid', () {
        expect(
          () => sut.verify(
            tag: Uint8List(10),
            message: Uint8List(0),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_auth_BYTES);
      });

      test('asserts if key is invalid', () {
        expect(
          () => sut.verify(
            tag: Uint8List(5),
            message: Uint8List(0),
            key: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_auth_KEYBYTES);
      });

      test('calls crypto_auth_verify with correct arguments', () {
        when(
          () => mockSodium.crypto_auth_verify(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(true);

        final tag = List.generate(5, (index) => index + 15);
        final message = List.generate(20, (index) => index * 2);
        final key = List.generate(5, (index) => index);

        sut.verify(
          tag: Uint8List.fromList(tag),
          message: Uint8List.fromList(message),
          key: SecureKeyFake(key),
        );

        verify(
          () => mockSodium.crypto_auth_verify(
            Uint8List.fromList(tag),
            Uint8List.fromList(message),
            Uint8List.fromList(key),
          ),
        );
      });

      test('returns true if validate succeeds', () {
        when(
          () => mockSodium.crypto_auth_verify(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(true);

        final result = sut.verify(
          tag: Uint8List(5),
          message: Uint8List(22),
          key: SecureKeyFake.empty(5),
        );

        expect(result, isTrue);
      });

      test('returns false if validate fails', () {
        when(
          () => mockSodium.crypto_auth_verify(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(false);

        final result = sut.verify(
          tag: Uint8List(5),
          message: Uint8List(22),
          key: SecureKeyFake.empty(5),
        );

        expect(result, isFalse);
      });

      test('throws SodiumException on JsError', () {
        when(
          () => mockSodium.crypto_auth_verify(
            any(),
            any(),
            any(),
          ),
        ).thenThrow(JsError());

        expect(
          () => sut.verify(
            tag: Uint8List(5),
            message: Uint8List(22),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });
  });
}
