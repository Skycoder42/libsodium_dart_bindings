import 'dart:ffi';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/ffi/api/helpers/secret_stream/secret_stream_pull_transformer_ffi.dart';
import 'package:sodium/src/ffi/api/helpers/secret_stream/secret_stream_push_transformer_ffi.dart';
import 'package:sodium/src/ffi/api/secret_stream_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
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
    Tuple3(
      () => mockSodium.crypto_secretstream_xchacha20poly1305_abytes(),
      () => sut.aBytes,
      'aBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_secretstream_xchacha20poly1305_headerbytes(),
      () => sut.headerBytes,
      'headerBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_secretstream_xchacha20poly1305_keybytes(),
      () => sut.keyBytes,
      'keyBytes',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_secretstream_xchacha20poly1305_keybytes())
          .thenReturn(5);
    });

    group('keygen', () {
      test('calls keygen on generated key', () {
        const len = 5;

        sut.keygen();

        verifyInOrder([
          () => mockSodium.crypto_secretstream_xchacha20poly1305_keybytes(),
          () => mockSodium.sodium_allocarray(len, 1),
          () => mockSodium.sodium_mprotect_readwrite(any(that: isNot(nullptr))),
          () => mockSodium.crypto_secretstream_xchacha20poly1305_keygen(
                any(that: isNot(nullptr)),
              ),
          () => mockSodium.sodium_mprotect_noaccess(any(that: isNot(nullptr))),
        ]);
      });

      test('returns generated key', () {
        final testData = List.generate(5, (index) => index);
        when(() =>
                mockSodium.crypto_secretstream_xchacha20poly1305_keygen(any()))
            .thenAnswer((i) {
          fillPointer(i.positionalArguments[0] as Pointer, testData);
        });

        final res = sut.keygen();

        expect(res.extractBytes(), testData);
      });

      test('disposes allocated key on error', () {
        when(() =>
                mockSodium.crypto_secretstream_xchacha20poly1305_keygen(any()))
            .thenThrow(Exception());

        expect(() => sut.keygen(), throwsA(isA<Exception>()));

        verify(() => mockSodium.sodium_free(any(that: isNot(nullptr))));
      });
    });

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
