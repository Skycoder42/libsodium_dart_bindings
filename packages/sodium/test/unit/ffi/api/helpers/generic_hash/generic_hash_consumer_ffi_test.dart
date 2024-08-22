// ignore_for_file: unnecessary_lambdas

@TestOn('dart-vm')
library;

import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/helpers/generic_hash/generic_hash_consumer_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';

import '../../../../../secure_key_fake.dart';
import '../../../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  const outLen = 42;

  final mockSodium = MockSodiumFFI();

  setUpAll(() {
    registerPointers();
    registerFallbackValue(nullptr);
  });

  setUp(() {
    reset(mockSodium);

    mockAllocArray(mockSodium);

    when(() => mockSodium.crypto_generichash_statebytes()).thenReturn(5);
    when(() => mockSodium.crypto_generichash_keybytes()).thenReturn(15);
  });

  group('constructor', () {
    test('initializes hash state', () {
      when(
        () => mockSodium.crypto_generichash_init(
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenReturn(0);

      GenericHashConsumerFFI(
        sodium: mockSodium,
        outLen: outLen,
      );

      verifyInOrder([
        () => mockSodium.crypto_generichash_statebytes(),
        () => mockSodium.sodium_allocarray(5, 1),
        () => mockSodium.sodium_memzero(any(that: isNot(nullptr)), 5),
        () => mockSodium.crypto_generichash_init(
              any(that: isNot(nullptr)),
              any(that: equals(nullptr)),
              0,
              outLen,
            ),
      ]);
    });

    test('initializes hash state with key', () {
      when(
        () => mockSodium.crypto_generichash_init(
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenReturn(0);

      final key = List.generate(15, (index) => index + 5);

      GenericHashConsumerFFI(
        sodium: mockSodium,
        outLen: outLen,
        key: SecureKeyFake(key),
      );

      verifyInOrder([
        () => mockSodium.crypto_generichash_statebytes(),
        () => mockSodium.sodium_allocarray(5, 1),
        () => mockSodium.sodium_memzero(any(that: isNot(nullptr)), 5),
        () => mockSodium.sodium_mprotect_readonly(any(that: hasRawData(key))),
        () => mockSodium.crypto_generichash_init(
              any(that: isNot(nullptr)),
              any(that: hasRawData<UnsignedChar>(key)),
              key.length,
              outLen,
            ),
      ]);
    });

    test('disposes sign state on error', () {
      when(
        () => mockSodium.crypto_generichash_init(
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenReturn(1);

      expect(
        () => GenericHashConsumerFFI(
          sodium: mockSodium,
          outLen: outLen,
        ),
        throwsA(isA<SodiumException>()),
      );

      verifyInOrder([
        () => mockSodium.crypto_generichash_statebytes(),
        () => mockSodium.sodium_allocarray(5, 1),
        () => mockSodium.sodium_memzero(any(that: isNot(nullptr)), 5),
        () => mockSodium.crypto_generichash_init(
              any(that: isNot(nullptr)),
              any(that: equals(nullptr)),
              0,
              outLen,
            ),
        () => mockSodium.sodium_free(any(that: isNot(nullptr))),
      ]);
    });
  });

  group('members', () {
    late GenericHashConsumerFFI sut;

    setUp(() {
      when(
        () => mockSodium.crypto_generichash_init(
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenReturn(0);

      sut = GenericHashConsumerFFI(
        sodium: mockSodium,
        outLen: outLen,
      );

      clearInteractions(mockSodium);
    });

    group('add', () {
      test('calls crypto_generichash_update with the given data', () {
        when(() => mockSodium.crypto_generichash_update(any(), any(), any()))
            .thenReturn(0);

        final message = List.generate(25, (index) => index * 3);

        sut.add(Uint8List.fromList(message));

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(message)),
              ),
          () => mockSodium.crypto_generichash_update(
                any(that: isNot(nullptr)),
                any(that: hasRawData<UnsignedChar>(message)),
                message.length,
              ),
          () => mockSodium.sodium_free(
                any(that: hasRawData(message)),
              ),
        ]);
      });

      test('throws StateError when adding data after completition', () async {
        when(() => mockSodium.crypto_generichash_final(any(), any(), any()))
            .thenReturn(0);

        await sut.close();

        expect(
          () => sut.add(Uint8List(0)),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('addStream', () {
      test('calls crypto_generichash_update on stream events', () async {
        when(() => mockSodium.crypto_generichash_update(any(), any(), any()))
            .thenReturn(0);

        final message = List.generate(25, (index) => index * 3);

        await sut.addStream(Stream.value(Uint8List.fromList(message)));

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(message)),
              ),
          () => mockSodium.crypto_generichash_update(
                any(that: isNot(nullptr)),
                any(that: hasRawData<UnsignedChar>(message)),
                message.length,
              ),
          () => mockSodium.sodium_free(
                any(that: hasRawData(message)),
              ),
        ]);
      });

      test('throws exception and cancels addStream on error', () async {
        when(() => mockSodium.crypto_generichash_update(any(), any(), any()))
            .thenReturn(1);

        final message = List.generate(25, (index) => index * 3);

        await expectLater(
          () => sut.addStream(Stream.value(Uint8List.fromList(message))),
          throwsA(isA<SodiumException>()),
        );

        verify(
          () => mockSodium.sodium_free(
            any(that: hasRawData(message)),
          ),
        );
      });

      test('throws StateError when adding a stream after completition',
          () async {
        when(() => mockSodium.crypto_generichash_final(any(), any(), any()))
            .thenReturn(0);

        await sut.close();

        expect(
          () => sut.addStream(const Stream.empty()),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('close', () {
      test('calls crypto_generichash_final with correct arguments', () async {
        when(
          () => mockSodium.crypto_generichash_final(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        await sut.close();

        verifyInOrder([
          () => mockSodium.sodium_allocarray(outLen, 1),
          () => mockSodium.sodium_memzero(any(that: isNot(nullptr)), outLen),
          () => mockSodium.crypto_generichash_final(
                any(that: isNot(nullptr)),
                any(that: isNot(nullptr)),
                outLen,
              ),
        ]);
      });

      test('returns hash on success', () async {
        final hash = List.generate(outLen, (index) => index * 12);

        when(
          () => mockSodium.crypto_generichash_final(
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments[1] as Pointer, hash);
          return 0;
        });

        final result = await sut.close();

        expect(result, Uint8List.fromList(hash));
        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test('throws exception if hashing fails', () async {
        when(
          () => mockSodium.crypto_generichash_final(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        await expectLater(
          () => sut.close(),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test('throws state error if close is called a second time', () async {
        when(
          () => mockSodium.crypto_generichash_final(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        await sut.close();

        await expectLater(
          () => sut.close(),
          throwsA(isA<StateError>()),
        );
      });

      test('returns same future as hash', () async {
        when(
          () => mockSodium.crypto_generichash_final(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final hash = sut.hash;
        final closed = sut.close();

        expect(hash, closed);
        expect(await hash, await closed);
      });
    });
  });
}
