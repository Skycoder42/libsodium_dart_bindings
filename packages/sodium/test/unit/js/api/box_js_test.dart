import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/detached_cipher_result.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/box_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';

class MockLibSodiumJS extends Mock implements LibSodiumJS {}

void main() {
  final mockSodium = MockLibSodiumJS();

  late BoxJS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);

    sut = BoxJS(mockSodium);
  });

  testConstantsMapping([
    Tuple3(
      () => mockSodium.crypto_box_PUBLICKEYBYTES,
      () => sut.publicKeyBytes,
      'publicKeyBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_box_SECRETKEYBYTES,
      () => sut.secretKeyBytes,
      'secretKeyBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_box_MACBYTES,
      () => sut.macBytes,
      'macBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_box_NONCEBYTES,
      () => sut.nonceBytes,
      'nonceBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_box_SEEDBYTES,
      () => sut.seedBytes,
      'seedBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_box_SEALBYTES,
      () => sut.sealBytes,
      'sealBytes',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_box_PUBLICKEYBYTES).thenReturn(5);
      when(() => mockSodium.crypto_box_SECRETKEYBYTES).thenReturn(5);
      when(() => mockSodium.crypto_box_MACBYTES).thenReturn(5);
      when(() => mockSodium.crypto_box_NONCEBYTES).thenReturn(5);
      when(() => mockSodium.crypto_box_SEEDBYTES).thenReturn(5);
      when(() => mockSodium.crypto_box_SEALBYTES).thenReturn(5);
    });

    group('keypair', () {
      test('calls crypto_box_keypair to allocate keys', () {
        when(() => mockSodium.crypto_box_keypair()).thenReturn(KeyPair(
          keyType: '',
          publicKey: Uint8List(0),
          privateKey: Uint8List(0),
        ));

        sut.keyPair();

        verify(() => mockSodium.crypto_box_keypair());
      });

      test('returns generated key', () {
        final testPublic = List.generate(5, (index) => 10 - index);
        final testSecret = List.generate(5, (index) => index);
        when(() => mockSodium.crypto_box_keypair()).thenReturn(KeyPair(
          keyType: '',
          publicKey: Uint8List.fromList(testPublic),
          privateKey: Uint8List.fromList(testSecret),
        ));

        final res = sut.keyPair();

        expect(res.publicKey, testPublic);
        expect(res.secretKey.extractBytes(), testSecret);
      });

      test('disposes allocated key on error', () {
        when(() => mockSodium.crypto_box_keypair()).thenThrow(JsError());

        expect(() => sut.keyPair(), throwsA(isA<Exception>()));
      });
    });

    group('seedKeypair', () {
      test('asserts if seed is invalid', () {
        expect(
          () => sut.seedKeyPair(SecureKeyFake.empty(10)),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_SEEDBYTES);
      });

      test('calls crypto_box_seed_keypair on the keys with the seed', () {
        when(() => mockSodium.crypto_box_seed_keypair(any()))
            .thenReturn(KeyPair(
          keyType: '',
          publicKey: Uint8List(0),
          privateKey: Uint8List(0),
        ));

        final seed = List.generate(5, (index) => 3 * index);
        sut.seedKeyPair(SecureKeyFake(seed));

        verify(
          () => mockSodium.crypto_box_seed_keypair(Uint8List.fromList(seed)),
        );
      });

      test('returns generated key', () {
        final testPublic = List.generate(5, (index) => 10 - index);
        final testSecret = List.generate(5, (index) => index);
        when(() => mockSodium.crypto_box_seed_keypair(any()))
            .thenReturn(KeyPair(
          keyType: '',
          publicKey: Uint8List.fromList(testPublic),
          privateKey: Uint8List.fromList(testSecret),
        ));

        final res = sut.seedKeyPair(SecureKeyFake.empty(5));

        expect(res.publicKey, testPublic);
        expect(res.secretKey.extractBytes(), testSecret);
      });

      test('disposes allocated key on error', () {
        when(() => mockSodium.crypto_box_seed_keypair(any()))
            .thenThrow(JsError());

        expect(
          () => sut.seedKeyPair(SecureKeyFake.empty(5)),
          throwsA(isA<Exception>()),
        );
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

        verify(() => mockSodium.crypto_box_NONCEBYTES);
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

        verify(() => mockSodium.crypto_box_PUBLICKEYBYTES);
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

        verify(() => mockSodium.crypto_box_SECRETKEYBYTES);
      });

      test('calls crypto_box_easy with correct arguments', () {
        when(
          () => mockSodium.crypto_box_easy(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0));

        final message = List.generate(20, (index) => index * 2);
        final nonce = List.generate(5, (index) => 10 + index);
        final recipientPublicKey = List.generate(5, (index) => 20 + index);
        final senderSecretKey = List.generate(5, (index) => 30 + index);

        sut.easy(
          message: Uint8List.fromList(message),
          nonce: Uint8List.fromList(nonce),
          recipientPublicKey: Uint8List.fromList(recipientPublicKey),
          senderSecretKey: SecureKeyFake(senderSecretKey),
        );

        verify(
          () => mockSodium.crypto_box_easy(
            Uint8List.fromList(message),
            Uint8List.fromList(nonce),
            Uint8List.fromList(recipientPublicKey),
            Uint8List.fromList(senderSecretKey),
          ),
        );
      });

      test('returns encrypted data', () {
        final cipher = List.generate(25, (index) => 100 - index);
        when(
          () => mockSodium.crypto_box_easy(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List.fromList(cipher));

        final result = sut.easy(
          message: Uint8List(20),
          nonce: Uint8List(5),
          recipientPublicKey: Uint8List(5),
          senderSecretKey: SecureKeyFake.empty(5),
        );

        expect(result, cipher);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_box_easy(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenThrow(JsError());

        expect(
          () => sut.easy(
            message: Uint8List(10),
            nonce: Uint8List(5),
            recipientPublicKey: Uint8List(5),
            senderSecretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );
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

        verify(() => mockSodium.crypto_box_MACBYTES);
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

        verify(() => mockSodium.crypto_box_NONCEBYTES);
      });

      test('asserts if senderPublicKey is invalid', () {
        expect(
          () => sut.openEasy(
            cipherText: Uint8List(20),
            nonce: Uint8List(5),
            senderPublicKey: Uint8List(10),
            recipientSecretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_PUBLICKEYBYTES);
      });

      test('asserts if recipientSecretKey is invalid', () {
        expect(
          () => sut.openEasy(
            cipherText: Uint8List(20),
            nonce: Uint8List(5),
            senderPublicKey: Uint8List(5),
            recipientSecretKey: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_SECRETKEYBYTES);
      });

      test('calls crypto_box_open_easy with correct arguments', () {
        when(
          () => mockSodium.crypto_box_open_easy(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0));

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

        verify(
          () => mockSodium.crypto_box_open_easy(
            Uint8List.fromList(cipherText),
            Uint8List.fromList(nonce),
            Uint8List.fromList(senderPublicKey),
            Uint8List.fromList(recipientSecretKey),
          ),
        );
      });

      test('returns decrypted data', () {
        final message = List.generate(8, (index) => index * 5);
        when(
          () => mockSodium.crypto_box_open_easy(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List.fromList(message));

        final result = sut.openEasy(
          cipherText: Uint8List(13),
          nonce: Uint8List(5),
          senderPublicKey: Uint8List(5),
          recipientSecretKey: SecureKeyFake.empty(5),
        );

        expect(result, message);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_box_open_easy(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenThrow(JsError());

        expect(
          () => sut.openEasy(
            cipherText: Uint8List(10),
            nonce: Uint8List(5),
            senderPublicKey: Uint8List(5),
            recipientSecretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );
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

        verify(() => mockSodium.crypto_box_NONCEBYTES);
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

        verify(() => mockSodium.crypto_box_PUBLICKEYBYTES);
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

        verify(() => mockSodium.crypto_box_SECRETKEYBYTES);
      });

      test('calls crypto_box_detached with correct arguments', () {
        when(
          () => mockSodium.crypto_box_detached(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(CryptoBox(
          ciphertext: Uint8List(0),
          mac: Uint8List(0),
        ));

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

        verify(
          () => mockSodium.crypto_box_detached(
            Uint8List.fromList(message),
            Uint8List.fromList(nonce),
            Uint8List.fromList(recipientPublicKey),
            Uint8List.fromList(senderSecretKey),
          ),
        );
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
          ),
        ).thenReturn(CryptoBox(
          ciphertext: Uint8List.fromList(cipherText),
          mac: Uint8List.fromList(mac),
        ));

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
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_box_detached(
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenThrow(JsError());

        expect(
          () => sut.detached(
            message: Uint8List(10),
            nonce: Uint8List(5),
            recipientPublicKey: Uint8List(5),
            senderSecretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );
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

        verify(() => mockSodium.crypto_box_MACBYTES);
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

        verify(() => mockSodium.crypto_box_NONCEBYTES);
      });

      test('asserts if senderPublicKey is invalid', () {
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

        verify(() => mockSodium.crypto_box_PUBLICKEYBYTES);
      });

      test('asserts if recipientSecretKey is invalid', () {
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

        verify(() => mockSodium.crypto_box_SECRETKEYBYTES);
      });

      test('calls crypto_secretbox_open_detached with correct arguments', () {
        when(
          () => mockSodium.crypto_box_open_detached(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0));

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

        verify(
          () => mockSodium.crypto_box_open_detached(
            Uint8List.fromList(cipherText),
            Uint8List.fromList(mac),
            Uint8List.fromList(nonce),
            Uint8List.fromList(senderPublicKey),
            Uint8List.fromList(recipientSecretKey),
          ),
        );
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
          ),
        ).thenReturn(Uint8List.fromList(message));

        final result = sut.openDetached(
          cipherText: Uint8List(25),
          mac: Uint8List(5),
          nonce: Uint8List(5),
          senderPublicKey: Uint8List(5),
          recipientSecretKey: SecureKeyFake.empty(5),
        );

        expect(result, message);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_box_open_detached(
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenThrow(JsError());

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
      });
    });

    group('seal', () {
      test('asserts if recipientPublicKey is invalid', () {
        expect(
          () => sut.seal(
            message: Uint8List(20),
            recipientPublicKey: Uint8List(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_PUBLICKEYBYTES);
      });

      test('calls crypto_box_seal with correct arguments', () {
        when(
          () => mockSodium.crypto_box_seal(
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0));

        final message = List.generate(20, (index) => index * 2);
        final recipientPublicKey = List.generate(5, (index) => 20 + index);

        sut.seal(
          message: Uint8List.fromList(message),
          recipientPublicKey: Uint8List.fromList(recipientPublicKey),
        );

        verify(
          () => mockSodium.crypto_box_seal(
            Uint8List.fromList(message),
            Uint8List.fromList(recipientPublicKey),
          ),
        );
      });

      test('returns encrypted data', () {
        final cipher = List.generate(25, (index) => 100 - index);
        when(
          () => mockSodium.crypto_box_seal(
            any(),
            any(),
          ),
        ).thenReturn(Uint8List.fromList(cipher));

        final result = sut.seal(
          message: Uint8List(20),
          recipientPublicKey: Uint8List(5),
        );

        expect(result, cipher);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_box_seal(
            any(),
            any(),
          ),
        ).thenThrow(JsError());

        expect(
          () => sut.seal(
            message: Uint8List(10),
            recipientPublicKey: Uint8List(5),
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('sealOpen', () {
      test('asserts if cipherText is invalid', () {
        expect(
          () => sut.sealOpen(
            cipherText: Uint8List(3),
            recipientPublicKey: Uint8List(5),
            recipientSecretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_SEALBYTES);
      });

      test('asserts if recipientPublicKey is invalid', () {
        expect(
          () => sut.sealOpen(
            cipherText: Uint8List(20),
            recipientPublicKey: Uint8List(10),
            recipientSecretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_PUBLICKEYBYTES);
      });

      test('asserts if recipientSecretKey is invalid', () {
        expect(
          () => sut.sealOpen(
            cipherText: Uint8List(20),
            recipientPublicKey: Uint8List(5),
            recipientSecretKey: SecureKeyFake.empty(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_SECRETKEYBYTES);
      });

      test('calls crypto_box_seal_open with correct arguments', () {
        when(
          () => mockSodium.crypto_box_seal_open(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0));

        final cipherText = List.generate(20, (index) => index * 2);
        final recipientPublicKey = List.generate(5, (index) => 20 + index);
        final recipientSecretKey = List.generate(5, (index) => 30 + index);

        sut.sealOpen(
          cipherText: Uint8List.fromList(cipherText),
          recipientPublicKey: Uint8List.fromList(recipientPublicKey),
          recipientSecretKey: SecureKeyFake(recipientSecretKey),
        );

        verify(
          () => mockSodium.crypto_box_seal_open(
            Uint8List.fromList(cipherText),
            Uint8List.fromList(recipientPublicKey),
            Uint8List.fromList(recipientSecretKey),
          ),
        );
      });

      test('returns decrypted data', () {
        final message = List.generate(8, (index) => index * 5);
        when(
          () => mockSodium.crypto_box_seal_open(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List.fromList(message));

        final result = sut.sealOpen(
          cipherText: Uint8List(13),
          recipientPublicKey: Uint8List(5),
          recipientSecretKey: SecureKeyFake.empty(5),
        );

        expect(result, message);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_box_seal_open(
            any(),
            any(),
            any(),
          ),
        ).thenThrow(JsError());

        expect(
          () => sut.sealOpen(
            cipherText: Uint8List(10),
            recipientPublicKey: Uint8List(5),
            recipientSecretKey: SecureKeyFake.empty(5),
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });
  });
}
