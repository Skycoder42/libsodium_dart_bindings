// ignore_for_file: invalid_use_of_protected_member
import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/secret_stream.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/helpers/secret_stream/secret_stream_pull_transformer_ffi.dart';

import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:sodium/src/ffi/bindings/sodium_pointer.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../../../secure_key_fake.dart';
import '../../../../../test_constants_mapping.dart';
import '../../../pointer_test_helpers.dart';

class MockLibSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockLibSodiumFFI();

  setUpAll(() {
    registerPointers();
    registerFallbackValue<Pointer<crypto_secretstream_xchacha20poly1305_state>>(
      nullptr.cast(),
    );
  });

  setUp(() {
    reset(mockSodium);
  });

  group('SecretStreamPullTransformerSinkFFI', () {
    // ignore: close_sinks
    late SecretStreamPullTransformerSinkFFI sut;

    setUp(() {
      mockAllocArray(mockSodium);
      mockAlloc(mockSodium, 0);

      when(() => mockSodium.crypto_secretstream_xchacha20poly1305_statebytes())
          .thenReturn(5);
      when(() => mockSodium.crypto_secretstream_xchacha20poly1305_headerbytes())
          .thenReturn(10);
      when(() => mockSodium.crypto_secretstream_xchacha20poly1305_abytes())
          .thenReturn(3);

      sut = SecretStreamPullTransformerSinkFFI(mockSodium, false);
    });

    testConstantsMapping([
      Tuple3(
        () => mockSodium.crypto_secretstream_xchacha20poly1305_headerbytes(),
        () => sut.headerBytes,
        'headerBytes',
      ),
    ]);

    group('initialize', () {
      test('calls init_pull with correct arguments', () {
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_init_pull(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final keyData = List.generate(7, (index) => index * 4);
        final headerData = List.generate(10, (index) => index + 1);

        sut.initialize(
          SecureKeyFake(keyData),
          Uint8List.fromList(headerData),
        );

        verifyInOrder([
          () => mockSodium.sodium_memzero(
                any(that: isNot(nullptr)),
                5,
              ),
          () => mockSodium.sodium_mprotect_readonly(any(that: isNot(nullptr))),
          () => mockSodium.crypto_secretstream_xchacha20poly1305_init_pull(
                any(that: isNot(nullptr)),
                any(that: hasRawData<Uint8>(headerData)),
                any(that: hasRawData<Uint8>(keyData)),
              ),
        ]);
      });

      test('returns init_pull result state', () {
        final stateData = List.generate(5, (index) => index);
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_init_pull(
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments[0] as Pointer, stateData);
          return 0;
        });

        final state = sut.initialize(SecureKeyFake.empty(0), Uint8List(0));

        expect(state.count, stateData.length);
        expect(state.ptr, hasRawData<Uint8>(stateData));
        verify(() => mockSodium.sodium_free(any())).called(2);
        verifyNever(
          () => mockSodium.sodium_free(any(that: hasRawData<Uint8>(stateData))),
        );
      });

      test('throws SodiumException if init_pull fails', () {
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_init_pull(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut.initialize(SecureKeyFake.empty(0), Uint8List(0)),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(3);
      });
    });

    test('rekey calls rekey with passed state', () {
      final state = SodiumPointer<Uint8>.alloc(mockSodium);

      sut.rekey(state);

      verify(
        () => mockSodium.crypto_secretstream_xchacha20poly1305_rekey(
          state.ptr.cast(),
        ),
      );
    });

    group('decryptMessage', () {
      setUp(() {
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_tag_message(),
        ).thenReturn(0);
      });

      test('calls pull with correct arguments', () {
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_pull(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final cipherData = List.generate(20, (index) => index + 10);
        final additionalData = List.generate(5, (index) => index * index);
        final state = SodiumPointer<Uint8>.alloc(mockSodium);

        sut.decryptMessage(
          state,
          SecretStreamCipherMessage(
            Uint8List.fromList(cipherData),
            additionalData: Uint8List.fromList(additionalData),
          ),
        );

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(any(that: isNot(nullptr))),
          () => mockSodium.sodium_mprotect_readonly(any(that: isNot(nullptr))),
          () => mockSodium.sodium_memzero(
                any(that: isNot(nullptr)),
                sizeOf<Uint8>(),
              ),
          () => mockSodium.crypto_secretstream_xchacha20poly1305_pull(
                state.ptr.cast(),
                any(that: isNot(nullptr)),
                any(that: equals(nullptr)),
                any(that: predicate((Pointer<Uint8> p) => p.value == 0)),
                any(that: hasRawData<Uint8>(cipherData)),
                cipherData.length,
                any(that: hasRawData<Uint8>(additionalData)),
                additionalData.length,
              ),
        ]);
      });

      test('calls pull without additional data if not set', () {
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_pull(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final cipherData = List.generate(20, (index) => index + 10);
        final state = SodiumPointer<Uint8>.alloc(mockSodium);

        sut.decryptMessage(
          state,
          SecretStreamCipherMessage(Uint8List.fromList(cipherData)),
        );

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(any(that: isNot(nullptr))),
          () => mockSodium.sodium_memzero(
                any(that: isNot(nullptr)),
                sizeOf<Uint8>(),
              ),
          () => mockSodium.crypto_secretstream_xchacha20poly1305_pull(
                state.ptr.cast(),
                any(that: isNot(nullptr)),
                any(that: equals(nullptr)),
                any(that: predicate((Pointer<Uint8> p) => p.value == 0)),
                any(that: hasRawData<Uint8>(cipherData)),
                cipherData.length,
                nullptr.cast(),
                0,
              ),
        ]);
      });

      test('returns decrypted plain message', () {
        const tagValue = 77;
        final plainData = List.generate(13, (index) => index + 1);
        when(() => mockSodium.crypto_secretstream_xchacha20poly1305_tag_push())
            .thenReturn(tagValue);
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_pull(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments[1] as Pointer, plainData);
          (i.positionalArguments[3] as Pointer<Uint8>).value = tagValue;
          return 0;
        });

        final state = SodiumPointer<Uint8>.alloc(mockSodium);
        final additionalData = List.generate(5, (index) => index * index);
        final result = sut.decryptMessage(
          state,
          SecretStreamCipherMessage(
            Uint8List(16),
            additionalData: Uint8List.fromList(additionalData),
          ),
        );

        expect(result.message, plainData);
        expect(result.additionalData, additionalData);
        expect(result.tag, SecretStreamMessageTag.push);
        verify(
          () => mockSodium.sodium_free(any(that: isNot(nullptr))),
        ).called(4);
      });

      test('throws SodiumException if pull fails', () {
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_pull(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut.decryptMessage(
            SodiumPointer<Uint8>.alloc(mockSodium),
            SecretStreamCipherMessage(
              Uint8List(10),
              additionalData: Uint8List(0),
            ),
          ),
          throwsA(isA<SodiumException>()),
        );
        verify(
          () => mockSodium.sodium_free(any(that: isNot(nullptr))),
        ).called(4);
      });
    });

    test('disposeState frees the state', () {
      final state = SodiumPointer<Uint8>.alloc(mockSodium);

      sut.disposeState(state);

      verify(() => mockSodium.sodium_free(state.ptr.cast()));
    });
  });

  group('SecretStreamPullTransformerFFI', () {
    late SecretStreamPullTransformerFFI sut;

    setUp(() {
      sut = SecretStreamPullTransformerFFI(
        mockSodium,
        SecureKeyFake.empty(0),
        false,
      );
    });

    test('createSink creates SecretStreamPullTransformerSinkFFI', () {
      final sink = sut.createSink(true);

      expect(
        sink,
        isA<SecretStreamPullTransformerSinkFFI>()
            .having((s) => s.sodium, 'sodium', mockSodium)
            .having((s) => s.requireFinalized, 'requireFinalized', isTrue),
      );
    });
  });
}
