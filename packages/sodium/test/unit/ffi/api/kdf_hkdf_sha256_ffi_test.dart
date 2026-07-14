// ignore_for_file: unnecessary_lambdas for mocking

@TestOn('dart-vm')
library;

import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/api/string_x.dart';
import 'package:sodium/src/ffi/api/helpers/kdf_hkdf/kdf_hkdf_extract_consumer_ffi.dart';
import 'package:sodium/src/ffi/api/kdf_hkdf_sha256_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.wrapper.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';
import '../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  late KdfHkdfSha256FFI sut;

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);

    mockAllocArray(mockSodium);

    sut = KdfHkdfSha256FFI(mockSodium);
  });

  testConstantsMapping([
    (
      () => mockSodium.crypto_kdf_hkdf_sha256_keybytes(),
      () => sut.keyBytes,
      'keyBytes',
    ),
    (
      () => mockSodium.crypto_kdf_hkdf_sha256_bytes_min(),
      () => sut.bytesMin,
      'bytesMin',
    ),
    (
      () => mockSodium.crypto_kdf_hkdf_sha256_bytes_max(),
      () => sut.bytesMax,
      'bytesMax',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_kdf_hkdf_sha256_keybytes()).thenReturn(5);
      when(() => mockSodium.crypto_kdf_hkdf_sha256_bytes_min()).thenReturn(5);
      when(() => mockSodium.crypto_kdf_hkdf_sha256_bytes_max()).thenReturn(15);
      when(() => mockSodium.crypto_kdf_hkdf_sha256_statebytes()).thenReturn(5);
    });

    testKeygen(
      mockSodium: mockSodium,
      runKeygen: () => sut.keygen(),
      keyBytesNative: mockSodium.crypto_kdf_hkdf_sha256_keybytes,
      keygenNative: mockSodium.crypto_kdf_hkdf_sha256_keygen,
    );

    group('extract', () {
      test('calls crypto_kdf_hkdf_sha256_extract with correct arguments', () {
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final salt = List.generate(8, (index) => index + 1);
        final ikm = List.generate(10, (index) => index * 2);

        sut.extract(
          salt: Uint8List.fromList(salt),
          ikm: Uint8List.fromList(ikm),
        );

        verifyInOrder([
          () =>
              mockSodium.sodium_mprotect_readonly(any(that: hasRawData(salt))),
          () => mockSodium.sodium_mprotect_readonly(any(that: hasRawData(ikm))),
          () => mockSodium.crypto_kdf_hkdf_sha256_extract(
            any(that: isNot(nullptr)),
            any(that: hasRawData<UnsignedChar>(salt)),
            salt.length,
            any(that: hasRawData<UnsignedChar>(ikm)),
            ikm.length,
          ),
        ]);
      });

      test('passes nullptr as salt when salt is null', () {
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final ikm = List.generate(10, (index) => index * 2);

        sut.extract(ikm: Uint8List.fromList(ikm));

        verify(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract(
            any(that: isNot(nullptr)),
            any(that: equals(nullptr)),
            0,
            any(that: hasRawData<UnsignedChar>(ikm)),
            ikm.length,
          ),
        );
      });

      test('returns extracted master key', () {
        final prk = List.generate(5, (index) => 100 - index);

        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments[0] as Pointer, prk);
          return 0;
        });

        final result = sut.extract(
          salt: Uint8List.fromList(List.generate(8, (index) => index)),
          ikm: Uint8List.fromList(List.generate(10, (index) => index)),
        );

        expect(result.extractBytes(), prk);

        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test('throws if crypto_kdf_hkdf_sha256_extract fails', () {
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut.extract(
            salt: Uint8List.fromList(List.generate(8, (index) => index)),
            ikm: Uint8List.fromList(List.generate(10, (index) => index)),
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(3);
      });
    });

    group('expand', () {
      test('asserts if masterKey is invalid', () {
        expect(
          () => sut.expand(
            masterKey: SecureKeyFake.empty(10),
            context: 'test',
            outLen: 10,
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_kdf_hkdf_sha256_keybytes());
      });

      test('asserts if outLen is invalid', () {
        expect(
          () => sut.expand(
            masterKey: SecureKeyFake.empty(5),
            context: 'test',
            outLen: 20,
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_kdf_hkdf_sha256_bytes_min());
        verify(() => mockSodium.crypto_kdf_hkdf_sha256_bytes_max());
      });

      test('calls crypto_kdf_hkdf_sha256_expand with correct arguments', () {
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_expand(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final masterKey = List.generate(5, (index) => index + 10);
        const context = 'TEST';
        const outLen = 10;

        sut.expand(
          masterKey: SecureKeyFake(masterKey),
          context: context,
          outLen: outLen,
        );

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
            any(that: hasRawData(context.toCharArray())),
          ),
          () => mockSodium.sodium_mprotect_readonly(
            any(that: hasRawData(masterKey)),
          ),
          () => mockSodium.crypto_kdf_hkdf_sha256_expand(
            any(that: isNot(nullptr)),
            outLen,
            any(that: hasRawData<Char>(context.toCharArray())),
            context.length,
            any(that: hasRawData<UnsignedChar>(masterKey)),
          ),
        ]);
      });

      test('returns expanded subkey', () {
        final subkey = List.generate(10, (index) => 100 - index);

        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_expand(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments[0] as Pointer, subkey);
          return 0;
        });

        final result = sut.expand(
          masterKey: SecureKeyFake.empty(5),
          context: 'test',
          outLen: 10,
        );

        expect(result.extractBytes(), subkey);

        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test('throws if crypto_kdf_hkdf_sha256_expand fails', () {
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_expand(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut.expand(
            masterKey: SecureKeyFake.empty(5),
            context: 'test',
            outLen: 10,
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(3);
      });
    });

    group('createExtractConsumer', () {
      test('returns KdfHkdfExtractConsumerFFI and wires extract_init', () {
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_init(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final result = sut.createExtractConsumer();

        expect(result, isA<KdfHkdfExtractConsumerFFI>());
        verify(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_init(
            any(that: isNot(nullptr)),
            any(that: equals(nullptr)),
            0,
          ),
        );
      });
    });

    group('extractStream', () {
      test('extracts master key using the incremental sha256 apis', () async {
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_init(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_update(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final prk = List.generate(5, (index) => index + 50);
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_final(any(), any()),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments[1] as Pointer, prk);
          return 0;
        });

        final ikm = List.generate(10, (index) => index * 2);

        final result = await sut.extractStream(
          ikm: Stream.value(Uint8List.fromList(ikm)),
        );

        expect(result.extractBytes(), prk);

        verifyInOrder([
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_init(
            any(that: isNot(nullptr)),
            any(that: equals(nullptr)),
            0,
          ),
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_update(
            any(that: isNot(nullptr)),
            any(that: hasRawData<UnsignedChar>(ikm)),
            ikm.length,
          ),
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_final(
            any(that: isNot(nullptr)),
            any(that: isNot(nullptr)),
          ),
        ]);
      });
    });
  });
}
