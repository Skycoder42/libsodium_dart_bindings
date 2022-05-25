@TestOn('js')

import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/detached_cipher_result.dart';
import 'package:sodium/src/api/secure_key.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/box_js.dart';
import 'package:sodium/src/js/api/secure_key_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';

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

  group('BoxJS', () {
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

      testKeypair(
        mockSodium: mockSodium,
        runKeypair: () => sut.keyPair(),
        keypairNative: mockSodium.crypto_box_keypair,
      );

      testSeedKeypair(
        mockSodium: mockSodium,
        runSeedKeypair: (SecureKey seed) => sut.seedKeyPair(seed),
        seedBytesNative: () => mockSodium.crypto_box_SEEDBYTES,
        seedKeypairNative: mockSodium.crypto_box_seed_keypair,
      );

      group('easy', () {
        test('asserts if nonce is invalid', () {
          expect(
            () => sut.easy(
              message: Uint8List(20),
              nonce: Uint8List(10),
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_NONCEBYTES);
        });

        test('asserts if publicKey is invalid', () {
          expect(
            () => sut.easy(
              message: Uint8List(20),
              nonce: Uint8List(5),
              publicKey: Uint8List(10),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_PUBLICKEYBYTES);
        });

        test('asserts if secretKey is invalid', () {
          expect(
            () => sut.easy(
              message: Uint8List(20),
              nonce: Uint8List(5),
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(10),
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
          final publicKey = List.generate(5, (index) => 20 + index);
          final secretKey = List.generate(5, (index) => 30 + index);

          sut.easy(
            message: Uint8List.fromList(message),
            nonce: Uint8List.fromList(nonce),
            publicKey: Uint8List.fromList(publicKey),
            secretKey: SecureKeyFake(secretKey),
          );

          verify(
            () => mockSodium.crypto_box_easy(
              Uint8List.fromList(message),
              Uint8List.fromList(nonce),
              Uint8List.fromList(publicKey),
              Uint8List.fromList(secretKey),
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
            publicKey: Uint8List(5),
            secretKey: SecureKeyFake.empty(5),
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
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(5),
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
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(5),
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
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_NONCEBYTES);
        });

        test('asserts if publicKey is invalid', () {
          expect(
            () => sut.openEasy(
              cipherText: Uint8List(20),
              nonce: Uint8List(5),
              publicKey: Uint8List(10),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_PUBLICKEYBYTES);
        });

        test('asserts if secretKey is invalid', () {
          expect(
            () => sut.openEasy(
              cipherText: Uint8List(20),
              nonce: Uint8List(5),
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(10),
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
          final publicKey = List.generate(5, (index) => 20 + index);
          final secretKey = List.generate(5, (index) => 30 + index);

          sut.openEasy(
            cipherText: Uint8List.fromList(cipherText),
            nonce: Uint8List.fromList(nonce),
            publicKey: Uint8List.fromList(publicKey),
            secretKey: SecureKeyFake(secretKey),
          );

          verify(
            () => mockSodium.crypto_box_open_easy(
              Uint8List.fromList(cipherText),
              Uint8List.fromList(nonce),
              Uint8List.fromList(publicKey),
              Uint8List.fromList(secretKey),
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
            publicKey: Uint8List(5),
            secretKey: SecureKeyFake.empty(5),
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
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(5),
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
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_NONCEBYTES);
        });

        test('asserts if publicKey is invalid', () {
          expect(
            () => sut.detached(
              message: Uint8List(20),
              nonce: Uint8List(5),
              publicKey: Uint8List(10),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_PUBLICKEYBYTES);
        });

        test('asserts if secretKey is invalid', () {
          expect(
            () => sut.detached(
              message: Uint8List(20),
              nonce: Uint8List(5),
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(10),
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
          ).thenReturn(
            CryptoBox(
              ciphertext: Uint8List(0),
              mac: Uint8List(0),
            ),
          );

          final message = List.generate(20, (index) => index * 2);
          final nonce = List.generate(5, (index) => 10 + index);
          final publicKey = List.generate(5, (index) => 20 + index);
          final secretKey = List.generate(5, (index) => 30 + index);

          sut.detached(
            message: Uint8List.fromList(message),
            nonce: Uint8List.fromList(nonce),
            publicKey: Uint8List.fromList(publicKey),
            secretKey: SecureKeyFake(secretKey),
          );

          verify(
            () => mockSodium.crypto_box_detached(
              Uint8List.fromList(message),
              Uint8List.fromList(nonce),
              Uint8List.fromList(publicKey),
              Uint8List.fromList(secretKey),
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
          ).thenReturn(
            CryptoBox(
              ciphertext: Uint8List.fromList(cipherText),
              mac: Uint8List.fromList(mac),
            ),
          );

          final result = sut.detached(
            message: Uint8List(10),
            nonce: Uint8List(5),
            publicKey: Uint8List(5),
            secretKey: SecureKeyFake.empty(5),
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
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(5),
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
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(5),
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
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_NONCEBYTES);
        });

        test('asserts if publicKey is invalid', () {
          expect(
            () => sut.openDetached(
              cipherText: Uint8List(10),
              mac: Uint8List(5),
              nonce: Uint8List(5),
              publicKey: Uint8List(10),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_PUBLICKEYBYTES);
        });

        test('asserts if secretKey is invalid', () {
          expect(
            () => sut.openDetached(
              cipherText: Uint8List(10),
              mac: Uint8List(5),
              nonce: Uint8List(5),
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(10),
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
          final publicKey = List.generate(5, (index) => 20 + index);
          final secretKey = List.generate(5, (index) => 30 + index);

          sut.openDetached(
            cipherText: Uint8List.fromList(cipherText),
            mac: Uint8List.fromList(mac),
            nonce: Uint8List.fromList(nonce),
            publicKey: Uint8List.fromList(publicKey),
            secretKey: SecureKeyFake(secretKey),
          );

          verify(
            () => mockSodium.crypto_box_open_detached(
              Uint8List.fromList(cipherText),
              Uint8List.fromList(mac),
              Uint8List.fromList(nonce),
              Uint8List.fromList(publicKey),
              Uint8List.fromList(secretKey),
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
            publicKey: Uint8List(5),
            secretKey: SecureKeyFake.empty(5),
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
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<SodiumException>()),
          );
        });
      });

      group('precalculate', () {
        test('asserts if publicKey is invalid', () {
          expect(
            () => sut.precalculate(
              publicKey: Uint8List(10),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_PUBLICKEYBYTES);
        });

        test('asserts if secretKey is invalid', () {
          expect(
            () => sut.precalculate(
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(10),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_SECRETKEYBYTES);
        });

        test('calls crypto_box_beforenm with correct arguments', () {
          when(
            () => mockSodium.crypto_box_beforenm(
              any(),
              any(),
            ),
          ).thenReturn(Uint8List(0));

          final publicKey = List.generate(5, (index) => 20 + index);
          final secretKey = List.generate(5, (index) => 30 + index);

          sut.precalculate(
            publicKey: Uint8List.fromList(publicKey),
            secretKey: SecureKeyFake(secretKey),
          );

          verify(
            () => mockSodium.crypto_box_beforenm(
              Uint8List.fromList(publicKey),
              Uint8List.fromList(secretKey),
            ),
          );
        });

        test('returns precompiled box with shared key', () {
          final sharedKey = List.generate(15, (index) => 44 - index);
          when(
            () => mockSodium.crypto_box_beforenm(
              any(),
              any(),
            ),
          ).thenReturn(Uint8List.fromList(sharedKey));

          final result = sut.precalculate(
            publicKey: Uint8List(5),
            secretKey: SecureKeyFake.empty(5),
          );

          expect(
            result,
            isA<PrecalculatedBoxJS>()
                .having(
                  (b) => b.box,
                  'box',
                  sut,
                )
                .having(
                  (b) => b.sharedKey.extractBytes(),
                  'sharedKey',
                  Uint8List.fromList(sharedKey),
                ),
          );
        });

        test('throws error if crypto_box_beforenm fails', () {
          when(
            () => mockSodium.crypto_box_beforenm(
              any(),
              any(),
            ),
          ).thenThrow(JsError());

          expect(
            () => sut.precalculate(
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<SodiumException>()),
          );
        });
      });

      group('seal', () {
        test('asserts if publicKey is invalid', () {
          expect(
            () => sut.seal(
              message: Uint8List(20),
              publicKey: Uint8List(10),
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
          final publicKey = List.generate(5, (index) => 20 + index);

          sut.seal(
            message: Uint8List.fromList(message),
            publicKey: Uint8List.fromList(publicKey),
          );

          verify(
            () => mockSodium.crypto_box_seal(
              Uint8List.fromList(message),
              Uint8List.fromList(publicKey),
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
            publicKey: Uint8List(5),
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
              publicKey: Uint8List(5),
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
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_SEALBYTES);
        });

        test('asserts if publicKey is invalid', () {
          expect(
            () => sut.sealOpen(
              cipherText: Uint8List(20),
              publicKey: Uint8List(10),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<RangeError>()),
          );

          verify(() => mockSodium.crypto_box_PUBLICKEYBYTES);
        });

        test('asserts if secretKey is invalid', () {
          expect(
            () => sut.sealOpen(
              cipherText: Uint8List(20),
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(10),
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
          final publicKey = List.generate(5, (index) => 20 + index);
          final secretKey = List.generate(5, (index) => 30 + index);

          sut.sealOpen(
            cipherText: Uint8List.fromList(cipherText),
            publicKey: Uint8List.fromList(publicKey),
            secretKey: SecureKeyFake(secretKey),
          );

          verify(
            () => mockSodium.crypto_box_seal_open(
              Uint8List.fromList(cipherText),
              Uint8List.fromList(publicKey),
              Uint8List.fromList(secretKey),
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
            publicKey: Uint8List(5),
            secretKey: SecureKeyFake.empty(5),
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
              publicKey: Uint8List(5),
              secretKey: SecureKeyFake.empty(5),
            ),
            throwsA(isA<SodiumException>()),
          );
        });
      });
    });
  });

  group('PrecalculatedBoxJS', () {
    final sharedKey = Uint8List.fromList(List.generate(20, (index) => index));

    late PrecalculatedBoxJS preSut;

    setUp(() {
      preSut = PrecalculatedBoxJS(
        sut,
        SecureKeyJS(mockSodium, sharedKey),
      );

      when(() => mockSodium.crypto_box_MACBYTES).thenReturn(5);
      when(() => mockSodium.crypto_box_NONCEBYTES).thenReturn(5);
    });

    group('easy', () {
      test('asserts if nonce is invalid', () {
        expect(
          () => preSut.easy(
            message: Uint8List(20),
            nonce: Uint8List(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_NONCEBYTES);
      });

      test('calls crypto_box_easy_afternm with correct arguments', () {
        when(
          () => mockSodium.crypto_box_easy_afternm(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0));

        final message = List.generate(20, (index) => index * 2);
        final nonce = List.generate(5, (index) => 10 + index);

        preSut.easy(
          message: Uint8List.fromList(message),
          nonce: Uint8List.fromList(nonce),
        );

        verify(
          () => mockSodium.crypto_box_easy_afternm(
            Uint8List.fromList(message),
            Uint8List.fromList(nonce),
            sharedKey,
          ),
        );
      });

      test('returns encrypted data', () {
        final cipher = List.generate(25, (index) => 100 - index);
        when(
          () => mockSodium.crypto_box_easy_afternm(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List.fromList(cipher));

        final result = preSut.easy(
          message: Uint8List(20),
          nonce: Uint8List(5),
        );

        expect(result, cipher);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_box_easy_afternm(
            any(),
            any(),
            any(),
          ),
        ).thenThrow(JsError());

        expect(
          () => preSut.easy(
            message: Uint8List(10),
            nonce: Uint8List(5),
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('openEasy', () {
      test('asserts if cipherText is invalid', () {
        expect(
          () => preSut.openEasy(
            cipherText: Uint8List(3),
            nonce: Uint8List(5),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_MACBYTES);
      });

      test('asserts if nonce is invalid', () {
        expect(
          () => preSut.openEasy(
            cipherText: Uint8List(20),
            nonce: Uint8List(10),
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_box_NONCEBYTES);
      });

      test('calls crypto_box_open_easy_afternm with correct arguments', () {
        when(
          () => mockSodium.crypto_box_open_easy_afternm(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0));

        final cipherText = List.generate(20, (index) => index * 2);
        final nonce = List.generate(5, (index) => 10 + index);

        preSut.openEasy(
          cipherText: Uint8List.fromList(cipherText),
          nonce: Uint8List.fromList(nonce),
        );

        verify(
          () => mockSodium.crypto_box_open_easy_afternm(
            Uint8List.fromList(cipherText),
            Uint8List.fromList(nonce),
            sharedKey,
          ),
        );
      });

      test('returns decrypted data', () {
        final message = List.generate(8, (index) => index * 5);
        when(
          () => mockSodium.crypto_box_open_easy_afternm(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List.fromList(message));

        final result = preSut.openEasy(
          cipherText: Uint8List(13),
          nonce: Uint8List(5),
        );

        expect(result, message);
      });

      test('throws exception on failure', () {
        when(
          () => mockSodium.crypto_box_open_easy_afternm(
            any(),
            any(),
            any(),
          ),
        ).thenThrow(JsError());

        expect(
          () => preSut.openEasy(
            cipherText: Uint8List(10),
            nonce: Uint8List(5),
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('detached', () {
      test('calls easy with parameters', () {
        when(
          () => mockSodium.crypto_box_easy_afternm(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(10));

        final message = List.generate(20, (index) => index * 2);
        final nonce = List.generate(5, (index) => 10 + index);

        preSut.detached(
          message: Uint8List.fromList(message),
          nonce: Uint8List.fromList(nonce),
        );

        verify(
          () => mockSodium.crypto_box_easy_afternm(
            Uint8List.fromList(message),
            Uint8List.fromList(nonce),
            sharedKey,
          ),
        );
      });

      test('splits easy result into cipherText and mac', () {
        final cipher = List.generate(25, (index) => 100 - index);
        when(
          () => mockSodium.crypto_box_easy_afternm(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List.fromList(cipher));

        final result = preSut.detached(
          message: Uint8List(20),
          nonce: Uint8List(5),
        );

        expect(result.mac, cipher.sublist(0, 5));
        expect(result.cipherText, cipher.sublist(5));
      });
    });

    group('openDetached', () {
      test('calls openEasy with combined parameters', () {
        when(
          () => mockSodium.crypto_box_open_easy_afternm(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0));

        final cipherText = List.generate(15, (index) => index * 2);
        final mac = List.generate(5, (index) => 20 - index);
        final nonce = List.generate(5, (index) => 10 + index);

        preSut.openDetached(
          cipherText: Uint8List.fromList(cipherText),
          mac: Uint8List.fromList(mac),
          nonce: Uint8List.fromList(nonce),
        );

        verify(
          () => mockSodium.crypto_box_open_easy_afternm(
            Uint8List.fromList(mac + cipherText),
            Uint8List.fromList(nonce),
            sharedKey,
          ),
        );
      });

      test('returns decrypted data', () {
        final message = List.generate(8, (index) => index * 5);
        when(
          () => mockSodium.crypto_box_open_easy_afternm(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List.fromList(message));

        final result = preSut.openDetached(
          cipherText: Uint8List(13),
          mac: Uint8List(5),
          nonce: Uint8List(5),
        );

        expect(result, message);
      });

      test('dispose zeros key memory', () {
        preSut.dispose();

        verify(() => mockSodium.memzero(sharedKey));
      });
    });
  });
}
