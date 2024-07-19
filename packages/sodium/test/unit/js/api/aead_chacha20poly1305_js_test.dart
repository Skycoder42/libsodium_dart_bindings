@TestOn('js')
library aead_js_test;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/detached_cipher_result.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/aead_chacha20poly1305_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';

import '../sodium_js_mock.dart';

void main() {
  final mockSodium = MockLibSodiumJS();

  late AeadChaCha20Poly1305JS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);

    sut = AeadChaCha20Poly1305JS(mockSodium.asLibSodiumJS);
  });

  testConstantsMapping([
    (
      () => mockSodium.crypto_aead_chacha20poly1305_KEYBYTES,
      () => sut.keyBytes,
      'keyBytes',
    ),
    (
      () => mockSodium.crypto_aead_chacha20poly1305_NPUBBYTES,
      () => sut.nonceBytes,
      'nonceBytes',
    ),
    (
      () => mockSodium.crypto_aead_chacha20poly1305_ABYTES,
      () => sut.aBytes,
      'aBytes',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_aead_chacha20poly1305_KEYBYTES)
          .thenReturn(5);
      when(() => mockSodium.crypto_aead_chacha20poly1305_NPUBBYTES)
          .thenReturn(5);
      when(() => mockSodium.crypto_aead_chacha20poly1305_ABYTES).thenReturn(5);
    });

    testKeygen(
      mockSodium: mockSodium,
      runKeygen: () => sut.keygen(),
      keygenNative: mockSodium.crypto_aead_chacha20poly1305_keygen,
    );

    group('encrypt', () {
      test('asserts if nonce is invalid', () {
        expect(
          () => sut.encrypt(
            message: Uint8List(0),
            nonce: Uint8List(10),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_aead_chacha20poly1305_NPUBBYTES);
      });

      test('asserts if key is invalid', () {
        expect(
          () => sut.encrypt(
            message: Uint8List(0),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_aead_chacha20poly1305_KEYBYTES);
      });

      test(
          'calls crypto_aead_chacha20poly1305_encrypt with default '
          'arguments', () {
        when(
          () => mockSodium.crypto_aead_chacha20poly1305_encrypt(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0).toJS);

        final message = List.generate(20, (index) => index * 2);
        final nonce = List.generate(5, (index) => 10 + index);
        final key = List.generate(5, (index) => index);

        sut.encrypt(
          message: Uint8List.fromList(message),
          nonce: Uint8List.fromList(nonce),
          key: SecureKeyFake(key),
        );

        verify(
          () => mockSodium.crypto_aead_chacha20poly1305_encrypt(
            Uint8List.fromList(message).toJS,
            null,
            null,
            Uint8List.fromList(nonce).toJS,
            Uint8List.fromList(key).toJS,
          ),
        );
      });

      test(
          'calls crypto_aead_chacha20poly1305_encrypt with additional '
          'data', () {
        when(
          () => mockSodium.crypto_aead_chacha20poly1305_encrypt(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0).toJS);

        final message = List.generate(20, (index) => index * 2);
        final additionalData = List.generate(30, (index) => index * 3);
        final nonce = List.generate(5, (index) => 10 + index);
        final key = List.generate(5, (index) => index);

        sut.encrypt(
          message: Uint8List.fromList(message),
          additionalData: Uint8List.fromList(additionalData),
          nonce: Uint8List.fromList(nonce),
          key: SecureKeyFake(key),
        );

        verify(
          () => mockSodium.crypto_aead_chacha20poly1305_encrypt(
            Uint8List.fromList(message).toJS,
            Uint8List.fromList(additionalData).toJS,
            null,
            Uint8List.fromList(nonce).toJS,
            Uint8List.fromList(key).toJS,
          ),
        );
      });

      test('returns encrypted data', () {
        final cipher = List.generate(25, (index) => 100 - index);
        when(
          () => mockSodium.crypto_aead_chacha20poly1305_encrypt(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List.fromList(cipher).toJS);

        final result = sut.encrypt(
          message: Uint8List(20),
          nonce: Uint8List(5),
          key: SecureKeyFake.empty(5),
        );

        expect(result, cipher);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_aead_chacha20poly1305_encrypt(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenThrow(JSError());

        expect(
          () => sut.encrypt(
            message: Uint8List(10),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('decrypt', () {
      test('asserts if cipherText is invalid', () {
        expect(
          () => sut.decrypt(
            cipherText: Uint8List(0),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_aead_chacha20poly1305_ABYTES);
      });

      test('asserts if nonce is invalid', () {
        expect(
          () => sut.decrypt(
            cipherText: Uint8List(10),
            nonce: Uint8List(10),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_aead_chacha20poly1305_NPUBBYTES);
      });

      test('asserts if key is invalid', () {
        expect(
          () => sut.decrypt(
            cipherText: Uint8List(10),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_aead_chacha20poly1305_KEYBYTES);
      });

      test(
          'calls crypto_aead_chacha20poly1305_decrypt with default '
          'arguments', () {
        when(
          () => mockSodium.crypto_aead_chacha20poly1305_decrypt(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0).toJS);

        final cipherText = List.generate(20, (index) => index * 2);
        final nonce = List.generate(5, (index) => 10 + index);
        final key = List.generate(5, (index) => index);

        sut.decrypt(
          cipherText: Uint8List.fromList(cipherText),
          nonce: Uint8List.fromList(nonce),
          key: SecureKeyFake(key),
        );

        verify(
          () => mockSodium.crypto_aead_chacha20poly1305_decrypt(
            null,
            Uint8List.fromList(cipherText).toJS,
            null,
            Uint8List.fromList(nonce).toJS,
            Uint8List.fromList(key).toJS,
          ),
        );
      });

      test(
          'calls crypto_aead_chacha20poly1305_decrypt with additional '
          'data', () {
        when(
          () => mockSodium.crypto_aead_chacha20poly1305_decrypt(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0).toJS);

        final cipherText = List.generate(20, (index) => index * 2);
        final additionalData = List.generate(30, (index) => index * 3);
        final nonce = List.generate(5, (index) => 10 + index);
        final key = List.generate(5, (index) => index);

        sut.decrypt(
          cipherText: Uint8List.fromList(cipherText),
          additionalData: Uint8List.fromList(additionalData),
          nonce: Uint8List.fromList(nonce),
          key: SecureKeyFake(key),
        );

        verify(
          () => mockSodium.crypto_aead_chacha20poly1305_decrypt(
            null,
            Uint8List.fromList(cipherText).toJS,
            Uint8List.fromList(additionalData).toJS,
            Uint8List.fromList(nonce).toJS,
            Uint8List.fromList(key).toJS,
          ),
        );
      });

      test('returns decrypted data', () {
        final message = List.generate(8, (index) => index * 5);
        when(
          () => mockSodium.crypto_aead_chacha20poly1305_decrypt(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List.fromList(message).toJS);

        final result = sut.decrypt(
          cipherText: Uint8List(13),
          nonce: Uint8List(5),
          key: SecureKeyFake.empty(5),
        );

        expect(result, message);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_aead_chacha20poly1305_decrypt(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenThrow(JSError());

        expect(
          () => sut.decrypt(
            cipherText: Uint8List(10),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('encryptDetached', () {
      test('asserts if nonce is invalid', () {
        expect(
          () => sut.encryptDetached(
            message: Uint8List(0),
            nonce: Uint8List(10),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_aead_chacha20poly1305_NPUBBYTES);
      });

      test('asserts if key is invalid', () {
        expect(
          () => sut.encryptDetached(
            message: Uint8List(0),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_aead_chacha20poly1305_KEYBYTES);
      });

      test(
          'calls crypto_aead_chacha20poly1305_encrypt_detached with '
          'default arguments', () {
        when(
          () => mockSodium.crypto_aead_chacha20poly1305_encrypt_detached(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(
          CryptoBox(
            ciphertext: Uint8List(0).toJS,
            mac: Uint8List(0).toJS,
          ),
        );

        final message = List.generate(20, (index) => index * 2);
        final nonce = List.generate(5, (index) => 10 + index);
        final key = List.generate(5, (index) => index);

        sut.encryptDetached(
          message: Uint8List.fromList(message),
          nonce: Uint8List.fromList(nonce),
          key: SecureKeyFake(key),
        );

        verify(
          () => mockSodium.crypto_aead_chacha20poly1305_encrypt_detached(
            Uint8List.fromList(message).toJS,
            null,
            null,
            Uint8List.fromList(nonce).toJS,
            Uint8List.fromList(key).toJS,
          ),
        );
      });

      test(
          'calls crypto_aead_chacha20poly1305_encrypt_detached with '
          'additional data', () {
        when(
          () => mockSodium.crypto_aead_chacha20poly1305_encrypt_detached(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(
          CryptoBox(
            ciphertext: Uint8List(0).toJS,
            mac: Uint8List(0).toJS,
          ),
        );

        final message = List.generate(20, (index) => index * 2);
        final additionalData = List.generate(15, (index) => index * 3);
        final nonce = List.generate(5, (index) => 10 + index);
        final key = List.generate(5, (index) => index);

        sut.encryptDetached(
          message: Uint8List.fromList(message),
          additionalData: Uint8List.fromList(additionalData),
          nonce: Uint8List.fromList(nonce),
          key: SecureKeyFake(key),
        );

        verify(
          () => mockSodium.crypto_aead_chacha20poly1305_encrypt_detached(
            Uint8List.fromList(message).toJS,
            Uint8List.fromList(additionalData).toJS,
            null,
            Uint8List.fromList(nonce).toJS,
            Uint8List.fromList(key).toJS,
          ),
        );
      });

      test('returns encrypted data and mac', () {
        final cipherText = List.generate(10, (index) => index);
        final mac = List.generate(5, (index) => index * 3);
        when(
          () => mockSodium.crypto_aead_chacha20poly1305_encrypt_detached(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(
          CryptoBox(
            ciphertext: Uint8List.fromList(cipherText).toJS,
            mac: Uint8List.fromList(mac).toJS,
          ),
        );

        final result = sut.encryptDetached(
          message: Uint8List(10),
          nonce: Uint8List(5),
          key: SecureKeyFake.empty(5),
        );

        expect(
          result,
          DetachedCipherResult(
            cipherText: Uint8List.fromList(cipherText),
            mac: Uint8List.fromList(mac),
          ),
        );
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_aead_chacha20poly1305_encrypt_detached(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenThrow(JSError());

        expect(
          () => sut.encryptDetached(
            message: Uint8List(10),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('decryptDetached', () {
      test('asserts if mac is invalid', () {
        expect(
          () => sut.decryptDetached(
            cipherText: Uint8List(0),
            mac: Uint8List(10),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_aead_chacha20poly1305_ABYTES);
      });

      test('asserts if nonce is invalid', () {
        expect(
          () => sut.decryptDetached(
            cipherText: Uint8List(0),
            mac: Uint8List(5),
            nonce: Uint8List(10),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_aead_chacha20poly1305_NPUBBYTES);
      });

      test('asserts if key is invalid', () {
        expect(
          () => sut.decryptDetached(
            cipherText: Uint8List(0),
            mac: Uint8List(5),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_aead_chacha20poly1305_KEYBYTES);
      });

      test(
          'calls crypto_aead_chacha20poly1305_decrypt_detached with '
          'default arguments', () {
        when(
          () => mockSodium.crypto_aead_chacha20poly1305_decrypt_detached(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0).toJS);

        final cipherText = List.generate(15, (index) => index * 2);
        final mac = List.generate(5, (index) => 20 - index);
        final nonce = List.generate(5, (index) => 10 + index);
        final key = List.generate(5, (index) => index);

        sut.decryptDetached(
          cipherText: Uint8List.fromList(cipherText),
          mac: Uint8List.fromList(mac),
          nonce: Uint8List.fromList(nonce),
          key: SecureKeyFake(key),
        );

        verify(
          () => mockSodium.crypto_aead_chacha20poly1305_decrypt_detached(
            null,
            Uint8List.fromList(cipherText).toJS,
            Uint8List.fromList(mac).toJS,
            null,
            Uint8List.fromList(nonce).toJS,
            Uint8List.fromList(key).toJS,
          ),
        );
      });

      test(
          'calls crypto_aead_chacha20poly1305_decrypt_detached with '
          'additonal data', () {
        when(
          () => mockSodium.crypto_aead_chacha20poly1305_decrypt_detached(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0).toJS);

        final cipherText = List.generate(15, (index) => index * 2);
        final mac = List.generate(5, (index) => 20 - index);
        final additionalData = List.generate(30, (index) => index * 3);
        final nonce = List.generate(5, (index) => 10 + index);
        final key = List.generate(5, (index) => index);

        sut.decryptDetached(
          cipherText: Uint8List.fromList(cipherText),
          mac: Uint8List.fromList(mac),
          additionalData: Uint8List.fromList(additionalData),
          nonce: Uint8List.fromList(nonce),
          key: SecureKeyFake(key),
        );

        verify(
          () => mockSodium.crypto_aead_chacha20poly1305_decrypt_detached(
            null,
            Uint8List.fromList(cipherText).toJS,
            Uint8List.fromList(mac).toJS,
            Uint8List.fromList(additionalData).toJS,
            Uint8List.fromList(nonce).toJS,
            Uint8List.fromList(key).toJS,
          ),
        );
      });

      test('returns decrypted data', () {
        final message = List.generate(25, (index) => index);
        when(
          () => mockSodium.crypto_aead_chacha20poly1305_decrypt_detached(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List.fromList(message).toJS);

        final result = sut.decryptDetached(
          cipherText: Uint8List(25),
          mac: Uint8List(5),
          nonce: Uint8List(5),
          key: SecureKeyFake.empty(5),
        );

        expect(result, message);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_aead_chacha20poly1305_decrypt_detached(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenThrow(JSError());

        expect(
          () => sut.decryptDetached(
            cipherText: Uint8List(10),
            mac: Uint8List(5),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });
  });
}
