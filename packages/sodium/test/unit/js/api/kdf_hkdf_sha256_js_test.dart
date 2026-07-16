@TestOn('js')
library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/helpers/kdf_hkdf/kdf_hkdf_extract_consumer_js.dart';
import 'package:sodium/src/js/api/kdf_hkdf_sha256_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';
import '../sodium_js_mock.dart';

void main() {
  final mockSodium = MockLibSodiumJS();

  late KdfHkdfSha256JS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);

    sut = KdfHkdfSha256JS(mockSodium.asLibSodiumJS);
  });

  testConstantsMapping([
    (
      () => mockSodium.crypto_kdf_hkdf_sha256_KEYBYTES,
      () => sut.keyBytes,
      'keyBytes',
    ),
    (
      () => mockSodium.crypto_kdf_hkdf_sha256_BYTES_MIN,
      () => sut.bytesMin,
      'bytesMin',
    ),
    (
      () => mockSodium.crypto_kdf_hkdf_sha256_BYTES_MAX,
      () => sut.bytesMax,
      'bytesMax',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_kdf_hkdf_sha256_KEYBYTES).thenReturn(5);
      when(() => mockSodium.crypto_kdf_hkdf_sha256_BYTES_MIN).thenReturn(5);
      when(() => mockSodium.crypto_kdf_hkdf_sha256_BYTES_MAX).thenReturn(15);
    });

    testKeygen(
      mockSodium: mockSodium,
      runKeygen: () => sut.keygen(),
      keygenNative: mockSodium.crypto_kdf_hkdf_sha256_keygen,
    );

    group('extract', () {
      test('calls crypto_kdf_hkdf_sha256_extract with correct arguments', () {
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract(any(), any()),
        ).thenReturn(Uint8List(0).toJS);

        final salt = List.generate(8, (index) => index + 1);
        final ikm = List.generate(10, (index) => index * 2);

        sut.extract(
          salt: Uint8List.fromList(salt),
          ikm: Uint8List.fromList(ikm),
        );

        verify(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract(
            Uint8List.fromList(salt).toJS,
            Uint8List.fromList(ikm).toJS,
          ),
        );
      });

      test('passes null as salt when salt is null', () {
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract(any(), any()),
        ).thenReturn(Uint8List(0).toJS);

        final ikm = List.generate(10, (index) => index * 2);

        sut.extract(ikm: Uint8List.fromList(ikm));

        verify(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract(
            null,
            Uint8List.fromList(ikm).toJS,
          ),
        );
      });

      test('returns extracted master key', () {
        final prk = List.generate(5, (index) => 100 - index);

        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract(any(), any()),
        ).thenReturn(Uint8List.fromList(prk).toJS);

        final result = sut.extract(ikm: Uint8List(10));

        expect(result.extractBytes(), prk);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract(any(), any()),
        ).thenThrow(JSError());

        expect(
          () => sut.extract(ikm: Uint8List(10)),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('expand', () {
      test('asserts if masterKey is invalid', () {
        expect(
          () => sut.expand(
            masterKey: SecureKeyFake.empty(10),
            context: 'test',
            outLen: 10,
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_kdf_hkdf_sha256_KEYBYTES);
      });

      test('asserts if outLen is invalid', () {
        expect(
          () => sut.expand(
            masterKey: SecureKeyFake.empty(5),
            context: 'test',
            outLen: 20,
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_kdf_hkdf_sha256_BYTES_MIN);
        verify(() => mockSodium.crypto_kdf_hkdf_sha256_BYTES_MAX);
      });

      test('calls crypto_kdf_hkdf_sha256_expand with correct arguments', () {
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_expand(any(), any(), any()),
        ).thenReturn(Uint8List(0).toJS);

        final masterKey = List.generate(5, (index) => index + 10);
        const context = 'TEST';
        const outLen = 10;

        sut.expand(
          masterKey: SecureKeyFake(masterKey),
          context: context,
          outLen: outLen,
        );

        verify(
          () => mockSodium.crypto_kdf_hkdf_sha256_expand(
            outLen,
            context,
            Uint8List.fromList(masterKey).toJS,
          ),
        );
      });

      test('returns expanded subkey', () {
        final subkey = List.generate(10, (index) => 100 - index);

        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_expand(any(), any(), any()),
        ).thenReturn(Uint8List.fromList(subkey).toJS);

        final result = sut.expand(
          masterKey: SecureKeyFake.empty(5),
          context: 'test',
          outLen: 10,
        );

        expect(result.extractBytes(), subkey);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_expand(any(), any(), any()),
        ).thenThrow(JSError());

        expect(
          () => sut.expand(
            masterKey: SecureKeyFake.empty(5),
            context: 'test',
            outLen: 10,
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('createExtractConsumer', () {
      test('returns KdfHkdfExtractConsumerJS and wires extract_init', () {
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_init(any()),
        ).thenReturn(42.toJS);

        final result = sut.createExtractConsumer();

        expect(result, isA<KdfHkdfExtractConsumerJS>());
        verify(() => mockSodium.crypto_kdf_hkdf_sha256_extract_init(null));
      });

      test('wires extract_init with salt', () {
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_init(any()),
        ).thenReturn(42.toJS);

        final salt = List.generate(8, (index) => index + 1);

        final result = sut.createExtractConsumer(
          salt: Uint8List.fromList(salt),
        );

        expect(result, isA<KdfHkdfExtractConsumerJS>());
        verify(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_init(
            Uint8List.fromList(salt).toJS,
          ),
        );
      });
    });

    group('extractStream', () {
      test('extracts master key using the incremental sha256 apis', () async {
        const state = 42;
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_init(any()),
        ).thenReturn(state.toJS);

        final prk = List.generate(5, (index) => index + 50);
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_final(any()),
        ).thenReturn(Uint8List.fromList(prk).toJS);

        final ikm = List.generate(10, (index) => index * 2);

        final result = await sut.extractStream(
          ikm: Stream.value(Uint8List.fromList(ikm)),
        );

        expect(result.extractBytes(), prk);

        verifyInOrder([
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_init(null),
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_update(
            state.toJS,
            Uint8List.fromList(ikm).toJS,
          ),
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_final(state.toJS),
        ]);
      });
    });
  });
}
