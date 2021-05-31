import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/short_hash_ffi.dart';
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

  late ShortHashFFI sut;

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);

    mockAllocArray(mockSodium);

    sut = ShortHashFFI(mockSodium);
  });

  testConstantsMapping([
    Tuple3(
      () => mockSodium.crypto_shorthash_bytes(),
      () => sut.bytes,
      'bytes',
    ),
    Tuple3(
      () => mockSodium.crypto_shorthash_keybytes(),
      () => sut.keyBytes,
      'keyBytes',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_shorthash_bytes()).thenReturn(5);
      when(() => mockSodium.crypto_shorthash_keybytes()).thenReturn(5);
    });

    testKeygen(
      mockSodium: mockSodium,
      runKeygen: () => sut.keygen(),
      keyBytesNative: mockSodium.crypto_shorthash_keybytes,
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

        verify(() => mockSodium.crypto_shorthash_keybytes());
      });

      test('calls crypto_generichash with correct arguments', () {
        when(
          () => mockSodium.crypto_shorthash(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final key = List.generate(5, (index) => index * 10);
        final message = List.generate(20, (index) => index * 2);

        sut(
          message: Uint8List.fromList(message),
          key: SecureKeyFake(key),
        );

        verifyInOrder([
          () => mockSodium.sodium_allocarray(5, 1),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(message)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(key)),
              ),
          () => mockSodium.crypto_shorthash(
                any(that: isNot(nullptr)),
                any(that: hasRawData<Uint8>(message)),
                message.length,
                any(that: hasRawData<Uint8>(key)),
              ),
        ]);
      });

      test('returns calculated hash', () {
        final hash = List.generate(5, (index) => 10 + index);
        when(
          () => mockSodium.crypto_shorthash(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments.first as Pointer, hash);
          return 0;
        });

        final result = sut(
          message: Uint8List(10),
          key: SecureKeyFake.empty(5),
        );

        expect(result, hash);

        verify(() => mockSodium.sodium_free(any())).called(3);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_shorthash(
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
  });
}
