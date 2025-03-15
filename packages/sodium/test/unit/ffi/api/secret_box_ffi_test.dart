// ignore_for_file: unnecessary_lambdas

@TestOn('dart-vm')
library;

import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/detached_cipher_result.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/secret_box_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';
import '../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  late SecretBoxFFI sut;

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);

    mockAllocArray(mockSodium);

    sut = SecretBoxFFI(mockSodium);
  });

  testConstantsMapping([
    (
      () => mockSodium.crypto_secretbox_keybytes(),
      () => sut.keyBytes,
      'keyBytes',
    ),
    (
      () => mockSodium.crypto_secretbox_macbytes(),
      () => sut.macBytes,
      'macBytes',
    ),
    (
      () => mockSodium.crypto_secretbox_noncebytes(),
      () => sut.nonceBytes,
      'nonceBytes',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_secretbox_keybytes()).thenReturn(5);
      when(() => mockSodium.crypto_secretbox_macbytes()).thenReturn(5);
      when(() => mockSodium.crypto_secretbox_noncebytes()).thenReturn(5);
    });

    testKeygen(
      mockSodium: mockSodium,
      runKeygen: () => sut.keygen(),
      keyBytesNative: mockSodium.crypto_secretbox_keybytes,
      keygenNative: mockSodium.crypto_secretbox_keygen,
    );

    group('easy', () {
      test('asserts if nonce is invalid', () {
        expect(
          () => sut.easy(
            message: Uint8List(0),
            nonce: Uint8List(10),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_secretbox_noncebytes());
      });

      test('asserts if key is invalid', () {
        expect(
          () => sut.easy(
            message: Uint8List(0),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_secretbox_keybytes());
      });

      test('calls crypto_secretbox_easy with correct arguments', () {
        when(
          () => mockSodium.crypto_secretbox_easy(
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

        sut.easy(
          message: Uint8List.fromList(message),
          nonce: Uint8List.fromList(nonce),
          key: SecureKeyFake(key),
        );

        verifyInOrder([
          () =>
              mockSodium.sodium_mprotect_readonly(any(that: hasRawData(nonce))),
          () => mockSodium.sodium_mprotect_readonly(any(that: hasRawData(key))),
          () => mockSodium.crypto_secretbox_easy(
            any(that: hasRawData<UnsignedChar>(mac + message)),
            any(that: hasRawData<UnsignedChar>(message)),
            message.length,
            any(that: hasRawData<UnsignedChar>(nonce)),
            any(that: hasRawData<UnsignedChar>(key)),
          ),
        ]);
      });

      test('returns encrypted data', () {
        final cipher = List.generate(25, (index) => 100 - index);
        when(
          () => mockSodium.crypto_secretbox_easy(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(
            i.positionalArguments.first as Pointer<UnsignedChar>,
            cipher,
          );
          return 0;
        });

        final result = sut.easy(
          message: Uint8List(20),
          nonce: Uint8List(5),
          key: SecureKeyFake.empty(5),
        );

        expect(result, cipher);

        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_secretbox_easy(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut.easy(
            message: Uint8List(10),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(3);
      });
    });

    group('openEasy', () {
      test('asserts if cipherText is invalid', () {
        expect(
          () => sut.openEasy(
            cipherText: Uint8List(0),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_secretbox_macbytes());
      });

      test('asserts if nonce is invalid', () {
        expect(
          () => sut.openEasy(
            cipherText: Uint8List(10),
            nonce: Uint8List(10),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_secretbox_noncebytes());
      });

      test('asserts if key is invalid', () {
        expect(
          () => sut.openEasy(
            cipherText: Uint8List(10),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_secretbox_keybytes());
      });

      test('calls crypto_secretbox_open_easy with correct arguments', () {
        when(
          () => mockSodium.crypto_secretbox_open_easy(
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

        sut.openEasy(
          cipherText: Uint8List.fromList(cipherText),
          nonce: Uint8List.fromList(nonce),
          key: SecureKeyFake(key),
        );

        verifyInOrder([
          () =>
              mockSodium.sodium_mprotect_readonly(any(that: hasRawData(nonce))),
          () => mockSodium.sodium_mprotect_readonly(any(that: hasRawData(key))),
          () => mockSodium.crypto_secretbox_open_easy(
            any(that: hasRawData<UnsignedChar>(cipherText.sublist(5))),
            any(that: hasRawData<UnsignedChar>(cipherText)),
            cipherText.length,
            any(that: hasRawData<UnsignedChar>(nonce)),
            any(that: hasRawData<UnsignedChar>(key)),
          ),
        ]);
      });

      test('returns decrypted data', () {
        final message = List.generate(8, (index) => index * 5);
        when(
          () => mockSodium.crypto_secretbox_open_easy(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(
            i.positionalArguments.first as Pointer<UnsignedChar>,
            message,
          );
          return 0;
        });

        final result = sut.openEasy(
          cipherText: Uint8List(13),
          nonce: Uint8List(5),
          key: SecureKeyFake.empty(5),
        );

        expect(result, message);

        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_secretbox_open_easy(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut.openEasy(
            cipherText: Uint8List(10),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(3);
      });
    });

    group('detached', () {
      test('asserts if nonce is invalid', () {
        expect(
          () => sut.detached(
            message: Uint8List(0),
            nonce: Uint8List(10),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_secretbox_noncebytes());
      });

      test('asserts if key is invalid', () {
        expect(
          () => sut.detached(
            message: Uint8List(0),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_secretbox_keybytes());
      });

      test('calls crypto_secretbox_detached with correct arguments', () {
        when(
          () => mockSodium.crypto_secretbox_detached(
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

        sut.detached(
          message: Uint8List.fromList(message),
          nonce: Uint8List.fromList(nonce),
          key: SecureKeyFake(key),
        );

        verifyInOrder([
          () =>
              mockSodium.sodium_mprotect_readonly(any(that: hasRawData(nonce))),
          () => mockSodium.sodium_mprotect_readonly(any(that: hasRawData(key))),
          () => mockSodium.crypto_secretbox_detached(
            any(that: hasRawData<UnsignedChar>(message)),
            any(that: isNot(nullptr)),
            any(that: hasRawData<UnsignedChar>(message)),
            message.length,
            any(that: hasRawData<UnsignedChar>(nonce)),
            any(that: hasRawData<UnsignedChar>(key)),
          ),
        ]);
      });

      test('returns encrypted data and mac', () {
        final cipherText = List.generate(10, (index) => index);
        final mac = List.generate(5, (index) => index * 3);
        when(
          () => mockSodium.crypto_secretbox_detached(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(
            i.positionalArguments[0] as Pointer<UnsignedChar>,
            cipherText,
          );
          fillPointer(i.positionalArguments[1] as Pointer<UnsignedChar>, mac);
          return 0;
        });

        final result = sut.detached(
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

        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_secretbox_detached(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut.detached(
            message: Uint8List(10),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(4);
      });
    });

    group('openDetached', () {
      test('asserts if mac is invalid', () {
        expect(
          () => sut.openDetached(
            cipherText: Uint8List(0),
            mac: Uint8List(10),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_secretbox_macbytes());
      });

      test('asserts if nonce is invalid', () {
        expect(
          () => sut.openDetached(
            cipherText: Uint8List(0),
            mac: Uint8List(5),
            nonce: Uint8List(10),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_secretbox_noncebytes());
      });

      test('asserts if key is invalid', () {
        expect(
          () => sut.openDetached(
            cipherText: Uint8List(0),
            mac: Uint8List(5),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_secretbox_keybytes());
      });

      test('calls crypto_secretbox_open_detached with correct arguments', () {
        when(
          () => mockSodium.crypto_secretbox_open_detached(
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

        sut.openDetached(
          cipherText: Uint8List.fromList(cipherText),
          mac: Uint8List.fromList(mac),
          nonce: Uint8List.fromList(nonce),
          key: SecureKeyFake(key),
        );

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(any(that: hasRawData(mac))),
          () =>
              mockSodium.sodium_mprotect_readonly(any(that: hasRawData(nonce))),
          () => mockSodium.sodium_mprotect_readonly(any(that: hasRawData(key))),
          () => mockSodium.crypto_secretbox_open_detached(
            any(that: hasRawData<UnsignedChar>(cipherText)),
            any(that: hasRawData<UnsignedChar>(cipherText)),
            any(that: hasRawData<UnsignedChar>(mac)),
            cipherText.length,
            any(that: hasRawData<UnsignedChar>(nonce)),
            any(that: hasRawData<UnsignedChar>(key)),
          ),
        ]);
      });

      test('returns decrypted data', () {
        final message = List.generate(25, (index) => index);
        when(
          () => mockSodium.crypto_secretbox_open_detached(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(
            i.positionalArguments.first as Pointer<UnsignedChar>,
            message,
          );
          return 0;
        });

        final result = sut.openDetached(
          cipherText: Uint8List(25),
          mac: Uint8List(5),
          nonce: Uint8List(5),
          key: SecureKeyFake.empty(5),
        );

        expect(result, message);

        verify(() => mockSodium.sodium_free(any())).called(3);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_secretbox_open_detached(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut.openDetached(
            cipherText: Uint8List(10),
            mac: Uint8List(5),
            nonce: Uint8List(5),
            key: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(4);
      });
    });
  });
}
