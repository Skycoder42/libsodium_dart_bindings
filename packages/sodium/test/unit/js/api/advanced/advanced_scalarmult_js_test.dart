import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/sodium.js.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/advanced/advanced_scalar_mult_js.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../../secure_key_fake.dart';
import '../../../../test_constants_mapping.dart';

class MockSodiumJS extends Mock implements LibSodiumJS {}

void main() {
  final mockSodium = MockSodiumJS();

  late AdvancedScalarMultJS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);

    sut = AdvancedScalarMultJS(mockSodium);
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
      when(() => mockSodium.crypto_scalarmult_SCALARBYTES).thenReturn(5);
    });

    group('base', () {
      test('asserts if secretKey is invalid', () {
        expect(
          () => sut.base(
            secretKey: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_scalarmult_SCALARBYTES);
        verifyNoMoreInteractions(mockSodium);
      });

      test('calls crypto_scalarmult_base with correct arguments', () {
        when(
          () => mockSodium.crypto_scalarmult_base(
            any(),
          ),
        ).thenReturn(Uint8List(0));

        final secretKey = List.generate(5, (index) => index);

        sut.base(secretKey: SecureKeyFake(secretKey));

        verifyInOrder([
          () => mockSodium.crypto_scalarmult_SCALARBYTES,
          () => mockSodium.crypto_scalarmult_base(
                any(),
              ),
        ]);
        verifyNoMoreInteractions(mockSodium);
      });

      test('returns public key', () {
        final publicKey = List.generate(5, (index) => index);
        when(
          () => mockSodium.crypto_scalarmult_base(
            any(),
          ),
        ).thenAnswer((_) => Uint8List.fromList(publicKey));

        final result = sut.base(secretKey: SecureKeyFake.empty(5));

        expect(result, publicKey);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_scalarmult_base(
            any(),
          ),
        ).thenThrow(JsError());

        expect(
          () => sut.base(secretKey: SecureKeyFake.empty(5)),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('call', () {
      test('asserts if secretKey is invalid', () {
        expect(
          () => sut.call(
            secretKey: SecureKeyFake.empty(10),
            otherPublicKey: Uint8List(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_scalarmult_SCALARBYTES);
        verifyNoMoreInteractions(mockSodium);
      });

      test('asserts if otherPublicKey is invalid', () {
        expect(
          () => sut.call(
            secretKey: SecureKeyFake.empty(5),
            otherPublicKey: Uint8List(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_scalarmult_SCALARBYTES);
        verify(() => mockSodium.crypto_scalarmult_BYTES);
        verifyNoMoreInteractions(mockSodium);
      });

      test('calls crypto_scalarmult with correct arguments', () {
        final sharedSecret = List.generate(5, (index) => index);
        when(
          () => mockSodium.crypto_scalarmult(
            any(),
            any(),
          ),
        ).thenAnswer((_) => Uint8List.fromList(sharedSecret));

        final secretKey = List.generate(5, (index) => index);
        final otherPublicKey = List.generate(5, (index) => index + 5);

        sut.call(
          secretKey: SecureKeyFake(secretKey),
          otherPublicKey: Uint8List.fromList(otherPublicKey),
        );

        verifyInOrder([
          () => mockSodium.crypto_scalarmult_SCALARBYTES,
          () => mockSodium.crypto_scalarmult_BYTES,
          () => mockSodium.crypto_scalarmult(
                any(),
                any(),
              ),
        ]);
        verifyNoMoreInteractions(mockSodium);
      });

      test('returns shared secret', () {
        final sharedSecret = List.generate(5, (index) => index);
        when(
          () => mockSodium.crypto_scalarmult(
            any(),
            any(),
          ),
        ).thenAnswer((_) => Uint8List.fromList(sharedSecret));

        final result = sut.call(
          secretKey: SecureKeyFake.empty(5),
          otherPublicKey: Uint8List.fromList(Uint8List(5)),
        );

        expect(result, SecureKeyFake(sharedSecret));
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_scalarmult(
            any(),
            any(),
          ),
        ).thenThrow(JsError());

        expect(
          () => sut.call(
            secretKey: SecureKeyFake.empty(5),
            otherPublicKey: Uint8List.fromList(Uint8List(5)),
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });
  });
}
