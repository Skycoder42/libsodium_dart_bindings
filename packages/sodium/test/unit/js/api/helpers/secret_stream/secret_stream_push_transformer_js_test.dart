import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/secret_stream.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/helpers/secret_stream/secret_stream_push_transformer_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:test/test.dart';

import '../../../../../secure_key_fake.dart';

class MockLibSodiumJS extends Mock implements LibSodiumJS {}

void main() {
  final mockSodium = MockLibSodiumJS();

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);
  });

  group('SecretStreamPushTransformerSinkJS', () {
    // ignore: close_sinks
    late SecretStreamPushTransformerSinkJS sut;

    setUp(() {
      when(() => mockSodium.crypto_secretstream_xchacha20poly1305_HEADERBYTES)
          .thenReturn(5);
      when(() => mockSodium.crypto_secretstream_xchacha20poly1305_ABYTES)
          .thenReturn(7);

      sut = SecretStreamPushTransformerSinkJS(mockSodium);
    });

    group('initialize', () {
      final fakeResult = SecretStreamInitPush(
        header: Uint8List(0),
        state: 0,
      );

      test('calls init_push with correct arguments', () {
        final keyData = List.generate(7, (index) => index * 3);
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_init_push(
            any(),
          ),
        ).thenReturn(fakeResult);

        sut.initialize(SecureKeyFake(keyData));

        verify(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_init_push(
            Uint8List.fromList(keyData),
          ),
        );
      });

      test('returns init push result with state and header', () {
        const state = 42;
        final headerData = List.generate(10, (index) => 15 + index);
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_init_push(
            any(),
          ),
        ).thenReturn(
          SecretStreamInitPush(
            state: state,
            header: Uint8List.fromList(headerData),
          ),
        );

        final res = sut.initialize(SecureKeyFake.empty(0));

        expect(res.state, state);
        expect(res.header, headerData);
      });

      test('throws SodiumException if init_push fails', () {
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_init_push(
            any(),
          ),
        ).thenThrow(JsError());

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

        sut.rekey(state);

        verify(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_rekey(state),
        );
      });

      test('throws SodiumException on JsError', () {
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_rekey(any()),
        ).thenThrow(JsError());

        expect(
          () => sut.rekey(1),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('encryptMessage', () {
      setUp(() {
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_MESSAGE,
        ).thenReturn(0);
      });

      test('calls push with correct arguments', () {
        when(() => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_PUSH)
            .thenReturn(42);
        when(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_push(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0));

        final messageData = List.generate(20, (index) => index + 10);
        final additionalData = List.generate(5, (index) => index * index);
        const tag = SecretStreamMessageTag.push;
        const state = 12;

        sut.encryptMessage(
          state,
          SecretStreamPlainMessage(
            Uint8List.fromList(messageData),
            additionalData: Uint8List.fromList(additionalData),
            tag: tag,
          ),
        );

        verify(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_push(
            state,
            Uint8List.fromList(messageData),
            Uint8List.fromList(additionalData),
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
        ).thenReturn(Uint8List(0));

        final messageData = List.generate(20, (index) => index + 10);
        const state = 13;

        sut.encryptMessage(
          state,
          SecretStreamPlainMessage(Uint8List.fromList(messageData)),
        );

        verify(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_push(
            state,
            Uint8List.fromList(messageData),
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
        ).thenReturn(Uint8List.fromList(cipherData));

        final additionalData = List.generate(10, (index) => index * index);
        final result = sut.encryptMessage(
          0,
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
        ).thenReturn(Uint8List.fromList(cipherData));

        final result = sut.encryptMessage(
          0,
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
        ).thenThrow(JsError());

        expect(
          () => sut.encryptMessage(
            11,
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
      sut.disposeState(22);

      verifyZeroInteractions(mockSodium);
    });
  });

  group('SecretStreamPushTransformerJS', () {
    late SecretStreamPushTransformerJS sut;

    setUp(() {
      sut = SecretStreamPushTransformerJS(mockSodium, SecureKeyFake.empty(0));
    });

    test('createSink creates SecretStreamPushTransformerSinkJS', () {
      final sink = sut.createSink();

      expect(
        sink,
        isA<SecretStreamPushTransformerSinkJS>()
            .having((s) => s.sodium, 'sodium', mockSodium),
      );
    });
  });
}
