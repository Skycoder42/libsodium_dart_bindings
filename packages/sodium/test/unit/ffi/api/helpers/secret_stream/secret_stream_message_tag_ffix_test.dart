// ignore_for_file: unnecessary_lambdas

@TestOn('dart-vm')
library;

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/secret_stream.dart';

import 'package:sodium/src/ffi/api/helpers/secret_stream/secret_stream_message_tag_ffix.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';

import '../../../../../test_data.dart';

class MockLibSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockLibSodiumFFI();

  setUp(() {
    reset(mockSodium);
  });

  testData<(SecretStreamMessageTag, int Function())>(
    'getValue returns correct message tag value',
    [
      (
        SecretStreamMessageTag.message,
        () => mockSodium.crypto_secretstream_xchacha20poly1305_tag_message(),
      ),
      (
        SecretStreamMessageTag.push,
        () => mockSodium.crypto_secretstream_xchacha20poly1305_tag_push(),
      ),
      (
        SecretStreamMessageTag.rekey,
        () => mockSodium.crypto_secretstream_xchacha20poly1305_tag_rekey(),
      ),
      (
        SecretStreamMessageTag.finalPush,
        () => mockSodium.crypto_secretstream_xchacha20poly1305_tag_final(),
      ),
    ],
    (fixture) {
      const value = 12;
      when(fixture.$2).thenReturn(value);

      final result = fixture.$1.getValue(mockSodium);

      expect(result, value);
      verify(fixture.$2);
    },
  );

  group('fromValue', () {
    setUp(() {
      when(() => mockSodium.crypto_secretstream_xchacha20poly1305_tag_message())
          .thenReturn(0);
      when(() => mockSodium.crypto_secretstream_xchacha20poly1305_tag_push())
          .thenReturn(0);
      when(() => mockSodium.crypto_secretstream_xchacha20poly1305_tag_rekey())
          .thenReturn(0);
      when(() => mockSodium.crypto_secretstream_xchacha20poly1305_tag_final())
          .thenReturn(0);
    });

    testData<(SecretStreamMessageTag, int Function())>(
      'returns correct tag for value',
      [
        (
          SecretStreamMessageTag.message,
          () => mockSodium.crypto_secretstream_xchacha20poly1305_tag_message(),
        ),
        (
          SecretStreamMessageTag.push,
          () => mockSodium.crypto_secretstream_xchacha20poly1305_tag_push(),
        ),
        (
          SecretStreamMessageTag.rekey,
          () => mockSodium.crypto_secretstream_xchacha20poly1305_tag_rekey(),
        ),
        (
          SecretStreamMessageTag.finalPush,
          () => mockSodium.crypto_secretstream_xchacha20poly1305_tag_final(),
        ),
      ],
      (fixture) {
        const value = 12;
        when(fixture.$2).thenReturn(value);

        final result = SecretStreamMessageTagFFIX.fromValue(mockSodium, value);

        expect(result, fixture.$1);
        verify(fixture.$2);
      },
    );

    test('throws for invalid value', () {
      expect(
        () => SecretStreamMessageTagFFIX.fromValue(mockSodium, 42),
        throwsA(isA<ArgumentError>()),
      );

      verify(
        () => mockSodium.crypto_secretstream_xchacha20poly1305_tag_message(),
      );
      verify(
        () => mockSodium.crypto_secretstream_xchacha20poly1305_tag_push(),
      );
      verify(
        () => mockSodium.crypto_secretstream_xchacha20poly1305_tag_rekey(),
      );
      verify(
        () => mockSodium.crypto_secretstream_xchacha20poly1305_tag_final(),
      );
    });
  });
}
