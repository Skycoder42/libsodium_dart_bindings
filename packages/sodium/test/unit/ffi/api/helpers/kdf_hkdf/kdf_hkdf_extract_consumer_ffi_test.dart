// ignore_for_file: unnecessary_lambdas for mocking

@TestOn('dart-vm')
library;

import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/helpers/kdf_hkdf/kdf_hkdf_extract_consumer_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart'
    show crypto_kdf_hkdf_sha256_state;
import 'package:sodium/src/ffi/bindings/libsodium.ffi.wrapper.dart';
import 'package:test/test.dart';

import '../../../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  const keyBytes = 15;
  const stateBytes = 5;

  final mockSodium = MockSodiumFFI();

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);

    mockAllocArray(mockSodium);
  });

  KdfHkdfExtractConsumerFFI<crypto_kdf_hkdf_sha256_state> createSut({
    Uint8List? salt,
  }) => KdfHkdfExtractConsumerFFI<crypto_kdf_hkdf_sha256_state>(
    sodium: mockSodium,
    keyBytes: keyBytes,
    stateBytes: stateBytes,
    extractInit: mockSodium.crypto_kdf_hkdf_sha256_extract_init,
    extractUpdate: mockSodium.crypto_kdf_hkdf_sha256_extract_update,
    extractFinal: mockSodium.crypto_kdf_hkdf_sha256_extract_final,
    salt: salt,
  );

  group('constructor', () {
    test('initializes extract state', () {
      late Pointer state;
      when(
        () =>
            mockSodium.crypto_kdf_hkdf_sha256_extract_init(any(), any(), any()),
      ).thenCapture(0, (p) => state = p);

      createSut();

      verifyInOrder([
        () => mockSodium.sodium_allocarray(stateBytes, 1),
        () => mockSodium.sodium_memzero(any(that: isNot(nullptr)), stateBytes),
        () => mockSodium.crypto_kdf_hkdf_sha256_extract_init(
          any(that: hasAddress(state.address)),
          any(that: equals(nullptr)),
          0,
        ),
        () => mockSodium.sodium_mprotect_noaccess(
          any(that: hasAddress(state.address)),
        ),
      ]);
    });

    test('initializes extract state with salt', () {
      late Pointer state;
      when(
        () =>
            mockSodium.crypto_kdf_hkdf_sha256_extract_init(any(), any(), any()),
      ).thenCapture(0, (p) => state = p);

      final salt = List.generate(8, (index) => index + 1);

      createSut(salt: Uint8List.fromList(salt));

      verifyInOrder([
        () => mockSodium.sodium_allocarray(stateBytes, 1),
        () => mockSodium.sodium_memzero(any(that: isNot(nullptr)), stateBytes),
        () => mockSodium.sodium_mprotect_readonly(any(that: hasRawData(salt))),
        () => mockSodium.crypto_kdf_hkdf_sha256_extract_init(
          any(that: hasAddress(state.address)),
          any(that: hasRawData<UnsignedChar>(salt)),
          salt.length,
        ),
        () => mockSodium.sodium_mprotect_noaccess(
          any(that: hasAddress(state.address)),
        ),
        () => mockSodium.sodium_free(any(that: hasRawData(salt))),
      ]);
    });

    test('disposes state on error', () {
      when(
        () =>
            mockSodium.crypto_kdf_hkdf_sha256_extract_init(any(), any(), any()),
      ).thenReturn(1);

      expect(createSut, throwsA(isA<SodiumException>()));

      verify(() => mockSodium.sodium_free(any(that: isNot(nullptr))));
    });
  });

  group('members', () {
    late KdfHkdfExtractConsumerFFI<crypto_kdf_hkdf_sha256_state> sut;

    setUp(() {
      when(
        () =>
            mockSodium.crypto_kdf_hkdf_sha256_extract_init(any(), any(), any()),
      ).thenReturn(0);

      sut = createSut();

      clearInteractions(mockSodium);
    });

    group('add', () {
      test(
        'calls crypto_kdf_hkdf_sha256_extract_update with the given data',
        () {
          late Pointer state;
          when(
            () => mockSodium.crypto_kdf_hkdf_sha256_extract_update(
              any(),
              any(),
              any(),
            ),
          ).thenCapture(0, (p) => state = p);

          final ikm = List.generate(25, (index) => index * 3);

          sut.add(Uint8List.fromList(ikm));

          verifyInOrder([
            () =>
                mockSodium.sodium_mprotect_readonly(any(that: hasRawData(ikm))),
            () => mockSodium.sodium_mprotect_readwrite(
              any(that: hasAddress(state.address)),
            ),
            () => mockSodium.crypto_kdf_hkdf_sha256_extract_update(
              any(that: hasAddress(state.address)),
              any(that: hasRawData<UnsignedChar>(ikm)),
              ikm.length,
            ),
            () => mockSodium.sodium_mprotect_noaccess(
              any(that: hasAddress(state.address)),
            ),
            () => mockSodium.sodium_free(any(that: hasRawData(ikm))),
          ]);
        },
      );

      test('throws StateError when adding data after completition', () async {
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_final(any(), any()),
        ).thenReturn(0);

        await sut.close();

        expect(() => sut.add(Uint8List(0)), throwsA(isA<StateError>()));
      });
    });

    group('addStream', () {
      test(
        'calls crypto_kdf_hkdf_sha256_extract_update on stream events',
        () async {
          late Pointer state;
          when(
            () => mockSodium.crypto_kdf_hkdf_sha256_extract_update(
              any(),
              any(),
              any(),
            ),
          ).thenCapture(0, (p) => state = p);

          final ikm = List.generate(25, (index) => index * 3);

          await sut.addStream(Stream.value(Uint8List.fromList(ikm)));

          verifyInOrder([
            () =>
                mockSodium.sodium_mprotect_readonly(any(that: hasRawData(ikm))),
            () => mockSodium.sodium_mprotect_readwrite(
              any(that: hasAddress(state.address)),
            ),
            () => mockSodium.crypto_kdf_hkdf_sha256_extract_update(
              any(that: hasAddress(state.address)),
              any(that: hasRawData<UnsignedChar>(ikm)),
              ikm.length,
            ),
            () => mockSodium.sodium_mprotect_noaccess(
              any(that: hasAddress(state.address)),
            ),
            () => mockSodium.sodium_free(any(that: hasRawData(ikm))),
          ]);
        },
      );

      test('throws exception and cancels addStream on error', () async {
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_update(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        final ikm = List.generate(25, (index) => index * 3);

        await expectLater(
          () => sut.addStream(Stream.value(Uint8List.fromList(ikm))),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any(that: hasRawData(ikm))));
      });

      test(
        'throws StateError when adding a stream after completition',
        () async {
          when(
            () => mockSodium.crypto_kdf_hkdf_sha256_extract_final(any(), any()),
          ).thenReturn(0);

          await sut.close();

          expect(
            () => sut.addStream(const Stream.empty()),
            throwsA(isA<StateError>()),
          );
        },
      );
    });

    group('close', () {
      test(
        'calls crypto_kdf_hkdf_sha256_extract_final with correct arguments',
        () async {
          late Pointer state;
          when(
            () => mockSodium.crypto_kdf_hkdf_sha256_extract_final(any(), any()),
          ).thenCapture(0, (p) => state = p);

          await sut.close();

          verifyInOrder([
            () => mockSodium.sodium_allocarray(keyBytes, 1),
            () => mockSodium.sodium_mprotect_readwrite(
              any(that: hasAddress(state.address)),
            ),
            () => mockSodium.crypto_kdf_hkdf_sha256_extract_final(
              any(that: hasAddress(state.address)),
              any(that: isNot(nullptr)),
            ),
            () => mockSodium.sodium_free(any(that: hasAddress(state.address))),
          ]);
        },
      );

      test('returns extracted master key on success', () async {
        final prk = List.generate(keyBytes, (index) => index * 2);

        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_final(any(), any()),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments[1] as Pointer, prk);
          return 0;
        });

        final result = await sut.close();

        expect(result.extractBytes(), prk);
        verify(() => mockSodium.sodium_free(any())).called(1);
      });

      test('throws exception if extraction fails', () async {
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_final(any(), any()),
        ).thenReturn(1);

        await expectLater(() => sut.close(), throwsA(isA<SodiumException>()));

        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test('throws state error if close is called a second time', () async {
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_final(any(), any()),
        ).thenReturn(0);

        await sut.close();

        await expectLater(() => sut.close(), throwsA(isA<StateError>()));
      });

      test('returns same future as masterKey', () async {
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_final(any(), any()),
        ).thenReturn(0);

        final masterKey = sut.masterKey;
        final closed = sut.close();

        expect(closed, masterKey);
        expect(await masterKey, await closed);
      });
    });
  });
}
