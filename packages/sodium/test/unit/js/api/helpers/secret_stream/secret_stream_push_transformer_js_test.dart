@TestOn('js')
library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/secret_stream.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/helpers/secret_stream/secret_stream_push_transformer_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:test/test.dart';

import '../../../../../secure_key_fake.dart';

import '../../../sodium_js_mock.dart';

void main() {
  final mockSodium = MockLibSodiumJS();

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);
  });

  group('SecretStreamPushTransformerSinkJS', () {
    // ignore: close_sinks for testing
    late SecretStreamPushTransformerSinkJS sut;

    setUp(() {
      when(
        () => mockSodium.crypto_secretstream_xchacha20poly1305_HEADERBYTES,
      ).thenReturn(5);
      when(
        () => mockSodium.crypto_secretstream_xchacha20poly1305_ABYTES,
      ).thenReturn(7);

      sut = SecretStreamPushTransformerSinkJS(mockSodium.asLibSodiumJS);
    });

    group('initialize', () {
      final fakeResult = SecretStreamInitPush(
        header: Uint8List(0).toJS,
        state: 0.toJS,
      );

      test('calls init_push with correct arguments', () {
        final keyData = List.generate(7, (index) => index * 3);
        when(
          () =>
              mockSodium.crypto_secretstream_xchacha20poly1305_init_push(any()),
        ).thenReturn(fakeResult);

        sut.initialize(SecureKeyFake(keyData));

        verify(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_init_push(
            Uint8List.fromList(keyData).toJS,
          ),
        );
      });

      test('returns init push result with state and header', () {
        const state = 42;
        final headerData = List.generate(10, (index) => 15 + index);
        when(
          () =>
              mockSodium.crypto_secretstream_xchacha20poly1305_init_push(any()),
        ).thenReturn(
          SecretStreamInitPush(
            state: state.toJS,
            header: Uint8List.fromList(headerData).toJS,
          ),
        );

        final res = sut.initialize(SecureKeyFake.empty(0));

        expect(res.state, state);
        expect(res.header, headerData);
      });

      test('throws SodiumException if init_push fails', () {
        when(
          () =>
              mockSodium.crypto_secretstream_xchacha20poly1305_init_push(any()),
        ).thenThrow(JSError());

        expect(
          () => sut.initialize(SecureKeyFake.empty(0)),
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
          () => mockSodium.crypto_secretstream_xchacha20poly1305_rekey(
            state.toJS,
          ),
        );
      });

      test('throws SodiumException on JSError', () {
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_rekey(any()),
        ).thenThrow(JSError());

        expect(() => sut.rekey(1.toJS), throwsA(isA<SodiumException>()));
      });
    });

    group('encryptMessage', () {
      setUp(() {
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_MESSAGE,
        ).thenReturn(0);
      });

      test('calls push with correct arguments', () {
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_PUSH,
        ).thenReturn(42);
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_push(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0).toJS);

        final messageData = List.generate(20, (index) => index + 10);
        final additionalData = List.generate(5, (index) => index * index);
        const tag = SecretStreamMessageTag.push;
        const state = 12;

        sut.encryptMessage(
          state.toJS,
          SecretStreamPlainMessage(
            Uint8List.fromList(messageData),
            additionalData: Uint8List.fromList(additionalData),
            tag: tag,
          ),
        );

        verify(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_push(
            state.toJS,
            Uint8List.fromList(messageData).toJS,
            Uint8List.fromList(additionalData).toJS,
            42,
          ),
        );
      });

      test('calls push without additional data if not set', () {
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_push(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0).toJS);

        final messageData = List.generate(20, (index) => index + 10);
        const state = 13;

        sut.encryptMessage(
          state.toJS,
          SecretStreamPlainMessage(Uint8List.fromList(messageData)),
        );

        verify(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_push(
            state.toJS,
            Uint8List.fromList(messageData).toJS,
            null,
            0,
          ),
        );
      });

      test('returns encrypted cipher message', () {
        final cipherData = List.generate(8, (index) => index * 2);
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_push(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List.fromList(cipherData).toJS);

        final additionalData = List.generate(10, (index) => index * index);
        final result = sut.encryptMessage(
          0.toJS,
          SecretStreamPlainMessage(
            Uint8List(5),
            additionalData: Uint8List.fromList(additionalData),
          ),
        );

        expect(result.message, cipherData);
        expect(result.additionalData, additionalData);
      });

      test('returns encrypted cipher message without extra data', () {
        final cipherData = List.generate(8, (index) => index * 2);
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_push(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List.fromList(cipherData).toJS);

        final result = sut.encryptMessage(
          0.toJS,
          SecretStreamPlainMessage(Uint8List(5)),
        );

        expect(result.message, cipherData);
        expect(result.additionalData, isNull);
      });

      test('throws SodiumException if push fails', () {
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_push(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenThrow(JSError());

        expect(
          () => sut.encryptMessage(
            11.toJS,
            SecretStreamPlainMessage(
              Uint8List(0),
              additionalData: Uint8List(0),
            ),
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    test('disposeState does nothing', () {
      sut.disposeState(22.toJS);

      verifyZeroInteractions(mockSodium);
    });
  });

  group('SecretStreamPushTransformerJS', () {
    late SecretStreamPushTransformerJS sut;

    setUp(() {
      sut = SecretStreamPushTransformerJS(
        mockSodium.asLibSodiumJS,
        SecureKeyFake.empty(0),
      );
    });

    test('createSink creates SecretStreamPushTransformerSinkJS', () {
      final sink = sut.createSink();

      expect(
        sink,
        isA<SecretStreamPushTransformerSinkJS>().having(
          (s) => s.sodium,
          'sodium',
          sut.sodium,
        ),
      );
    });
  });
}
