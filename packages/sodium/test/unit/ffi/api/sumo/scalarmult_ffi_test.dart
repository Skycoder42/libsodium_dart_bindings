// ignore_for_file: unnecessary_lambdas

@TestOn('dart-vm')
library scalarmult_ffi_test;

import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/sumo/scalarmult_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';

import '../../../../secure_key_fake.dart';
import '../../../../test_constants_mapping.dart';
import '../../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  late ScalarmultFFI sut;

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);

    mockAllocArray(mockSodium);

    sut = ScalarmultFFI(mockSodium);
  });

  testConstantsMapping([
    (
      () => mockSodium.crypto_scalarmult_bytes(),
      () => sut.bytes,
      'bytes',
    ),
    (
      () => mockSodium.crypto_scalarmult_scalarbytes(),
      () => sut.scalarBytes,
      'scalarBytes',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_scalarmult_bytes()).thenReturn(5);
      when(() => mockSodium.crypto_scalarmult_scalarbytes()).thenReturn(10);
    });

    group('base', () {
      test('asserts if n is invalid', () {
        expect(
          () => sut.base(n: SecureKeyFake.empty(5)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_scalarmult_scalarbytes());
      });

      test('calls crypto_scalarmult_base with correct arguments', () {
        when(
          () => mockSodium.crypto_scalarmult_base(
            any(),
            any(),
          ),
        ).thenReturn(0);

        final n = List.generate(10, (index) => index);

        sut.base(n: SecureKeyFake(n));

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(n)),
              ),
          () => mockSodium.crypto_scalarmult_base(
                any(that: isNot(nullptr)),
                any(that: hasRawData<UnsignedChar>(n)),
              ),
        ]);
      });

      test('returns public key data', () {
        final q = List.generate(5, (index) => 100 - index);
        when(
          () => mockSodium.crypto_scalarmult_base(
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(
            i.positionalArguments.first as Pointer<UnsignedChar>,
            q,
          );
          return 0;
        });

        final result = sut.base(
          n: SecureKeyFake.empty(10),
        );

        expect(result, q);

        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_scalarmult_base(
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut.base(
            n: SecureKeyFake.empty(10),
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(2);
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

        verify(() => mockSodium.crypto_scalarmult_scalarbytes());
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
          () => mockSodium.crypto_scalarmult_scalarbytes(),
          () => mockSodium.crypto_scalarmult_bytes(),
        ]);
      });

      test('calls crypto_scalarmult with correct arguments', () {
        when(
          () => mockSodium.crypto_scalarmult(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final n = List.generate(10, (index) => index);
        final p = List.generate(5, (index) => index * 2);

        sut(
          n: SecureKeyFake(n),
          p: Uint8List.fromList(p),
        );

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(p)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(n)),
              ),
          () => mockSodium.crypto_scalarmult(
                any(that: isNot(nullptr)),
                any(that: hasRawData<UnsignedChar>(n)),
                any(that: hasRawData<UnsignedChar>(p)),
              ),
        ]);
      });

      test('returns shared key data', () {
        final q = List.generate(5, (index) => 100 - index);
        when(
          () => mockSodium.crypto_scalarmult(
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(
            i.positionalArguments.first as Pointer<UnsignedChar>,
            q,
          );
          return 0;
        });

        final result = sut(
          n: SecureKeyFake.empty(10),
          p: Uint8List(5),
        );

        expect(result.extractBytes(), q);

        verify(() => mockSodium.sodium_free(any())).called(2);
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
          () => sut(
            n: SecureKeyFake.empty(10),
            p: Uint8List(5),
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(3);
      });
    });
  });
}
