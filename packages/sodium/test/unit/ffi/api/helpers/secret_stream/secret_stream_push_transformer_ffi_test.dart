// ignore_for_file: invalid_use_of_protected_member
import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/secret_stream.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/helpers/secret_stream/secret_stream_push_transformer_ffi.dart';

import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:sodium/src/ffi/bindings/sodium_pointer.dart';
import 'package:test/test.dart';

import '../../../../../secure_key_fake.dart';
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

  group('SecretStreamPushTransformerSinkFFI', () {
    // ignore: close_sinks
    late SecretStreamPushTransformerSinkFFI sut;

    setUp(() {
      mockAllocArray(mockSodium);
      mockAlloc(mockSodium, 0);

      when(() => mockSodium.crypto_secretstream_xchacha20poly1305_statebytes())
          .thenReturn(5);
      when(() => mockSodium.crypto_secretstream_xchacha20poly1305_headerbytes())
          .thenReturn(10);
      when(() => mockSodium.crypto_secretstream_xchacha20poly1305_abytes())
          .thenReturn(3);

      sut = SecretStreamPushTransformerSinkFFI(mockSodium);
    });

    group('initialize', () {
      test('calls init_push with correct arguments', () {
        final keyData = List.generate(7, (index) => index * 3);
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_init_push(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        sut.initialize(SecureKeyFake(keyData));

        verifyInOrder([
          () => mockSodium.sodium_memzero(any(that: isNot(nullptr)), 5),
          () => mockSodium.crypto_secretstream_xchacha20poly1305_init_push(
                any(that: isNot(nullptr)),
                any(that: isNot(nullptr)),
                any(that: hasRawData(keyData)),
              ),
        ]);
      });

      test('returns init push result with state and header', () {
        final stateData = List.generate(5, (index) => index);
        final headerData = List.generate(10, (index) => 15 + index);
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_init_push(
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments[0] as Pointer, stateData);
          fillPointer(i.positionalArguments[1] as Pointer, headerData);
          return 0;
        });

        final res = sut.initialize(SecureKeyFake.empty(0));

        expect(res.state.count, stateData.length);
        expect(res.state.ptr, hasRawData<Uint8>(stateData));
        expect(res.header, headerData);

        verify(() => mockSodium.sodium_free(any())).called(2);
        verifyNever(
          () => mockSodium.sodium_free(any(that: hasRawData<Uint8>(stateData))),
        );
      });

      test('throws SodiumException if init_push fails', () {
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_init_push(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut.initialize(SecureKeyFake.empty(0)),
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

    group('encryptMessage', () {
      setUp(() {
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_tag_message(),
        ).thenReturn(0);
      });

      test('calls push with correct arguments', () {
        when(() => mockSodium.crypto_secretstream_xchacha20poly1305_tag_push())
            .thenReturn(42);
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_push(
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

        final messageData = List.generate(20, (index) => index + 10);
        final additionalData = List.generate(5, (index) => index * index);
        const tag = SecretStreamMessageTag.push;
        final state = SodiumPointer<Uint8>.alloc(mockSodium);

        sut.encryptMessage(
          state,
          SecretStreamPlainMessage(
            Uint8List.fromList(messageData),
            additionalData: Uint8List.fromList(additionalData),
            tag: tag,
          ),
        );

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(any(that: isNot(nullptr))),
          () => mockSodium.sodium_mprotect_readonly(any(that: isNot(nullptr))),
          () => mockSodium.crypto_secretstream_xchacha20poly1305_push(
                state.ptr.cast(),
                any(that: isNot(nullptr)),
                any(that: equals(nullptr)),
                any(that: hasRawData<Uint8>(messageData)),
                messageData.length,
                any(that: hasRawData<Uint8>(additionalData)),
                additionalData.length,
                42,
              ),
        ]);
      });

      test('calls push without additional data if not set', () {
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_push(
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

        final messageData = List.generate(20, (index) => index + 10);
        final state = SodiumPointer<Uint8>.alloc(mockSodium);

        sut.encryptMessage(
          state,
          SecretStreamPlainMessage(Uint8List.fromList(messageData)),
        );

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(any(that: isNot(nullptr))),
          () => mockSodium.crypto_secretstream_xchacha20poly1305_push(
                state.ptr.cast(),
                any(that: isNot(nullptr)),
                any(that: equals(nullptr)),
                any(that: hasRawData<Uint8>(messageData)),
                messageData.length,
                nullptr.cast(),
                0,
                0,
              ),
        ]);
      });

      test('returns encrypted cipher message', () {
        final cipherData = List.generate(8, (index) => index * 2);
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_push(
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
          fillPointer(i.positionalArguments[1] as Pointer, cipherData);
          return 0;
        });

        final additionalData = List.generate(10, (index) => index * index);
        final result = sut.encryptMessage(
          SodiumPointer.alloc(mockSodium),
          SecretStreamPlainMessage(
            Uint8List(5),
            additionalData: Uint8List.fromList(additionalData),
          ),
        );

        expect(result.message, cipherData);
        expect(result.additionalData, additionalData);
        verify(
          () => mockSodium.sodium_free(any(that: isNot(nullptr))),
        ).called(3);
      });

      test('throws SodiumException if push fails', () {
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_push(
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
          () => sut.encryptMessage(
            SodiumPointer.alloc(mockSodium),
            SecretStreamPlainMessage(
              Uint8List(0),
              additionalData: Uint8List(0),
            ),
          ),
          throwsA(isA<SodiumException>()),
        );
        verify(
          () => mockSodium.sodium_free(any(that: isNot(nullptr))),
        ).called(3);
      });
    });

    test('disposeState frees the state', () {
      final state = SodiumPointer<Uint8>.alloc(mockSodium);

      sut.disposeState(state);

      verify(() => mockSodium.sodium_free(state.ptr.cast()));
    });
  });

  group('SecretStreamPushTransformerFFI', () {
    late SecretStreamPushTransformerFFI sut;

    setUp(() {
      sut = SecretStreamPushTransformerFFI(mockSodium, SecureKeyFake.empty(0));
    });

    test('createSink creates SecretStreamPushTransformerSinkFFI', () {
      final sink = sut.createSink();

      expect(
        sink,
        isA<SecretStreamPushTransformerSinkFFI>()
            .having((s) => s.sodium, 'sodium', mockSodium),
      );
    });
  });
}
