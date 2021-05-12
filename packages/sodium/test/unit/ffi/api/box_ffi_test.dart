import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/detached_cipher_result.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/box_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  late BoxFFI sut;

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);

    mockAllocArray(mockSodium);

    sut = BoxFFI(mockSodium);
  });

  testConstantsMapping([
    Tuple3(
      () => mockSodium.crypto_box_publickeybytes(),
      () => sut.publicKeyBytes,
      'publicKeyBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_box_secretkeybytes(),
      () => sut.secretKeyBytes,
      'secretKeyBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_box_macbytes(),
      () => sut.macBytes,
      'macBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_box_noncebytes(),
      () => sut.nonceBytes,
      'nonceBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_box_seedbytes(),
      () => sut.seedBytes,
      'seedBytes',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_box_publickeybytes()).thenReturn(5);
      when(() => mockSodium.crypto_box_secretkeybytes()).thenReturn(5);
      when(() => mockSodium.crypto_box_macbytes()).thenReturn(5);
      when(() => mockSodium.crypto_box_noncebytes()).thenReturn(5);
      when(() => mockSodium.crypto_box_seedbytes()).thenReturn(5);
    });

    group('keypair', () {
      test('calls crypto_box_keypair on both allocated keys', () {
        when(() => mockSodium.crypto_box_keypair(any(), any())).thenReturn(0);

        sut.keyPair();

        verifyInOrder([
          () => mockSodium.crypto_box_secretkeybytes(),
          () => mockSodium.sodium_allocarray(5, 1),
          () => mockSodium.crypto_box_publickeybytes(),
          () => mockSodium.sodium_allocarray(5, 1),
          () => mockSodium.sodium_mprotect_readwrite(any(that: isNot(nullptr))),
          () => mockSodium.crypto_box_keypair(
                any(that: isNot(nullptr)),
                any(that: isNot(nullptr)),
              ),
          () => mockSodium.sodium_mprotect_noaccess(any(that: isNot(nullptr))),
        ]);
      });

      test('returns generated key', () {
        final testPublic = List.generate(5, (index) => 10 - index);
        final testSecret = List.generate(5, (index) => index);
        when(() => mockSodium.crypto_box_keypair(any(), any())).thenAnswer((i) {
          fillPointer(i.positionalArguments[0] as Pointer<Uint8>, testPublic);
          fillPointer(i.positionalArguments[1] as Pointer<Uint8>, testSecret);
          return 0;
        });

        final res = sut.keyPair();

        expect(res.publicKey, testPublic);
        expect(res.secretKey.extractBytes(), testSecret);

        verify(() => mockSodium.sodium_free(any(that: hasRawData(testPublic))));
      });

      test('disposes allocated key on error', () {
        when(() => mockSodium.crypto_box_keypair(any(), any())).thenReturn(1);

        expect(() => sut.keyPair(), throwsA(isA<Exception>()));

        verify(
          () => mockSodium.sodium_free(any(that: isNot(nullptr))),
        ).called(2);
      });
    });

    group('seedKeypair', () {
      test('asserts if seed is invalid', () {
        expect(
          () => sut.seedKeyPair(SecureKeyFake.empty(10)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_seedbytes());
      });

      test('calls crypto_box_seed_keypair on the keys with the seed', () {
        when(() => mockSodium.crypto_box_seed_keypair(any(), any(), any()))
            .thenReturn(0);

        final seed = List.generate(5, (index) => 3 * index);
        sut.seedKeyPair(SecureKeyFake(seed));

        verifyInOrder([
          () => mockSodium.crypto_box_secretkeybytes(),
          () => mockSodium.sodium_allocarray(5, 1),
          () => mockSodium.crypto_box_publickeybytes(),
          () => mockSodium.sodium_allocarray(5, 1),
          () => mockSodium.sodium_mprotect_readwrite(
                any(that: isNot(hasRawData(seed))),
              ),
          () => mockSodium.crypto_box_seed_keypair(
                any(that: isNot(nullptr)),
                any(that: isNot(nullptr)),
                any(that: hasRawData<Uint8>(seed)),
              ),
          () => mockSodium.sodium_mprotect_noaccess(
                any(that: isNot(hasRawData(seed))),
              ),
        ]);
      });

      test('returns generated key', () {
        final testPublic = List.generate(5, (index) => 10 - index);
        final testSecret = List.generate(5, (index) => index);
        when(() => mockSodium.crypto_box_seed_keypair(any(), any(), any()))
            .thenAnswer((i) {
          fillPointer(i.positionalArguments[0] as Pointer<Uint8>, testPublic);
          fillPointer(i.positionalArguments[1] as Pointer<Uint8>, testSecret);
          return 0;
        });

        final res = sut.seedKeyPair(SecureKeyFake.empty(5));

        expect(res.publicKey, testPublic);
        expect(res.secretKey.extractBytes(), testSecret);

        verify(() => mockSodium.sodium_free(any(that: hasRawData(testPublic))));
      });

      test('disposes allocated key on error', () {
        when(() => mockSodium.crypto_box_seed_keypair(any(), any(), any()))
            .thenReturn(1);

        expect(
          () => sut.seedKeyPair(SecureKeyFake.empty(5)),
          throwsA(isA<Exception>()),
        );

        verify(
          () => mockSodium.sodium_free(any(that: isNot(nullptr))),
        ).called(3);
      });
    });

    group('easy', () {
      test('asserts if nonce is invalid', () {
        expect(
          () => sut.easy(
            message: Uint8List(20),
            nonce: Uint8List(10),
            recipientPublicKey: Uint8List(5),
            senderSecretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_noncebytes());
      });

      test('asserts if recipientPublicKey is invalid', () {
        expect(
          () => sut.easy(
            message: Uint8List(20),
            nonce: Uint8List(5),
            recipientPublicKey: Uint8List(10),
            senderSecretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_publickeybytes());
      });

      test('asserts if senderSecretKey is invalid', () {
        expect(
          () => sut.easy(
            message: Uint8List(20),
            nonce: Uint8List(5),
            recipientPublicKey: Uint8List(5),
            senderSecretKey: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_secretkeybytes());
      });

      test('calls crypto_box_easy with correct arguments', () {
        when(
          () => mockSodium.crypto_box_easy(
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
        final recipientPublicKey = List.generate(5, (index) => 20 + index);
        final senderSecretKey = List.generate(5, (index) => 30 + index);
        final mac = List.filled(5, 0);

        sut.easy(
          message: Uint8List.fromList(message),
          nonce: Uint8List.fromList(nonce),
          recipientPublicKey: Uint8List.fromList(recipientPublicKey),
          senderSecretKey: SecureKeyFake(senderSecretKey),
        );

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(nonce)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(recipientPublicKey)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(senderSecretKey)),
              ),
          () => mockSodium.crypto_box_easy(
                any(that: hasRawData<Uint8>(mac + message)),
                any(that: hasRawData<Uint8>(message)),
                message.length,
                any(that: hasRawData<Uint8>(nonce)),
                any(that: hasRawData<Uint8>(recipientPublicKey)),
                any(that: hasRawData<Uint8>(senderSecretKey)),
              ),
        ]);
      });

      test('returns encrypted data', () {
        final cipher = List.generate(25, (index) => 100 - index);
        when(
          () => mockSodium.crypto_box_easy(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments.first as Pointer<Uint8>, cipher);
          return 0;
        });

        final result = sut.easy(
          message: Uint8List(20),
          nonce: Uint8List(5),
          recipientPublicKey: Uint8List(5),
          senderSecretKey: SecureKeyFake.empty(5),
        );

        expect(result, cipher);

        verify(() => mockSodium.sodium_free(any())).called(4);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_box_easy(
            any(),
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
            recipientPublicKey: Uint8List(5),
            senderSecretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(4);
      });
    });

    group('openEasy', () {
      test('asserts if cipherText is invalid', () {
        expect(
          () => sut.openEasy(
            cipherText: Uint8List(3),
            nonce: Uint8List(5),
            senderPublicKey: Uint8List(5),
            recipientSecretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_macbytes());
      });

      test('asserts if nonce is invalid', () {
        expect(
          () => sut.openEasy(
            cipherText: Uint8List(20),
            nonce: Uint8List(10),
            senderPublicKey: Uint8List(5),
            recipientSecretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_noncebytes());
      });

      test('asserts if recipientPublicKey is invalid', () {
        expect(
          () => sut.openEasy(
            cipherText: Uint8List(20),
            nonce: Uint8List(5),
            senderPublicKey: Uint8List(10),
            recipientSecretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_publickeybytes());
      });

      test('asserts if senderSecretKey is invalid', () {
        expect(
          () => sut.openEasy(
            cipherText: Uint8List(20),
            nonce: Uint8List(5),
            senderPublicKey: Uint8List(5),
            recipientSecretKey: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_secretkeybytes());
      });

      test('calls crypto_box_open_easy with correct arguments', () {
        when(
          () => mockSodium.crypto_box_open_easy(
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
        final senderPublicKey = List.generate(5, (index) => 20 + index);
        final recipientSecretKey = List.generate(5, (index) => 30 + index);

        sut.openEasy(
          cipherText: Uint8List.fromList(cipherText),
          nonce: Uint8List.fromList(nonce),
          senderPublicKey: Uint8List.fromList(senderPublicKey),
          recipientSecretKey: SecureKeyFake(recipientSecretKey),
        );

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(nonce)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(senderPublicKey)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(recipientSecretKey)),
              ),
          () => mockSodium.crypto_box_open_easy(
                any(that: hasRawData<Uint8>(cipherText.sublist(5))),
                any(that: hasRawData<Uint8>(cipherText)),
                cipherText.length,
                any(that: hasRawData<Uint8>(nonce)),
                any(that: hasRawData<Uint8>(senderPublicKey)),
                any(that: hasRawData<Uint8>(recipientSecretKey)),
              ),
        ]);
      });

      test('returns decrypted data', () {
        final message = List.generate(8, (index) => index * 5);
        when(
          () => mockSodium.crypto_box_open_easy(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments.first as Pointer<Uint8>, message);
          return 0;
        });

        final result = sut.openEasy(
          cipherText: Uint8List(13),
          nonce: Uint8List(5),
          senderPublicKey: Uint8List(5),
          recipientSecretKey: SecureKeyFake.empty(5),
        );

        expect(result, message);

        verify(() => mockSodium.sodium_free(any())).called(4);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_box_open_easy(
            any(),
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
            senderPublicKey: Uint8List(5),
            recipientSecretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(4);
      });
    });

    group('detached', () {
      test('asserts if nonce is invalid', () {
        expect(
          () => sut.detached(
            message: Uint8List(20),
            nonce: Uint8List(10),
            recipientPublicKey: Uint8List(5),
            senderSecretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_noncebytes());
      });

      test('asserts if recipientPublicKey is invalid', () {
        expect(
          () => sut.detached(
            message: Uint8List(20),
            nonce: Uint8List(5),
            recipientPublicKey: Uint8List(10),
            senderSecretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_publickeybytes());
      });

      test('asserts if senderSecretKey is invalid', () {
        expect(
          () => sut.detached(
            message: Uint8List(20),
            nonce: Uint8List(5),
            recipientPublicKey: Uint8List(5),
            senderSecretKey: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_secretkeybytes());
      });

      test('calls crypto_box_detached with correct arguments', () {
        when(
          () => mockSodium.crypto_box_detached(
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
        final recipientPublicKey = List.generate(5, (index) => 20 + index);
        final senderSecretKey = List.generate(5, (index) => 30 + index);

        sut.detached(
          message: Uint8List.fromList(message),
          nonce: Uint8List.fromList(nonce),
          recipientPublicKey: Uint8List.fromList(recipientPublicKey),
          senderSecretKey: SecureKeyFake(senderSecretKey),
        );

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(nonce)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(recipientPublicKey)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(senderSecretKey)),
              ),
          () => mockSodium.crypto_box_detached(
                any(that: hasRawData<Uint8>(message)),
                any(that: isNot(nullptr)),
                any(that: hasRawData<Uint8>(message)),
                message.length,
                any(that: hasRawData<Uint8>(nonce)),
                any(that: hasRawData<Uint8>(recipientPublicKey)),
                any(that: hasRawData<Uint8>(senderSecretKey)),
              ),
        ]);
      });

      test('returns encrypted data and mac', () {
        final cipherText = List.generate(10, (index) => index);
        final mac = List.generate(5, (index) => index * 3);
        when(
          () => mockSodium.crypto_box_detached(
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

        final result = sut.detached(
          message: Uint8List(10),
          nonce: Uint8List(5),
          recipientPublicKey: Uint8List(5),
          senderSecretKey: SecureKeyFake.empty(5),
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
          () => mockSodium.crypto_box_detached(
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
          () => sut.detached(
            message: Uint8List(10),
            nonce: Uint8List(5),
            recipientPublicKey: Uint8List(5),
            senderSecretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(5);
      });
    });

    group('openDetached', () {
      test('asserts if mac is invalid', () {
        expect(
          () => sut.openDetached(
            cipherText: Uint8List(10),
            mac: Uint8List(10),
            nonce: Uint8List(5),
            senderPublicKey: Uint8List(5),
            recipientSecretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_macbytes());
      });

      test('asserts if nonce is invalid', () {
        expect(
          () => sut.openDetached(
            cipherText: Uint8List(10),
            mac: Uint8List(5),
            nonce: Uint8List(10),
            senderPublicKey: Uint8List(5),
            recipientSecretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_noncebytes());
      });

      test('asserts if recipientPublicKey is invalid', () {
        expect(
          () => sut.openDetached(
            cipherText: Uint8List(10),
            mac: Uint8List(5),
            nonce: Uint8List(5),
            senderPublicKey: Uint8List(10),
            recipientSecretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_publickeybytes());
      });

      test('asserts if senderSecretKey is invalid', () {
        expect(
          () => sut.openDetached(
            cipherText: Uint8List(10),
            mac: Uint8List(5),
            nonce: Uint8List(5),
            senderPublicKey: Uint8List(5),
            recipientSecretKey: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_secretkeybytes());
      });

      test('calls crypto_secretbox_open_detached with correct arguments', () {
        when(
          () => mockSodium.crypto_box_open_detached(
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
        final senderPublicKey = List.generate(5, (index) => 20 + index);
        final recipientSecretKey = List.generate(5, (index) => 30 + index);

        sut.openDetached(
          cipherText: Uint8List.fromList(cipherText),
          mac: Uint8List.fromList(mac),
          nonce: Uint8List.fromList(nonce),
          senderPublicKey: Uint8List.fromList(senderPublicKey),
          recipientSecretKey: SecureKeyFake(recipientSecretKey),
        );

        verifyInOrder([
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(mac)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(nonce)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(senderPublicKey)),
              ),
          () => mockSodium.sodium_mprotect_readonly(
                any(that: hasRawData(recipientSecretKey)),
              ),
          () => mockSodium.crypto_box_open_detached(
                any(that: hasRawData<Uint8>(cipherText)),
                any(that: hasRawData<Uint8>(cipherText)),
                any(that: hasRawData<Uint8>(mac)),
                cipherText.length,
                any(that: hasRawData<Uint8>(nonce)),
                any(that: hasRawData<Uint8>(senderPublicKey)),
                any(that: hasRawData<Uint8>(recipientSecretKey)),
              ),
        ]);
      });

      test('returns decrypted data', () {
        final message = List.generate(25, (index) => index);
        when(
          () => mockSodium.crypto_box_open_detached(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments.first as Pointer<Uint8>, message);
          return 0;
        });

        final result = sut.openDetached(
          cipherText: Uint8List(25),
          mac: Uint8List(5),
          nonce: Uint8List(5),
          senderPublicKey: Uint8List(5),
          recipientSecretKey: SecureKeyFake.empty(5),
        );

        expect(result, message);

        verify(() => mockSodium.sodium_free(any())).called(5);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_box_open_detached(
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
          () => sut.openDetached(
            cipherText: Uint8List(10),
            mac: Uint8List(5),
            nonce: Uint8List(5),
            senderPublicKey: Uint8List(5),
            recipientSecretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.sodium_free(any())).called(5);
      });
    });
  });
}
