import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/js/api/helpers/secret_stream/secret_stream_pull_transformer_js.dart';
import 'package:sodium/src/js/api/helpers/secret_stream/secret_stream_push_transformer_js.dart';
import 'package:sodium/src/js/api/secret_stream_js.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';

class MockLibSodiumJS extends Mock implements LibSodiumJS {}

void main() {
  final mockSodium = MockLibSodiumJS();

  late SecretStreamJS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);

    sut = SecretStreamJS(mockSodium);
  });

  testConstantsMapping([
    Tuple3(
      () => mockSodium.crypto_secretstream_xchacha20poly1305_ABYTES,
      () => sut.aBytes,
      'aBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_secretstream_xchacha20poly1305_HEADERBYTES,
      () => sut.headerBytes,
      'headerBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_secretstream_xchacha20poly1305_KEYBYTES,
      () => sut.keyBytes,
      'keyBytes',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_secretstream_xchacha20poly1305_KEYBYTES)
          .thenReturn(5);
    });

    testKeygen(
      mockSodium: mockSodium,
      runKeygen: () => sut.keygen(),
      keygenNative: mockSodium.crypto_secretstream_xchacha20poly1305_keygen,
    );

    group('createPushEx', () {
      test('asserts if key is invalid', () {
        expect(
          () => sut.createPushEx(SecureKeyFake.empty(10)),
          throwsA(isA<RangeError>()),
        );

        verify(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_KEYBYTES,
        );
      });

      test('returns SecretStreamPushTransformerJS', () {
        final key = SecureKeyFake.empty(5);

        final result = sut.createPushEx(key);

        expect(
          result,
          isA<SecretStreamPushTransformerJS>()
              .having((t) => t.sodium, 'sodium', mockSodium)
              .having((t) => t.key, 'key', key),
        );
      });
    });

    group('createPullEx', () {
      test('asserts if key is invalid', () {
        expect(
          () => sut.createPullEx(SecureKeyFake.empty(10)),
          throwsA(isA<RangeError>()),
        );

        verify(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_KEYBYTES,
        );
      });

      test('returns SecretStreamPullTransformerJS', () {
        final key = SecureKeyFake.empty(5);

        final result = sut.createPullEx(key, requireFinalized: false);

        expect(
          result,
          isA<SecretStreamPullTransformerJS>()
              .having((t) => t.sodium, 'sodium', mockSodium)
              .having((t) => t.key, 'key', key)
              .having((t) => t.requireFinalized, 'requireFinalized', isFalse),
        );
      });
    });
  });
}
