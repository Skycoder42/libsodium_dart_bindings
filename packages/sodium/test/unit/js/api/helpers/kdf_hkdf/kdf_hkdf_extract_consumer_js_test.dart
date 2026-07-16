@TestOn('js')
library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/helpers/kdf_hkdf/kdf_hkdf_extract_consumer_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:test/test.dart';

import '../../../sodium_js_mock.dart';

void main() {
  const state = 234;

  final mockSodium = MockLibSodiumJS();

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);
  });

  KdfHkdfExtractConsumerJS<KdfHkdfSha256State> createSut({Uint8List? salt}) =>
      KdfHkdfExtractConsumerJS<KdfHkdfSha256State>(
        sodium: mockSodium.asLibSodiumJS,
        extractInit: mockSodium.crypto_kdf_hkdf_sha256_extract_init,
        extractUpdate: mockSodium.crypto_kdf_hkdf_sha256_extract_update,
        extractFinal: mockSodium.crypto_kdf_hkdf_sha256_extract_final,
        salt: salt,
      );

  group('constructor', () {
    test('initializes extract state', () {
      when(
        () => mockSodium.crypto_kdf_hkdf_sha256_extract_init(any()),
      ).thenReturn(state.toJS);

      createSut();

      verify(() => mockSodium.crypto_kdf_hkdf_sha256_extract_init(null));
    });

    test('initializes extract state with salt', () {
      when(
        () => mockSodium.crypto_kdf_hkdf_sha256_extract_init(any()),
      ).thenReturn(state.toJS);

      final salt = List.generate(8, (index) => index + 1);

      createSut(salt: Uint8List.fromList(salt));

      verify(
        () => mockSodium.crypto_kdf_hkdf_sha256_extract_init(
          Uint8List.fromList(salt).toJS,
        ),
      );
    });

    test('throws SodiumException on error', () {
      when(
        () => mockSodium.crypto_kdf_hkdf_sha256_extract_init(any()),
      ).thenThrow(JSError());

      expect(createSut, throwsA(isA<SodiumException>()));
    });
  });

  group('members', () {
    late KdfHkdfExtractConsumerJS<KdfHkdfSha256State> sut;

    setUp(() {
      when(
        () => mockSodium.crypto_kdf_hkdf_sha256_extract_init(any()),
      ).thenReturn(state.toJS);

      sut = createSut();

      clearInteractions(mockSodium);
    });

    group('add', () {
      test('calls extract_update with the given data', () {
        final ikm = List.generate(25, (index) => index * 3);

        sut.add(Uint8List.fromList(ikm));

        verify(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_update(
            state.toJS,
            Uint8List.fromList(ikm).toJS,
          ),
        );
      });

      test('throws StateError when adding data after completition', () async {
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_final(any()),
        ).thenReturn(Uint8List(0).toJS);

        await sut.close();

        expect(() => sut.add(Uint8List(0)), throwsA(isA<StateError>()));
      });
    });

    group('addStream', () {
      test('calls extract_update on stream events', () async {
        final ikm = List.generate(25, (index) => index * 3);

        await sut.addStream(Stream.value(Uint8List.fromList(ikm)));

        verify(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_update(
            state.toJS,
            Uint8List.fromList(ikm).toJS,
          ),
        );
      });

      test('throws exception and cancels addStream on error', () async {
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_update(any(), any()),
        ).thenThrow(JSError());

        final ikm = List.generate(25, (index) => index * 3);

        await expectLater(
          () => sut.addStream(Stream.value(Uint8List.fromList(ikm))),
          throwsA(isA<SodiumException>()),
        );
      });

      test(
        'throws StateError when adding a stream after completition',
        () async {
          when(
            () => mockSodium.crypto_kdf_hkdf_sha256_extract_final(any()),
          ).thenReturn(Uint8List(0).toJS);

          await sut.close();

          expect(
            () => sut.addStream(const Stream.empty()),
            throwsA(isA<StateError>()),
          );
        },
      );
    });

    group('close', () {
      test('calls extract_final with correct arguments', () async {
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_final(any()),
        ).thenReturn(Uint8List(0).toJS);

        await sut.close();

        verify(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_final(state.toJS),
        );
      });

      test('returns extracted master key on success', () async {
        final prk = List.generate(15, (index) => index * 2);

        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_final(any()),
        ).thenReturn(Uint8List.fromList(prk).toJS);

        final result = await sut.close();

        expect(result.extractBytes(), prk);
      });

      test('throws exception if extraction fails', () async {
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_final(any()),
        ).thenThrow(JSError());

        await expectLater(() => sut.close(), throwsA(isA<SodiumException>()));
      });

      test('throws state error if close is called a second time', () async {
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_final(any()),
        ).thenReturn(Uint8List(0).toJS);

        await sut.close();

        await expectLater(() => sut.close(), throwsA(isA<StateError>()));
      });

      test('returns same future as masterKey', () async {
        when(
          () => mockSodium.crypto_kdf_hkdf_sha256_extract_final(any()),
        ).thenReturn(Uint8List(0).toJS);

        final masterKey = sut.masterKey;
        final closed = sut.close();

        expect(closed, masterKey);
        expect(await masterKey, await closed);
      });
    });
  });
}
