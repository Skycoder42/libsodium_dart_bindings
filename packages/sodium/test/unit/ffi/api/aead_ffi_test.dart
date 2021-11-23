@OnPlatform(<String, dynamic>{'!dart-vm': Skip('Requires dart:ffi')})

import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/detached_cipher_result.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/aead_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';
import '../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  late AeadFFI sut;

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);

    mockAllocArray(mockSodium);

    sut = AeadFFI(mockSodium);
  });

  testConstantsMapping([
    Tuple3(
      () => mockSodium.crypto_aead_xchacha20poly1305_ietf_keybytes(),
      () => sut.keyBytes,
      'keyBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_aead_xchacha20poly1305_ietf_npubbytes(),
      () => sut.nonceBytes,
      'nonceBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_aead_xchacha20poly1305_ietf_abytes(),
      () => sut.aBytes,
      'aBytes',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_aead_xchacha20poly1305_ietf_keybytes())
          .thenReturn(5);
      when(() => mockSodium.crypto_aead_xchacha20poly1305_ietf_npubbytes())
          .thenReturn(5);
      when(() => mockSodium.crypto_aead_xchacha20poly1305_ietf_abytes())
          .thenReturn(5);
    });

    testKeygen(
      mockSodium: mockSodium,
      runKeygen: () => sut.keygen(),
      keyBytesNative: mockSodium.crypto_aead_xchacha20poly1305_ietf_keybytes,
      keygenNative: mockSodium.crypto_aead_xchacha20poly1305_ietf_keygen,
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

        verify(() => mockSodium.crypto_aead_xchacha20poly1305_ietf_npubbytes());
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

        verify(() => mockSodium.crypto_aead_xchacha20poly1305_ietf_keybytes());
      });

      test(
          'calls crypto_aead_xchacha20poly1305_ietf_encrypt with default '
          'arguments', () {
        when(
          () => mockSodium.crypto_aead_xchacha20poly1305_ietf_encrypt(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final message = List.generate(20, (index) => index * 2);
        final nonce = List.generate(5, (index) => 10 + index);
        final key = List.generate(5, (index) => index);
        final mac = List.filled(5, 0);

        sut.encrypt(
          message: Uint8List.fromList(message),
          nonce: Uint8List.fromList(nonce),
          key: SecureKeyFake(key),
        );

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(nonce)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(key)),
              ),
          () => mockSodium.crypto_aead_xchacha20poly1305_ietf_encrypt(
                any(that: hasRawData<Uint8>(message + mac)),
                any(that: equals(nullptr)),
                any(that: hasRawData<Uint8>(message)),
                message.length,
                any(that: equals(nullptr)),
                0,
                any(that: equals(nullptr)),
                any(that: hasRawData<Uint8>(nonce)),
                any(that: hasRawData<Uint8>(key)),
              ),
        ]);
      });

      test(
          'calls crypto_aead_xchacha20poly1305_ietf_encrypt with additional '
          'data', () {
        when(
          () => mockSodium.crypto_aead_xchacha20poly1305_ietf_encrypt(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final message = List.generate(20, (index) => index * 2);
        final additionalData = List.generate(30, (index) => index * 3);
        final nonce = List.generate(5, (index) => 10 + index);
        final key = List.generate(5, (index) => index);
        final mac = List.filled(5, 0);

        sut.encrypt(
          message: Uint8List.fromList(message),
          additionalData: Uint8List.fromList(additionalData),
          nonce: Uint8List.fromList(nonce),
          key: SecureKeyFake(key),
        );

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(nonce)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(key)),
              ),
          () => mockSodium.crypto_aead_xchacha20poly1305_ietf_encrypt(
                any(that: hasRawData<Uint8>(message + mac)),
                any(that: equals(nullptr)),
                any(that: hasRawData<Uint8>(message)),
                message.length,
                any(that: hasRawData<Uint8>(additionalData)),
                additionalData.length,
                any(that: equals(nullptr)),
                any(that: hasRawData<Uint8>(nonce)),
                any(that: hasRawData<Uint8>(key)),
              ),
        ]);
      });

      test('returns encrypted data', () {
        final cipher = List.generate(25, (index) => 100 - index);
        when(
          () => mockSodium.crypto_aead_xchacha20poly1305_ietf_encrypt(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments.first as Pointer, cipher);
          return 0;
        });

        final result = sut.encrypt(
          message: Uint8List(20),
          additionalData: Uint8List(10),
          nonce: Uint8List(5),
          key: SecureKeyFake.empty(5),
        );

        expect(result, cipher);

        verify(() => mockSodium.sodium_free(any())).called(4);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_aead_xchacha20poly1305_ietf_encrypt(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut.encrypt(
            message: Uint8List(10),
            additionalData: Uint8List(10),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(4);
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

        verify(() => mockSodium.crypto_aead_xchacha20poly1305_ietf_abytes());
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

        verify(() => mockSodium.crypto_aead_xchacha20poly1305_ietf_npubbytes());
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

        verify(() => mockSodium.crypto_aead_xchacha20poly1305_ietf_keybytes());
      });

      test(
          'calls crypto_aead_xchacha20poly1305_ietf_decrypt with default '
          'arguments', () {
        when(
          () => mockSodium.crypto_aead_xchacha20poly1305_ietf_decrypt(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final cipherText = List.generate(20, (index) => index * 2);
        final nonce = List.generate(5, (index) => 10 + index);
        final key = List.generate(5, (index) => index);

        sut.decrypt(
          cipherText: Uint8List.fromList(cipherText),
          nonce: Uint8List.fromList(nonce),
          key: SecureKeyFake(key),
        );

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(nonce)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(key)),
              ),
          () => mockSodium.crypto_aead_xchacha20poly1305_ietf_decrypt(
                any(that: hasRawData<Uint8>(cipherText)),
                any(that: equals(nullptr)),
                any(that: equals(nullptr)),
                any(that: hasRawData<Uint8>(cipherText)),
                cipherText.length,
                any(that: equals(nullptr)),
                0,
                any(that: hasRawData<Uint8>(nonce)),
                any(that: hasRawData<Uint8>(key)),
              ),
        ]);
      });

      test(
          'calls crypto_aead_xchacha20poly1305_ietf_decrypt with additional '
          'data', () {
        when(
          () => mockSodium.crypto_aead_xchacha20poly1305_ietf_decrypt(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

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

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(nonce)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(additionalData)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(key)),
              ),
          () => mockSodium.crypto_aead_xchacha20poly1305_ietf_decrypt(
                any(that: hasRawData<Uint8>(cipherText)),
                any(that: equals(nullptr)),
                any(that: equals(nullptr)),
                any(that: hasRawData<Uint8>(cipherText)),
                cipherText.length,
                any(that: hasRawData<Uint8>(additionalData)),
                additionalData.length,
                any(that: hasRawData<Uint8>(nonce)),
                any(that: hasRawData<Uint8>(key)),
              ),
        ]);
      });

      test('returns decrypted data', () {
        final message = List.generate(8, (index) => index * 5);
        when(
          () => mockSodium.crypto_aead_xchacha20poly1305_ietf_decrypt(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments.first as Pointer, message);
          return 0;
        });

        final result = sut.decrypt(
          cipherText: Uint8List(13),
          additionalData: Uint8List(10),
          nonce: Uint8List(5),
          key: SecureKeyFake.empty(5),
        );

        expect(result, message);

        verify(() => mockSodium.sodium_free(any())).called(4);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_aead_xchacha20poly1305_ietf_decrypt(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut.decrypt(
            cipherText: Uint8List(10),
            additionalData: Uint8List(10),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(4);
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

        verify(() => mockSodium.crypto_aead_xchacha20poly1305_ietf_npubbytes());
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

        verify(() => mockSodium.crypto_aead_xchacha20poly1305_ietf_keybytes());
      });

      test(
          'calls crypto_aead_xchacha20poly1305_ietf_encrypt_detached with '
          'default arguments', () {
        when(
          () => mockSodium.crypto_aead_xchacha20poly1305_ietf_encrypt_detached(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        final message = List.generate(20, (index) => index * 2);
        final nonce = List.generate(5, (index) => 10 + index);
        final key = List.generate(5, (index) => index);

        sut.encryptDetached(
          message: Uint8List.fromList(message),
          nonce: Uint8List.fromList(nonce),
          key: SecureKeyFake(key),
        );

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(nonce)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(key)),
              ),
          () => mockSodium.crypto_aead_xchacha20poly1305_ietf_encrypt_detached(
                any(that: hasRawData<Uint8>(message)),
                any(that: isNot(nullptr)),
                any(that: equals(nullptr)),
                any(that: hasRawData<Uint8>(message)),
                message.length,
                any(that: equals(nullptr)),
                0,
                any(that: equals(nullptr)),
                any(that: hasRawData<Uint8>(nonce)),
                any(that: hasRawData<Uint8>(key)),
              ),
        ]);
      });

      test(
          'calls crypto_aead_xchacha20poly1305_ietf_encrypt_detached with '
          'additional data', () {
        when(
          () => mockSodium.crypto_aead_xchacha20poly1305_ietf_encrypt_detached(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

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

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(nonce)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(additionalData)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(key)),
              ),
          () => mockSodium.crypto_aead_xchacha20poly1305_ietf_encrypt_detached(
                any(that: hasRawData<Uint8>(message)),
                any(that: isNot(nullptr)),
                any(that: equals(nullptr)),
                any(that: hasRawData<Uint8>(message)),
                message.length,
                any(that: hasRawData<Uint8>(additionalData)),
                additionalData.length,
                any(that: equals(nullptr)),
                any(that: hasRawData<Uint8>(nonce)),
                any(that: hasRawData<Uint8>(key)),
              ),
        ]);
      });

      test('returns encrypted data and mac', () {
        final cipherText = List.generate(10, (index) => index);
        final mac = List.generate(5, (index) => index * 3);
        when(
          () => mockSodium.crypto_aead_xchacha20poly1305_ietf_encrypt_detached(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments[0] as Pointer<Uint8>, cipherText);
          fillPointer(i.positionalArguments[1] as Pointer<Uint8>, mac);
          return 0;
        });

        final result = sut.encryptDetached(
          message: Uint8List(10),
          additionalData: Uint8List(15),
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

        verify(() => mockSodium.sodium_free(any())).called(5);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_aead_xchacha20poly1305_ietf_encrypt_detached(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut.encryptDetached(
            message: Uint8List(10),
            additionalData: Uint8List(15),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(5);
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

        verify(() => mockSodium.crypto_aead_xchacha20poly1305_ietf_abytes());
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

        verify(() => mockSodium.crypto_aead_xchacha20poly1305_ietf_npubbytes());
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

        verify(() => mockSodium.crypto_aead_xchacha20poly1305_ietf_keybytes());
      });

      test(
          'calls crypto_aead_xchacha20poly1305_ietf_decrypt_detached with '
          'default arguments', () {
        when(
          () => mockSodium.crypto_aead_xchacha20poly1305_ietf_decrypt_detached(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

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

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(mac)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(nonce)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(key)),
              ),
          () => mockSodium.crypto_aead_xchacha20poly1305_ietf_decrypt_detached(
                any(that: hasRawData<Uint8>(cipherText)),
                any(that: equals(nullptr)),
                any(that: hasRawData<Uint8>(cipherText)),
                cipherText.length,
                any(that: hasRawData<Uint8>(mac)),
                any(that: equals(nullptr)),
                0,
                any(that: hasRawData<Uint8>(nonce)),
                any(that: hasRawData<Uint8>(key)),
              ),
        ]);
      });

      test(
          'calls crypto_aead_xchacha20poly1305_ietf_decrypt_detached with '
          'additonal data', () {
        when(
          () => mockSodium.crypto_aead_xchacha20poly1305_ietf_decrypt_detached(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

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

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(mac)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(nonce)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(additionalData)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(key)),
              ),
          () => mockSodium.crypto_aead_xchacha20poly1305_ietf_decrypt_detached(
                any(that: hasRawData<Uint8>(cipherText)),
                any(that: equals(nullptr)),
                any(that: hasRawData<Uint8>(cipherText)),
                cipherText.length,
                any(that: hasRawData<Uint8>(mac)),
                any(that: hasRawData<Uint8>(additionalData)),
                additionalData.length,
                any(that: hasRawData<Uint8>(nonce)),
                any(that: hasRawData<Uint8>(key)),
              ),
        ]);
      });

      test('returns decrypted data', () {
        final message = List.generate(25, (index) => index);
        when(
          () => mockSodium.crypto_aead_xchacha20poly1305_ietf_decrypt_detached(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments.first as Pointer, message);
          return 0;
        });

        final result = sut.decryptDetached(
          cipherText: Uint8List(25),
          mac: Uint8List(5),
          additionalData: Uint8List(15),
          nonce: Uint8List(5),
          key: SecureKeyFake.empty(5),
        );

        expect(result, message);

        verify(() => mockSodium.sodium_free(any())).called(5);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_aead_xchacha20poly1305_ietf_decrypt_detached(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut.decryptDetached(
            cipherText: Uint8List(10),
            mac: Uint8List(5),
            additionalData: Uint8List(15),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(5);
      });
    });
  });
}
