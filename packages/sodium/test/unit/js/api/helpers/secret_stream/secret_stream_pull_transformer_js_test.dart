@TestOn('js')
library secret_stream_pull_transformer_js_test;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/secret_stream.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/helpers/secret_stream/secret_stream_pull_transformer_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:test/test.dart';

import '../../../../../secure_key_fake.dart';
import '../../../../../test_constants_mapping.dart';

import '../../../sodium_js_mock.dart';

void main() {
  final mockSodium = MockLibSodiumJS();

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);
  });

  group('SecretStreamPullTransformerSinkJS', () {
    // ignore: close_sinks
    late SecretStreamPullTransformerSinkJS sut;

    setUp(() {
      when(() => mockSodium.crypto_secretstream_xchacha20poly1305_HEADERBYTES)
          .thenReturn(10);

      sut = SecretStreamPullTransformerSinkJS(mockSodium.asLibSodiumJS, false);
    });

    testConstantsMapping([
      (
        () => mockSodium.crypto_secretstream_xchacha20poly1305_HEADERBYTES,
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
          ),
        ).thenReturn(0.toJS);

        final keyData = List.generate(7, (index) => index * 4);
        final headerData = List.generate(10, (index) => index + 1);

        sut.initialize(
          SecureKeyFake(keyData),
          Uint8List.fromList(headerData),
        );

        verify(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_init_pull(
            Uint8List.fromList(headerData).toJS,
            Uint8List.fromList(keyData).toJS,
          ),
        );
      });

      test('returns init_pull result state', () {
        const state = 111;
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_init_pull(
            any(),
            any(),
          ),
        ).thenReturn(state.toJS);

        final result = sut.initialize(SecureKeyFake.empty(0), Uint8List(0));

        expect(result, state);
      });

      test('throws SodiumException if init_pull fails', () {
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_init_pull(
            any(),
            any(),
          ),
        ).thenThrow(JSError());

        expect(
          () => sut.initialize(SecureKeyFake.empty(0), Uint8List(0)),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('rekey', () {
      test('calls rekey with passed state', () {
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_rekey(any()),
        ).thenReturn(true);

        const state = 23;

        sut.rekey(state.toJS);

        verify(
          () => mockSodium
              .crypto_secretstream_xchacha20poly1305_rekey(state.toJS),
        );
      });

      test('throws SodiumException on JSError', () {
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_rekey(any()),
        ).thenThrow(JSError());

        expect(
          () => sut.rekey(1.toJS),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('decryptMessage', () {
      final pullResult = SecretStreamPull(
        message: Uint8List(0).toJS,
        tag: 0,
      );

      setUp(() {
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_MESSAGE,
        ).thenReturn(0);
      });

      test('calls pull with correct arguments', () {
        when<dynamic>(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_pull(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(pullResult);

        final cipherData = List.generate(20, (index) => index + 10);
        final additionalData = List.generate(5, (index) => index * index);
        const state = 5;

        sut.decryptMessage(
          state.toJS,
          SecretStreamCipherMessage(
            Uint8List.fromList(cipherData),
            additionalData: Uint8List.fromList(additionalData),
          ),
        );

        verify<dynamic>(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_pull(
            state.toJS,
            Uint8List.fromList(cipherData).toJS,
            Uint8List.fromList(additionalData).toJS,
          ),
        );
      });

      test('calls pull without additional data if not set', () {
        when<dynamic>(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_pull(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(pullResult);

        final cipherData = List.generate(20, (index) => index + 10);
        const state = 17;

        sut.decryptMessage(
          state.toJS,
          SecretStreamCipherMessage(Uint8List.fromList(cipherData)),
        );

        verify<dynamic>(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_pull(
            state.toJS,
            Uint8List.fromList(cipherData).toJS,
            null,
          ),
        );
      });

      test('returns decrypted plain message', () {
        const tagValue = 77;
        final plainData = List.generate(13, (index) => index + 1);
        when(() => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_PUSH)
            .thenReturn(tagValue);
        when<dynamic>(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_pull(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(
          SecretStreamPull(
            message: Uint8List.fromList(plainData).toJS,
            tag: tagValue,
          ),
        );

        const state = 44;
        final additionalData = List.generate(5, (index) => index * index);
        final result = sut.decryptMessage(
          state.toJS,
          SecretStreamCipherMessage(
            Uint8List(plainData.length),
            additionalData: Uint8List.fromList(additionalData),
          ),
        );

        expect(result.message, plainData);
        expect(result.additionalData, additionalData);
        expect(result.tag, SecretStreamMessageTag.push);
      });

      test('returns decrypted plain message without additional data', () {
        final plainData = List.generate(13, (index) => index + 1);
        when<dynamic>(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_pull(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(
          SecretStreamPull(
            message: Uint8List.fromList(plainData).toJS,
            tag: 0,
          ),
        );

        const state = 44;
        final result = sut.decryptMessage(
          state.toJS,
          SecretStreamCipherMessage(Uint8List(plainData.length)),
        );

        expect(result.message, plainData);
        expect(result.additionalData, isNull);
        expect(result.tag, SecretStreamMessageTag.message);
      });

      test('throws SodiumException if pull fails', () {
        when<dynamic>(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_pull(
            any(),
            any(),
            any(),
          ),
        ).thenThrow(JSError());

        expect(
          () => sut.decryptMessage(
            56.toJS,
            SecretStreamCipherMessage(Uint8List(0)),
          ),
          throwsA(isA<SodiumException>()),
        );
      });

      test('throws SodiumException if pull returns false', () {
        when<dynamic>(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_pull(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(false);

        expect(
          () => sut.decryptMessage(
            56.toJS,
            SecretStreamCipherMessage(Uint8List(0)),
          ),
          throwsA(isA<SodiumException>()),
        );
      });

      test('throws AssertionError if pull returns true', () {
        when<dynamic>(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_pull(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(true);

        expect(
          () => sut.decryptMessage(
            56.toJS,
            SecretStreamCipherMessage(Uint8List(0)),
          ),
          throwsA(isA<AssertionError>()),
        );
      });

      test('throws TypeError if pull returns unexpected value', () {
        when<dynamic>(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_pull(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(42);

        expect(
          () => sut.decryptMessage(
            56.toJS,
            SecretStreamCipherMessage(Uint8List(0)),
          ),
          throwsA(isA<TypeError>()),
        );
      });
    });

    test('disposeState does nothing', () {
      sut.disposeState(22.toJS);

      verifyZeroInteractions(mockSodium);
    });
  });

  group('SecretStreamPullTransformerJS', () {
    late SecretStreamPullTransformerJS sut;

    setUp(() {
      sut = SecretStreamPullTransformerJS(
        mockSodium.asLibSodiumJS,
        SecureKeyFake.empty(0),
        false,
      );
    });

    test('createSink creates SecretStreamPullTransformerSinkJS', () {
      final sink = sut.createSink(true);

      expect(
        sink,
        isA<SecretStreamPullTransformerSinkJS>()
            .having((s) => s.sodium, 'sodium', sut.sodium)
            .having((s) => s.requireFinalized, 'requireFinalized', isTrue),
      );
    });
  });
}
