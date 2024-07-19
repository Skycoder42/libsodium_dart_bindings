@TestOn('js')
library scalarmult_js_test;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/sumo/scalarmult_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../../secure_key_fake.dart';
import '../../../../test_constants_mapping.dart';

import '../../sodium_js_mock.dart';

void main() {
  final mockSodium = MockLibSodiumJS();

  late ScalarmultJS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);

    sut = ScalarmultJS(mockSodium.asLibSodiumJS);
  });

  testConstantsMapping([
    Tuple3(
      () => mockSodium.crypto_scalarmult_BYTES,
      () => sut.bytes,
      'bytes',
    ),
    Tuple3(
      () => mockSodium.crypto_scalarmult_SCALARBYTES,
      () => sut.scalarBytes,
      'scalarBytes',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_scalarmult_BYTES).thenReturn(5);
      when(() => mockSodium.crypto_scalarmult_SCALARBYTES).thenReturn(10);
    });

    group('base', () {
      test('asserts if n is invalid', () {
        expect(
          () => sut.base(n: SecureKeyFake.empty(5)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_scalarmult_SCALARBYTES);
      });

      test('calls crypto_scalarmult_base with correct arguments', () {
        when(
          () => mockSodium.crypto_scalarmult_base(
            any(),
          ),
        ).thenReturn(Uint8List(0).toJS);

        final n = List.generate(10, (index) => index);

        sut.base(n: SecureKeyFake(n));

        verify(
          () => mockSodium.crypto_scalarmult_base(Uint8List.fromList(n).toJS),
        );
      });

      test('returns public key data', () {
        final q = List.generate(5, (index) => 100 - index);
        when(
          () => mockSodium.crypto_scalarmult_base(
            any(),
          ),
        ).thenReturn(Uint8List.fromList(q).toJS);

        final result = sut.base(
          n: SecureKeyFake.empty(10),
        );

        expect(result, q);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_scalarmult_base(
            any(),
          ),
        ).thenThrow(JSError());

        expect(
          () => sut.base(
            n: SecureKeyFake.empty(10),
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('call', () {
      test('asserts if n is invalid', () {
        expect(
          () => sut(
            n: SecureKeyFake.empty(5),
            p: Uint8List(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_scalarmult_SCALARBYTES);
      });

      test('asserts if p is invalid', () {
        expect(
          () => sut(
            n: SecureKeyFake.empty(10),
            p: Uint8List(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verifyInOrder([
          () => mockSodium.crypto_scalarmult_SCALARBYTES,
          () => mockSodium.crypto_scalarmult_BYTES,
        ]);
      });

      test('calls crypto_scalarmult with correct arguments', () {
        when(
          () => mockSodium.crypto_scalarmult(
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0).toJS);

        final n = List.generate(10, (index) => index);
        final p = List.generate(5, (index) => index * 2);

        sut(
          n: SecureKeyFake(n),
          p: Uint8List.fromList(p),
        );

        verify(
          () => mockSodium.crypto_scalarmult(
            Uint8List.fromList(n).toJS,
            Uint8List.fromList(p).toJS,
          ),
        );
      });

      test('returns shared key data', () {
        final q = List.generate(5, (index) => 100 - index);
        when(
          () => mockSodium.crypto_scalarmult(
            any(),
            any(),
          ),
        ).thenReturn(Uint8List.fromList(q).toJS);

        final result = sut(
          n: SecureKeyFake.empty(10),
          p: Uint8List(5),
        );

        expect(result.extractBytes(), q);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_scalarmult(
            any(),
            any(),
          ),
        ).thenThrow(JSError());

        expect(
          () => sut(
            n: SecureKeyFake.empty(10),
            p: Uint8List(5),
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });
  });
}
