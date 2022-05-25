@TestOn('js')

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/secret_stream.dart';
import 'package:sodium/src/js/api/helpers/secret_stream/secret_stream_message_tag_jsx.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../../../test_data.dart';

class MockLibSodiumJS extends Mock implements LibSodiumJS {}

void main() {
  final mockSodium = MockLibSodiumJS();

  setUp(() {
    reset(mockSodium);
  });

  testData<Tuple2<SecretStreamMessageTag, num Function()>>(
    'getValue returns correct message tag value',
    [
      Tuple2(
        SecretStreamMessageTag.message,
        () => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_MESSAGE,
      ),
      Tuple2(
        SecretStreamMessageTag.push,
        () => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_PUSH,
      ),
      Tuple2(
        SecretStreamMessageTag.rekey,
        () => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_REKEY,
      ),
      Tuple2(
        SecretStreamMessageTag.finalPush,
        () => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_FINAL,
      ),
    ],
    (fixture) {
      const value = 12;
      when(fixture.item2).thenReturn(value);

      final result = fixture.item1.getValue(mockSodium);

      expect(result, value);
      verify(fixture.item2);
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

    testData<Tuple2<SecretStreamMessageTag, num Function()>>(
      'returns correct tag for value',
      [
        Tuple2(
          SecretStreamMessageTag.message,
          () => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_MESSAGE,
        ),
        Tuple2(
          SecretStreamMessageTag.push,
          () => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_PUSH,
        ),
        Tuple2(
          SecretStreamMessageTag.rekey,
          () => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_REKEY,
        ),
        Tuple2(
          SecretStreamMessageTag.finalPush,
          () => mockSodium.crypto_secretstream_xchacha20poly1305_TAG_FINAL,
        ),
      ],
      (fixture) {
        const value = 12;
        when(fixture.item2).thenReturn(value);

        final result = SecretStreamMessageTagJSX.fromValue(mockSodium, value);

        expect(result, fixture.item1);
        verify(fixture.item2);
      },
    );

    test('throws for invalid value', () {
      expect(
        () => SecretStreamMessageTagJSX.fromValue(mockSodium, 42),
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
