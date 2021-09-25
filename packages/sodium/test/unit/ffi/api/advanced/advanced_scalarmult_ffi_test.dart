import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/advanced/advanced_scalar_mult_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../../secure_key_fake.dart';
import '../../../../test_constants_mapping.dart';
import '../../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  late AdvancedScalarMultFFI sut;

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);

    mockAllocArray(mockSodium);

    sut = AdvancedScalarMultFFI(mockSodium);
  });

  testConstantsMapping([
    Tuple3(
      () => mockSodium.crypto_scalarmult_bytes(),
      () => sut.bytes,
      'bytes',
    ),
    Tuple3(
      () => mockSodium.crypto_scalarmult_scalarbytes(),
      () => sut.scalarBytes,
      'scalarBytes',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_scalarmult_bytes()).thenReturn(5);
      when(() => mockSodium.crypto_scalarmult_scalarbytes()).thenReturn(5);
    });

    group('base', () {
      test('asserts if secretKey is invalid', () {
        expect(
          () => sut.base(
            secretKey: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_scalarmult_scalarbytes());
        verifyNoMoreInteractions(mockSodium);
      });

      test('calls crypto_scalarmult_base with correct arguments', () {
        when(
          () => mockSodium.crypto_scalarmult_base(
            any(),
            any(),
          ),
        ).thenReturn(0);

        final secretKey = List.generate(5, (index) => index);

        sut.base(secretKey: SecureKeyFake(secretKey));

        verifyInOrder([
          () => mockSodium.crypto_scalarmult_scalarbytes(),
          () => mockSodium.crypto_scalarmult_bytes(),
          () => mockSodium.sodium_allocarray(5, 1),
          () => mockSodium.sodium_allocarray(5, 1),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(secretKey)),
              ),
          () => mockSodium.crypto_scalarmult_base(
                any(that: isNot(nullptr)),
                any(that: hasRawData<Uint8>(secretKey)),
              ),
          () => mockSodium.sodium_free(
                any(that: hasRawData<Void>(secretKey)),
              ),
          () => mockSodium.sodium_free(
                any(that: isNot(nullptr)),
              ),
        ]);
        verifyNoMoreInteractions(mockSodium);
      });

      test('returns public key', () {
        final publicKey = List.generate(5, (index) => index);
        when(
          () => mockSodium.crypto_scalarmult_base(
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments[0] as Pointer, publicKey);
          return 0;
        });

        final result = sut.base(secretKey: SecureKeyFake.empty(5));

        expect(result, publicKey);

        verify(
          () => mockSodium.sodium_free(any(that: isNot(nullptr))),
        ).called(2);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_scalarmult_base(
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut.base(secretKey: SecureKeyFake.empty(5)),
          throwsA(isA<SodiumException>()),
        );

        verify(
          () => mockSodium.sodium_free(any(that: isNot(nullptr))),
        ).called(2);
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

        verify(() => mockSodium.crypto_scalarmult_scalarbytes());
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

        verify(() => mockSodium.crypto_scalarmult_scalarbytes());
        verify(() => mockSodium.crypto_scalarmult_bytes());
        verifyNoMoreInteractions(mockSodium);
      });

      test('calls crypto_scalarmult with correct arguments', () {
        when(
          () => mockSodium.crypto_scalarmult(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final secretKey = List.generate(5, (index) => index);
        final otherPublicKey = List.generate(5, (index) => index + 5);

        sut.call(
          secretKey: SecureKeyFake(secretKey),
          otherPublicKey: Uint8List.fromList(otherPublicKey),
        );

        verifyInOrder([
          () => mockSodium.crypto_scalarmult_scalarbytes(),
          () => mockSodium.crypto_scalarmult_bytes(),
          () => mockSodium.crypto_scalarmult_bytes(),
          () => mockSodium.sodium_allocarray(5, 1),
          () => mockSodium.sodium_mprotect_noaccess(
                any(that: isNot(nullptr)),
              ),
          () => mockSodium.sodium_allocarray(5, 1),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: isNot(nullptr)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData<Uint8>(otherPublicKey)),
              ),
          () => mockSodium.sodium_allocarray(5, 1),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(secretKey)),
              ),
          () => mockSodium.crypto_scalarmult(
                any(that: isNot(nullptr)),
                any(that: hasRawData<Uint8>(secretKey)),
                any(that: hasRawData<Uint8>(otherPublicKey)),
              ),
          () => mockSodium.sodium_free(
                any(that: hasRawData<Uint8>(secretKey)),
              ),
          () => mockSodium.sodium_mprotect_noaccess(
                any(that: isNot(nullptr)),
              ),
          () => mockSodium.sodium_free(
                any(that: hasRawData<Uint8>(otherPublicKey)),
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
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments[0] as Pointer, sharedSecret);
          return 0;
        });

        final result = sut.call(
          secretKey: SecureKeyFake.empty(5),
          otherPublicKey: Uint8List.fromList(Uint8List(5)),
        );

        expect(result, SecureKeyFake(sharedSecret));

        verify(
          () => mockSodium.sodium_free(any(that: isNot(nullptr))),
        ).called(2);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_scalarmult(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () {
            return sut.call(
              secretKey: SecureKeyFake.empty(5),
              otherPublicKey: Uint8List.fromList(Uint8List(5)),
            );
          },
          throwsA(isA<SodiumException>()),
        );

        verify(
          () => mockSodium.sodium_free(any(that: isNot(nullptr))),
        ).called(3);
      });
    });
  });
}
