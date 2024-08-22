// ignore_for_file: unnecessary_lambdas

@TestOn('dart-vm')
library;

import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/generic_hash_ffi.dart';
import 'package:sodium/src/ffi/api/helpers/generic_hash/generic_hash_consumer_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';
import '../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  late GenericHashFFI sut;

  setUpAll(() {
    registerPointers();
    registerFallbackValue(nullptr);
  });

  setUp(() {
    reset(mockSodium);

    mockAllocArray(mockSodium);

    sut = GenericHashFFI(mockSodium);
  });

  testConstantsMapping([
    (
      () => mockSodium.crypto_generichash_bytes(),
      () => sut.bytes,
      'bytes',
    ),
    (
      () => mockSodium.crypto_generichash_bytes_min(),
      () => sut.bytesMin,
      'bytesMin',
    ),
    (
      () => mockSodium.crypto_generichash_bytes_max(),
      () => sut.bytesMax,
      'bytesMax',
    ),
    (
      () => mockSodium.crypto_generichash_keybytes(),
      () => sut.keyBytes,
      'keyBytes',
    ),
    (
      () => mockSodium.crypto_generichash_keybytes_min(),
      () => sut.keyBytesMin,
      'keyBytesMin',
    ),
    (
      () => mockSodium.crypto_generichash_keybytes_max(),
      () => sut.keyBytesMax,
      'keyBytesMax',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_generichash_bytes_min()).thenReturn(5);
      when(() => mockSodium.crypto_generichash_bytes_max()).thenReturn(5);
      when(() => mockSodium.crypto_generichash_keybytes_min()).thenReturn(5);
      when(() => mockSodium.crypto_generichash_keybytes_max()).thenReturn(5);
      when(() => mockSodium.crypto_generichash_statebytes()).thenReturn(10);
    });

    testKeygen(
      mockSodium: mockSodium,
      runKeygen: () => sut.keygen(),
      keyBytesNative: mockSodium.crypto_generichash_keybytes,
      keygenNative: mockSodium.crypto_generichash_keygen,
    );

    group('call', () {
      test('asserts if outLen is invalid', () {
        expect(
          () => sut(
            message: Uint8List(0),
            outLen: 10,
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_generichash_bytes_min());
        verify(() => mockSodium.crypto_generichash_bytes_max());
      });

      test('asserts if key is invalid', () {
        expect(
          () => sut(
            message: Uint8List(0),
            key: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_generichash_keybytes_min());
        verify(() => mockSodium.crypto_generichash_keybytes_max());
      });

      test('calls crypto_generichash with correct defaults', () {
        const hashBytes = 15;
        when(() => mockSodium.crypto_generichash_bytes()).thenReturn(hashBytes);
        when(
          () => mockSodium.crypto_generichash(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final message = List.generate(20, (index) => index * 2);

        sut(message: Uint8List.fromList(message));

        verifyInOrder([
          () => mockSodium.sodium_allocarray(hashBytes, 1),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(message)),
              ),
          () => mockSodium.crypto_generichash(
                any(that: isNot(nullptr)),
                hashBytes,
                any(that: hasRawData<UnsignedChar>(message)),
                message.length,
                any(that: equals(nullptr)),
                0,
              ),
        ]);
      });

      test('calls crypto_generichash with all arguments', () {
        when(
          () => mockSodium.crypto_generichash(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        const outLen = 5;
        final key = List.generate(5, (index) => index * 10);
        final message = List.generate(20, (index) => index * 2);

        sut(
          message: Uint8List.fromList(message),
          outLen: outLen,
          key: SecureKeyFake(key),
        );

        verifyInOrder([
          () => mockSodium.sodium_allocarray(outLen, 1),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(message)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(key)),
              ),
          () => mockSodium.crypto_generichash(
                any(that: isNot(nullptr)),
                outLen,
                any(that: hasRawData<UnsignedChar>(message)),
                message.length,
                any(that: hasRawData<UnsignedChar>(key)),
                key.length,
              ),
        ]);
      });

      test('returns calculated default hash', () {
        final hash = List.generate(25, (index) => 10 + index);
        when(() => mockSodium.crypto_generichash_bytes())
            .thenReturn(hash.length);
        when(
          () => mockSodium.crypto_generichash(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(
            i.positionalArguments.first as Pointer<UnsignedChar>,
            hash,
          );
          return 0;
        });

        final result = sut(message: Uint8List(10));

        expect(result, hash);

        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test('returns calculated custom hash', () {
        final hash = List.generate(5, (index) => 10 + index);
        when(
          () => mockSodium.crypto_generichash(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(
            i.positionalArguments.first as Pointer<UnsignedChar>,
            hash,
          );
          return 0;
        });

        final result = sut(
          message: Uint8List(10),
          outLen: hash.length,
          key: SecureKeyFake.empty(5),
        );

        expect(result, hash);

        verify(() => mockSodium.sodium_free(any())).called(3);
      });

      test('throws exception on failure', () {
        when(() => mockSodium.crypto_generichash_bytes()).thenReturn(10);
        when(
          () => mockSodium.crypto_generichash(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut(
            message: Uint8List(15),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(3);
      });
    });

    group('createConsumer', () {
      test('asserts if outLen is invalid', () {
        expect(
          () => sut.createConsumer(
            outLen: 10,
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_generichash_bytes_min());
        verify(() => mockSodium.crypto_generichash_bytes_max());
      });

      test('asserts if key is invalid', () {
        expect(
          () => sut.createConsumer(
            key: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_generichash_keybytes_min());
        verify(() => mockSodium.crypto_generichash_keybytes_max());
      });

      test('returns GenericHashConsumerFFI with defaults', () {
        const outLen = 55;
        when(() => mockSodium.crypto_generichash_bytes()).thenReturn(outLen);
        when(
          () => mockSodium.crypto_generichash_init(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final result = sut.createConsumer();

        expect(
          result,
          isA<GenericHashConsumerFFI>()
              .having((c) => c.sodium, 'sodium', mockSodium)
              .having(
                (c) => c.outLen,
                'outLen',
                outLen,
              ),
        );
      });

      test('returns GenericHashConsumerFFI with key', () {
        when(
          () => mockSodium.crypto_generichash_init(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        const outLen = 5;
        final secretKey = List.generate(5, (index) => index * index);

        final result = sut.createConsumer(
          outLen: outLen,
          key: SecureKeyFake(secretKey),
        );

        expect(
          result,
          isA<GenericHashConsumerFFI>()
              .having((c) => c.sodium, 'sodium', mockSodium)
              .having(
                (c) => c.outLen,
                'outLen',
                outLen,
              ),
        );
      });
    });
  });
}
