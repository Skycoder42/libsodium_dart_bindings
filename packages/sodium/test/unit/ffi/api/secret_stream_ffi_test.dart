// ignore_for_file: unnecessary_lambdas for mocking

@TestOn('dart-vm')
library;

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/ffi/api/helpers/secret_stream/secret_stream_pull_transformer_ffi.dart';
import 'package:sodium/src/ffi/api/helpers/secret_stream/secret_stream_push_transformer_ffi.dart';
import 'package:sodium/src/ffi/api/secret_stream_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';
import '../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  late SecretStreamFFI sut;

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);

    mockAllocArray(mockSodium);

    sut = SecretStreamFFI(mockSodium);
  });

  testConstantsMapping([
    (
      () => mockSodium.crypto_secretstream_xchacha20poly1305_abytes(),
      () => sut.aBytes,
      'aBytes',
    ),
    (
      () => mockSodium.crypto_secretstream_xchacha20poly1305_headerbytes(),
      () => sut.headerBytes,
      'headerBytes',
    ),
    (
      () => mockSodium.crypto_secretstream_xchacha20poly1305_keybytes(),
      () => sut.keyBytes,
      'keyBytes',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(
        () => mockSodium.crypto_secretstream_xchacha20poly1305_keybytes(),
      ).thenReturn(5);
    });

    testKeygen(
      mockSodium: mockSodium,
      runKeygen: () => sut.keygen(),
      keyBytesNative: mockSodium.crypto_secretstream_xchacha20poly1305_keybytes,
      keygenNative: mockSodium.crypto_secretstream_xchacha20poly1305_keygen,
    );

    group('createPushEx', () {
      test('asserts if key is invalid', () {
        expect(
          () => sut.createPushEx(SecureKeyFake.empty(10)),
          throwsA(isA<RangeError>()),
        );

        verify(
          () => mockSodium.crypto_secretstream_xchacha20poly1305_keybytes(),
        );
      });

      test('returns SecretStreamPushTransformerFFI', () {
        final key = SecureKeyFake.empty(5);

        final result = sut.createPushEx(key);

        expect(
          result,
          isA<SecretStreamPushTransformerFFI>()
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
          () => mockSodium.crypto_secretstream_xchacha20poly1305_keybytes(),
        );
      });

      test('returns SecretStreamPullTransformerFFI', () {
        final key = SecureKeyFake.empty(5);

        final result = sut.createPullEx(key, requireFinalized: false);

        expect(
          result,
          isA<SecretStreamPullTransformerFFI>()
              .having((t) => t.sodium, 'sodium', mockSodium)
              .having((t) => t.key, 'key', key)
              .having((t) => t.requireFinalized, 'requireFinalized', isFalse),
        );
      });
    });
  });
}
