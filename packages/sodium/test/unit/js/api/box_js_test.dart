@TestOn('js')
library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/detached_cipher_result.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/box_js.dart';
import 'package:sodium/src/js/api/secure_key_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../../../test_constants_mapping.dart';
import '../keygen_test_helpers.dart';

import '../sodium_js_mock.dart';

void main() {
  final mockSodium = MockLibSodiumJS();

  late BoxJS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);

    sut = BoxJS(mockSodium.asLibSodiumJS);
  });

  group('BoxJS', () {
    testConstantsMapping([
      (
        () => mockSodium.crypto_box_PUBLICKEYBYTES,
        () => sut.publicKeyBytes,
        'publicKeyBytes',
      ),
      (
        () => mockSodium.crypto_box_SECRETKEYBYTES,
        () => sut.secretKeyBytes,
        'secretKeyBytes',
      ),
      (
        () => mockSodium.crypto_box_MACBYTES,
        () => sut.macBytes,
        'macBytes',
      ),
      (
        () => mockSodium.crypto_box_NONCEBYTES,
        () => sut.nonceBytes,
        'nonceBytes',
      ),
      (
        () => mockSodium.crypto_box_SEEDBYTES,
        () => sut.seedBytes,
        'seedBytes',
      ),
      (
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
        runSeedKeypair: (seed) => sut.seedKeyPair(seed),
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
          ).thenReturn(Uint8List(0).toJS);

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
              Uint8List.fromList(message).toJS,
              Uint8List.fromList(nonce).toJS,
              Uint8List.fromList(publicKey).toJS,
              Uint8List.fromList(secretKey).toJS,
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
          ).thenReturn(Uint8List.fromList(cipher).toJS);

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
          ).thenThrow(JSError());

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
          ).thenReturn(Uint8List(0).toJS);

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
              Uint8List.fromList(cipherText).toJS,
              Uint8List.fromList(nonce).toJS,
              Uint8List.fromList(publicKey).toJS,
              Uint8List.fromList(secretKey).toJS,
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
          ).thenReturn(Uint8List.fromList(message).toJS);

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
          ).thenThrow(JSError());

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
              ciphertext: Uint8List(0).toJS,
              mac: Uint8List(0).toJS,
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
              Uint8List.fromList(message).toJS,
              Uint8List.fromList(nonce).toJS,
              Uint8List.fromList(publicKey).toJS,
              Uint8List.fromList(secretKey).toJS,
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
              ciphertext: Uint8List.fromList(cipherText).toJS,
              mac: Uint8List.fromList(mac).toJS,
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
          ).thenThrow(JSError());

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
          ).thenReturn(Uint8List(0).toJS);

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
              Uint8List.fromList(cipherText).toJS,
              Uint8List.fromList(mac).toJS,
              Uint8List.fromList(nonce).toJS,
              Uint8List.fromList(publicKey).toJS,
              Uint8List.fromList(secretKey).toJS,
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
          ).thenReturn(Uint8List.fromList(message).toJS);

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
          ).thenThrow(JSError());

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
          ).thenReturn(Uint8List(0).toJS);

          final publicKey = List.generate(5, (index) => 20 + index);
          final secretKey = List.generate(5, (index) => 30 + index);

          sut.precalculate(
            publicKey: Uint8List.fromList(publicKey),
            secretKey: SecureKeyFake(secretKey),
          );

          verify(
            () => mockSodium.crypto_box_beforenm(
              Uint8List.fromList(publicKey).toJS,
              Uint8List.fromList(secretKey).toJS,
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
          ).thenReturn(Uint8List.fromList(sharedKey).toJS);

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
          ).thenThrow(JSError());

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
          ).thenReturn(Uint8List(0).toJS);

          final message = List.generate(20, (index) => index * 2);
          final publicKey = List.generate(5, (index) => 20 + index);

          sut.seal(
            message: Uint8List.fromList(message),
            publicKey: Uint8List.fromList(publicKey),
          );

          verify(
            () => mockSodium.crypto_box_seal(
              Uint8List.fromList(message).toJS,
              Uint8List.fromList(publicKey).toJS,
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
          ).thenReturn(Uint8List.fromList(cipher).toJS);

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
          ).thenThrow(JSError());

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
          ).thenReturn(Uint8List(0).toJS);

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
              Uint8List.fromList(cipherText).toJS,
              Uint8List.fromList(publicKey).toJS,
              Uint8List.fromList(secretKey).toJS,
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
          ).thenReturn(Uint8List.fromList(message).toJS);

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
          ).thenThrow(JSError());

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
        SecureKeyJS(mockSodium.asLibSodiumJS, sharedKey.toJS),
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
        ).thenReturn(Uint8List(0).toJS);

        final message = List.generate(20, (index) => index * 2);
        final nonce = List.generate(5, (index) => 10 + index);

        preSut.easy(
          message: Uint8List.fromList(message),
          nonce: Uint8List.fromList(nonce),
        );

        verify(
          () => mockSodium.crypto_box_easy_afternm(
            Uint8List.fromList(message).toJS,
            Uint8List.fromList(nonce).toJS,
            sharedKey.toJS,
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
        ).thenReturn(Uint8List.fromList(cipher).toJS);

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
        ).thenThrow(JSError());

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
        ).thenReturn(Uint8List(0).toJS);

        final cipherText = List.generate(20, (index) => index * 2);
        final nonce = List.generate(5, (index) => 10 + index);

        preSut.openEasy(
          cipherText: Uint8List.fromList(cipherText),
          nonce: Uint8List.fromList(nonce),
        );

        verify(
          () => mockSodium.crypto_box_open_easy_afternm(
            Uint8List.fromList(cipherText).toJS,
            Uint8List.fromList(nonce).toJS,
            sharedKey.toJS,
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
        ).thenReturn(Uint8List.fromList(message).toJS);

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
        ).thenThrow(JSError());

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
        ).thenReturn(Uint8List(10).toJS);

        final message = List.generate(20, (index) => index * 2);
        final nonce = List.generate(5, (index) => 10 + index);

        preSut.detached(
          message: Uint8List.fromList(message),
          nonce: Uint8List.fromList(nonce),
        );

        verify(
          () => mockSodium.crypto_box_easy_afternm(
            Uint8List.fromList(message).toJS,
            Uint8List.fromList(nonce).toJS,
            sharedKey.toJS,
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
        ).thenReturn(Uint8List.fromList(cipher).toJS);

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
        ).thenReturn(Uint8List(0).toJS);

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
            Uint8List.fromList(mac + cipherText).toJS,
            Uint8List.fromList(nonce).toJS,
            sharedKey.toJS,
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
        ).thenReturn(Uint8List.fromList(message).toJS);

        final result = preSut.openDetached(
          cipherText: Uint8List(13),
          mac: Uint8List(5),
          nonce: Uint8List(5),
        );

        expect(result, message);
      });

      test('dispose zeros key memory', () {
        preSut.dispose();

        verify(() => mockSodium.memzero(sharedKey.toJS));
      });
    });
  });
}
