@TestOn('js')
library;

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/secret_stream.dart';
import 'package:sodium/src/js/api/helpers/secret_stream/secret_stream_message_tag_jsx.dart';
import 'package:test/test.dart';

import '../../../../../test_data.dart';

import '../../../sodium_js_mock.dart';

void main() {
  final mockSodium = MockLibSodiumJS();

  setUp(() {
    reset(mockSodium);
  });

  testData<(SecretStreamMessageTag, num Function())>(
    'getValue returns correct message tag value',
    [
      (
        SecretStreamMessageTag.message,
        () => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_MESSAGE,
      ),
      (
        SecretStreamMessageTag.push,
        () => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_PUSH,
      ),
      (
        SecretStreamMessageTag.rekey,
        () => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_REKEY,
      ),
      (
        SecretStreamMessageTag.finalPush,
        () => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_FINAL,
      ),
    ],
    (fixture) {
      const value = 12;
      when(fixture.$2).thenReturn(value);

      final result = fixture.$1.getValue(mockSodium.asLibSodiumJS);

      expect(result, value);
      verify(fixture.$2);
    },
  );

  group('fromValue', () {
    setUp(() {
      when(() => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_MESSAGE)
          .thenReturn(0);
      when(() => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_PUSH)
          .thenReturn(0);
      when(() => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_REKEY)
          .thenReturn(0);
      when(() => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_FINAL)
          .thenReturn(0);
    });

    testData<(SecretStreamMessageTag, num Function())>(
      'returns correct tag for value',
      [
        (
          SecretStreamMessageTag.message,
          () => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_MESSAGE,
        ),
        (
          SecretStreamMessageTag.push,
          () => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_PUSH,
        ),
        (
          SecretStreamMessageTag.rekey,
          () => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_REKEY,
        ),
        (
          SecretStreamMessageTag.finalPush,
          () => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_FINAL,
        ),
      ],
      (fixture) {
        const value = 12;
        when(fixture.$2).thenReturn(value);

        final result = SecretStreamMessageTagJSX.fromValue(
          mockSodium.asLibSodiumJS,
          value,
        );

        expect(result, fixture.$1);
        verify(fixture.$2);
      },
    );

    test('throws for invalid value', () {
      expect(
        () => SecretStreamMessageTagJSX.fromValue(mockSodium.asLibSodiumJS, 42),
        throwsA(isA<ArgumentError>()),
      );

      verify(
        () => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_MESSAGE,
      );
      verify(
        () => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_PUSH,
      );
      verify(
        () => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_REKEY,
      );
      verify(
        () => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_FINAL,
      );
    });
  });
}
