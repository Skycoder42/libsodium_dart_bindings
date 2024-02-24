// ignore_for_file: unnecessary_lambdas

@TestOn('dart-vm')
library sign_sumo_ffi_test;

import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/sumo/sign_sumo_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';

import '../../../../secure_key_fake.dart';
import '../../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  late SignSumoFFI sut;

  setUpAll(() {
    registerPointers();
    registerFallbackValue(nullptr);
  });

  setUp(() {
    reset(mockSodium);

    mockAllocArray(mockSodium);

    sut = SignSumoFFI(mockSodium);
  });

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_sign_publickeybytes()).thenReturn(5);
      when(() => mockSodium.crypto_sign_secretkeybytes()).thenReturn(5);
      when(() => mockSodium.crypto_sign_seedbytes()).thenReturn(5);
    });

    group('skToSeed', () {
      test('asserts if secretKey is invalid', () {
        expect(
          () => sut.skToSeed(SecureKeyFake.empty(10)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_secretkeybytes());
      });

      test('calls crypto_sign_ed25519_sk_to_seed with correct arguments', () {
        when(
          () => mockSodium.crypto_sign_ed25519_sk_to_seed(
            any(),
            any(),
          ),
        ).thenReturn(0);

        final secretKey = List.generate(5, (index) => 30 + index);

        sut.skToSeed(SecureKeyFake(secretKey));

        verifyInOrder([
          () => mockSodium.sodium_allocarray(5, 1),
          () => mockSodium.sodium_mprotect_readwrite(any(that: isNot(nullptr))),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(secretKey)),
              ),
          () => mockSodium.crypto_sign_ed25519_sk_to_seed(
                any(that: isNot(nullptr)),
                any(that: hasRawData<UnsignedChar>(secretKey)),
              ),
          () => mockSodium.sodium_mprotect_noaccess(any(that: isNot(nullptr))),
        ]);
      });

      test('returns seed of the secret key', () {
        final seed = List.generate(5, (index) => 100 - index);
        when(
          () => mockSodium.crypto_sign_ed25519_sk_to_seed(
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments.first as Pointer, seed);
          return 0;
        });

        final result = sut.skToSeed(SecureKeyFake.empty(5));

        expect(result.extractBytes(), seed);

        verify(() => mockSodium.sodium_free(any())).called(1);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_sign_ed25519_sk_to_seed(
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut.skToSeed(SecureKeyFake.empty(5)),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(2);
      });
    });

    group('skToPk', () {
      test('asserts if secretKey is invalid', () {
        expect(
          () => sut.skToPk(SecureKeyFake.empty(10)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_secretkeybytes());
      });

      test('calls crypto_sign_ed25519_sk_to_pk with correct arguments', () {
        when(
          () => mockSodium.crypto_sign_ed25519_sk_to_pk(
            any(),
            any(),
          ),
        ).thenReturn(0);

        final secretKey = List.generate(5, (index) => 30 + index);

        sut.skToPk(SecureKeyFake(secretKey));

        verifyInOrder([
          () => mockSodium.sodium_allocarray(5, 1),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(secretKey)),
              ),
          () => mockSodium.crypto_sign_ed25519_sk_to_pk(
                any(that: isNot(nullptr)),
                any(that: hasRawData<UnsignedChar>(secretKey)),
              ),
        ]);
      });

      test('returns the public key of the secret key', () {
        final publicKey = List.generate(5, (index) => 100 - index);
        when(
          () => mockSodium.crypto_sign_ed25519_sk_to_pk(
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments.first as Pointer, publicKey);
          return 0;
        });

        final result = sut.skToPk(SecureKeyFake.empty(5));

        expect(result, publicKey);

        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_sign_ed25519_sk_to_pk(
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut.skToPk(SecureKeyFake.empty(5)),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(2);
      });
    });

    group('pkToCurve25519', () {
      test('asserts if publicKey is invalid', () {
        expect(
          () => sut.pkToCurve25519(Uint8List.fromList(const [])),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_publickeybytes());
      });

      test('calls crypto_sign_ed25519_pk_to_curve25519 with correct arguments',
          () {
        when(
          () => mockSodium.crypto_sign_ed25519_pk_to_curve25519(
            any(),
            any(),
          ),
        ).thenReturn(0);

        final publicKey = Uint8List.fromList(
          List.generate(5, (index) => 30 + index),
        );

        sut.pkToCurve25519(publicKey);

        verifyInOrder([
          () => mockSodium.sodium_allocarray(5, 1),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(publicKey)),
              ),
          () => mockSodium.crypto_sign_ed25519_pk_to_curve25519(
                any(that: isNot(nullptr)),
                any(that: hasRawData<UnsignedChar>(publicKey)),
              ),
        ]);
      });

      test('returns the curve25519 public key of the ed25519 public key', () {
        final curve25519PublicKey = Uint8List.fromList(
          List.generate(5, (index) => 30 + index),
        );
        when(
          () => mockSodium.crypto_sign_ed25519_pk_to_curve25519(
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(
            i.positionalArguments.first as Pointer,
            curve25519PublicKey,
          );
          return 0;
        });

        final result = sut.pkToCurve25519(curve25519PublicKey);

        expect(result, curve25519PublicKey);

        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_sign_ed25519_pk_to_curve25519(
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut.pkToCurve25519(
            Uint8List.fromList(List.generate(5, (index) => 30 + index)),
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(2);
      });
    });

    group('skToCurve25519', () {
      test('asserts if secretKey is invalid', () {
        expect(
          () => sut.skToCurve25519(SecureKeyFake.empty(10)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_sign_secretkeybytes());
      });

      test('calls crypto_sign_ed25519_sk_to_curve25519 with correct arguments',
          () {
        when(
          () => mockSodium.crypto_sign_ed25519_sk_to_curve25519(
            any(),
            any(),
          ),
        ).thenReturn(0);

        final secretKey = List.generate(5, (index) => 30 + index);

        sut.skToCurve25519(SecureKeyFake(secretKey));

        verifyInOrder([
          () => mockSodium.sodium_allocarray(5, 1),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(secretKey)),
              ),
          () => mockSodium.crypto_sign_ed25519_sk_to_curve25519(
                any(that: isNot(nullptr)),
                any(that: hasRawData<UnsignedChar>(secretKey)),
              ),
        ]);
      });

      test('returns the public key of the secret key', () {
        final publicKey = List.generate(5, (index) => 100 - index);
        when(
          () => mockSodium.crypto_sign_ed25519_sk_to_curve25519(
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments.first as Pointer, publicKey);
          return 0;
        });

        final result = sut.skToCurve25519(SecureKeyFake.empty(5));

        expect(result, publicKey);

        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_sign_ed25519_sk_to_curve25519(
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut.skToCurve25519(SecureKeyFake.empty(5)),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(2);
      });
    });
  });
}
