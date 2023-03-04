// ignore_for_file: unnecessary_lambdas

@TestOn('dart-vm')
library kdf_ffi_test;

import 'dart:ffi';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/api/string_x.dart';
import 'package:sodium/src/ffi/api/kdf_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';
import '../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  late KdfFFI sut;

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);

    mockAllocArray(mockSodium);

    sut = KdfFFI(mockSodium);
  });

  testConstantsMapping([
    Tuple3(
      () => mockSodium.crypto_kdf_bytes_min(),
      () => sut.bytesMin,
      'bytesMin',
    ),
    Tuple3(
      () => mockSodium.crypto_kdf_bytes_max(),
      () => sut.bytesMax,
      'bytesMax',
    ),
    Tuple3(
      () => mockSodium.crypto_kdf_contextbytes(),
      () => sut.contextBytes,
      'contextBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_kdf_keybytes(),
      () => sut.keyBytes,
      'keyBytes',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_kdf_bytes_min()).thenReturn(5);
      when(() => mockSodium.crypto_kdf_bytes_max()).thenReturn(15);
      when(() => mockSodium.crypto_kdf_contextbytes()).thenReturn(5);
      when(() => mockSodium.crypto_kdf_keybytes()).thenReturn(5);
    });

    testKeygen(
      mockSodium: mockSodium,
      runKeygen: () => sut.keygen(),
      keyBytesNative: mockSodium.crypto_kdf_keybytes,
      keygenNative: mockSodium.crypto_kdf_keygen,
    );

    group('deriveFromKey', () {
      test('asserts if masterKey is invalid', () {
        expect(
          () => sut.deriveFromKey(
            masterKey: SecureKeyFake.empty(10),
            context: 'X' * 5,
            subkeyId: 0,
            subkeyLen: 10,
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_kdf_keybytes());
      });

      test('asserts if context is invalid', () {
        expect(
          () => sut.deriveFromKey(
            masterKey: SecureKeyFake.empty(5),
            context: 'X' * 10,
            subkeyId: 0,
            subkeyLen: 10,
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_kdf_contextbytes());
      });

      test('asserts if subkeyLen is invalid', () {
        expect(
          () => sut.deriveFromKey(
            masterKey: SecureKeyFake.empty(5),
            context: 'X' * 5,
            subkeyId: 0,
            subkeyLen: 20,
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_kdf_bytes_min());
        verify(() => mockSodium.crypto_kdf_bytes_max());
      });

      test('calls crypto_kdf_derive_from_key with correct arguments', () {
        when(
          () => mockSodium.crypto_kdf_derive_from_key(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final masterKey = List.generate(5, (index) => index * 2);
        const context = 'TEST';
        const subkeyId = 42;
        const subkeyLen = 10;

        sut.deriveFromKey(
          masterKey: SecureKeyFake(masterKey),
          context: context,
          subkeyId: subkeyId,
          subkeyLen: subkeyLen,
        );

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(context.toCharArray(memoryWidth: 5))),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(masterKey)),
              ),
          () => mockSodium.crypto_kdf_derive_from_key(
                any(that: isNot(nullptr)),
                subkeyLen,
                subkeyId,
                any(
                  that: hasRawData<Char>(context.toCharArray(memoryWidth: 5)),
                ),
                any(that: hasRawData<UnsignedChar>(masterKey)),
              ),
        ]);
      });

      test('returns derieved key', () {
        final subkey = List.generate(10, (index) => 100 - index);
        when(
          () => mockSodium.crypto_kdf_derive_from_key(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments.first as Pointer, subkey);
          return 0;
        });

        final result = sut.deriveFromKey(
          masterKey: SecureKeyFake.empty(5),
          context: 'test',
          subkeyId: 0,
          subkeyLen: 10,
        );

        expect(result.extractBytes(), subkey);

        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_kdf_derive_from_key(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut.deriveFromKey(
            masterKey: SecureKeyFake.empty(5),
            context: 'test',
            subkeyId: 0,
            subkeyLen: 10,
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(3);
      });
    });
  });
}
