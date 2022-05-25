@TestOn('dart-vm')

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/secret_stream.dart';

import 'package:sodium/src/ffi/api/helpers/secret_stream/secret_stream_message_tag_ffix.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../../../test_data.dart';

class MockLibSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockLibSodiumFFI();

  setUp(() {
    reset(mockSodium);
  });

  testData<Tuple2<SecretStreamMessageTag, int Function()>>(
    'getValue returns correct message tag value',
    [
      Tuple2(
        SecretStreamMessageTag.message,
        () => mockSodium.crypto_secretstream_xchacha20poly1305_tag_message(),
      ),
      Tuple2(
        SecretStreamMessageTag.push,
        () => mockSodium.crypto_secretstream_xchacha20poly1305_tag_push(),
      ),
      Tuple2(
        SecretStreamMessageTag.rekey,
        () => mockSodium.crypto_secretstream_xchacha20poly1305_tag_rekey(),
      ),
      Tuple2(
        SecretStreamMessageTag.finalPush,
        () => mockSodium.crypto_secretstream_xchacha20poly1305_tag_final(),
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
      when(() => mockSodium.crypto_secretstream_xchacha20poly1305_tag_message())
          .thenReturn(0);
      when(() => mockSodium.crypto_secretstream_xchacha20poly1305_tag_push())
          .thenReturn(0);
      when(() => mockSodium.crypto_secretstream_xchacha20poly1305_tag_rekey())
          .thenReturn(0);
      when(() => mockSodium.crypto_secretstream_xchacha20poly1305_tag_final())
          .thenReturn(0);
    });

    testData<Tuple2<SecretStreamMessageTag, int Function()>>(
      'returns correct tag for value',
      [
        Tuple2(
          SecretStreamMessageTag.message,
          () => mockSodium.crypto_secretstream_xchacha20poly1305_tag_message(),
        ),
        Tuple2(
          SecretStreamMessageTag.push,
          () => mockSodium.crypto_secretstream_xchacha20poly1305_tag_push(),
        ),
        Tuple2(
          SecretStreamMessageTag.rekey,
          () => mockSodium.crypto_secretstream_xchacha20poly1305_tag_rekey(),
        ),
        Tuple2(
          SecretStreamMessageTag.finalPush,
          () => mockSodium.crypto_secretstream_xchacha20poly1305_tag_final(),
        ),
      ],
      (fixture) {
        const value = 12;
        when(fixture.item2).thenReturn(value);

        final result = SecretStreamMessageTagFFIX.fromValue(mockSodium, value);

        expect(result, fixture.item1);
        verify(fixture.item2);
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
