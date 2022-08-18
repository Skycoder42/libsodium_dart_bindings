import 'dart:typed_data';

// ignore: test_library_import
import 'package:sodium/sodium.dart';

import '../test_case.dart';

class BoxTestCase extends TestCase {
  BoxTestCase(super.runner);

  @override
  String get name => 'box';

  Box get sut => sodium.crypto.box;

  @override
  void setupTests() {
    test('constants return correct values', () {
      expect(sut.publicKeyBytes, 32, reason: 'publicKeyBytes');
      expect(sut.secretKeyBytes, 32, reason: 'secretKeyBytes');
      expect(sut.macBytes, 16, reason: 'macBytes');
      expect(sut.nonceBytes, 24, reason: 'nonceBytes');
      expect(sut.seedBytes, 32, reason: 'seedBytes');
      expect(sut.sealBytes, 48, reason: 'sealBytes');
    });

    test('keyPair generates different correct length keys', () {
      final key1 = sut.keyPair();
      final key2 = sut.keyPair();

      printOnFailure('key1.secretKey: ${key1.secretKey.extractBytes()}');
      printOnFailure('key1.publicKey: ${key1.publicKey}');
      printOnFailure('key2.secretKey: ${key2.secretKey.extractBytes()}');
      printOnFailure('key2.publicKey: ${key2.publicKey}');

      expect(key1.secretKey, hasLength(sut.secretKeyBytes));
      expect(key1.publicKey, hasLength(sut.publicKeyBytes));
      expect(key2.secretKey, hasLength(sut.secretKeyBytes));
      expect(key2.publicKey, hasLength(sut.publicKeyBytes));

      expect(key1.secretKey, isNot(key2.secretKey));
      expect(key1.publicKey, isNot(key2.publicKey));
    });

    group('seedKeypair', () {
      test('generates different correct length keys for different seeds', () {
        final seed1 = sodium.secureRandom(sut.seedBytes);
        final seed2 = sodium.secureRandom(sut.seedBytes);

        printOnFailure('seed1: ${seed1.extractBytes()}');
        printOnFailure('seed2: ${seed2.extractBytes()}');

        final key1 = sut.seedKeyPair(seed1);
        final key2 = sut.seedKeyPair(seed2);

        printOnFailure('key1.secretKey: ${key1.secretKey.extractBytes()}');
        printOnFailure('key1.publicKey: ${key1.publicKey}');
        printOnFailure('key2.secretKey: ${key2.secretKey.extractBytes()}');
        printOnFailure('key2.publicKey: ${key2.publicKey}');

        expect(key1.secretKey, hasLength(sut.secretKeyBytes));
        expect(key1.publicKey, hasLength(sut.publicKeyBytes));
        expect(key2.secretKey, hasLength(sut.secretKeyBytes));
        expect(key2.publicKey, hasLength(sut.publicKeyBytes));

        expect(key1.secretKey, isNot(key2.secretKey));
        expect(key1.publicKey, isNot(key2.publicKey));
      });

      test('generates same correct length keys for same seeds', () {
        final seed = sodium.secureRandom(sut.seedBytes);

        printOnFailure('seed: ${seed.extractBytes()}');

        final key1 = sut.seedKeyPair(seed);
        final key2 = sut.seedKeyPair(seed);

        printOnFailure('key1.secretKey: ${key1.secretKey.extractBytes()}');
        printOnFailure('key1.publicKey: ${key1.publicKey}');
        printOnFailure('key2.secretKey: ${key2.secretKey.extractBytes()}');
        printOnFailure('key2.publicKey: ${key2.publicKey}');

        expect(key1.secretKey, hasLength(sut.secretKeyBytes));
        expect(key1.publicKey, hasLength(sut.publicKeyBytes));
        expect(key2.secretKey, hasLength(sut.secretKeyBytes));
        expect(key2.publicKey, hasLength(sut.publicKeyBytes));

        expect(key1.secretKey, key2.secretKey);
        expect(key1.publicKey, key2.publicKey);
      });
    });

    group('easy', () {
      test('can encrypt and decrypt data', () {
        final senderKey = sut.keyPair();
        final recipientKey = sut.keyPair();
        final nonce = sodium.randombytes.buf(sut.nonceBytes);
        final message = Uint8List.fromList(
          List.generate(32, (index) => index * 2),
        );

        printOnFailure(
          'senderKey.secretKey: ${senderKey.secretKey.extractBytes()}',
        );
        printOnFailure('senderKey.publicKey: ${senderKey.publicKey}');
        printOnFailure(
          'recipientKey.secretKey: ${recipientKey.secretKey.extractBytes()}',
        );
        printOnFailure('recipientKey.publicKey: ${recipientKey.publicKey}');
        printOnFailure('nonce: $nonce');
        printOnFailure('message: $message');

        final cipherText = sut.easy(
          message: message,
          nonce: nonce,
          publicKey: recipientKey.publicKey,
          secretKey: senderKey.secretKey,
        );

        printOnFailure('cipherText: $cipherText');

        final restored = sut.openEasy(
          cipherText: cipherText,
          nonce: nonce,
          publicKey: senderKey.publicKey,
          secretKey: recipientKey.secretKey,
        );

        printOnFailure('restored: $restored');

        expect(restored, message);
      });

      test('fails if data is invalid', () {
        final senderKey = sut.keyPair();
        final recipientKey = sut.keyPair();
        final nonce = sodium.randombytes.buf(sut.nonceBytes);

        printOnFailure(
          'senderKey.secretKey: ${senderKey.secretKey.extractBytes()}',
        );
        printOnFailure('senderKey.publicKey: ${senderKey.publicKey}');
        printOnFailure(
          'recipientKey.secretKey: ${recipientKey.secretKey.extractBytes()}',
        );
        printOnFailure('recipientKey.publicKey: ${recipientKey.publicKey}');
        printOnFailure('nonce: $nonce');

        final cipherText = sut.easy(
          message: Uint8List.fromList(const [1, 2, 3]),
          nonce: nonce,
          publicKey: recipientKey.publicKey,
          secretKey: senderKey.secretKey,
        );

        printOnFailure('cipherText: $cipherText');
        cipherText[0] = cipherText[0] ^ 0xFF;

        expect(
          () => sut.openEasy(
            cipherText: cipherText,
            nonce: nonce,
            publicKey: senderKey.publicKey,
            secretKey: recipientKey.secretKey,
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('detached', () {
      test('can encrypt and decrypt data', () {
        final senderKey = sut.keyPair();
        final recipientKey = sut.keyPair();
        final nonce = sodium.randombytes.buf(sut.nonceBytes);
        final message = Uint8List.fromList(
          List.generate(32, (index) => index * 2),
        );

        printOnFailure(
          'senderKey.secretKey: ${senderKey.secretKey.extractBytes()}',
        );
        printOnFailure('senderKey.publicKey: ${senderKey.publicKey}');
        printOnFailure(
          'recipientKey.secretKey: ${recipientKey.secretKey.extractBytes()}',
        );
        printOnFailure('recipientKey.publicKey: ${recipientKey.publicKey}');
        printOnFailure('nonce: $nonce');
        printOnFailure('message: $message');

        final cipher = sut.detached(
          message: message,
          nonce: nonce,
          publicKey: recipientKey.publicKey,
          secretKey: senderKey.secretKey,
        );

        printOnFailure('cipher: $cipher');

        final restored = sut.openDetached(
          cipherText: cipher.cipherText,
          mac: cipher.mac,
          nonce: nonce,
          publicKey: senderKey.publicKey,
          secretKey: recipientKey.secretKey,
        );

        printOnFailure('restored: $restored');

        expect(restored, message);
      });

      test('fails if data is invalid', () {
        final senderKey = sut.keyPair();
        final recipientKey = sut.keyPair();
        final nonce = sodium.randombytes.buf(sut.nonceBytes);

        printOnFailure(
          'senderKey.secretKey: ${senderKey.secretKey.extractBytes()}',
        );
        printOnFailure('senderKey.publicKey: ${senderKey.publicKey}');
        printOnFailure(
          'recipientKey.secretKey: ${recipientKey.secretKey.extractBytes()}',
        );
        printOnFailure('recipientKey.publicKey: ${recipientKey.publicKey}');
        printOnFailure('nonce: $nonce');

        final cipher = sut.detached(
          message: Uint8List.fromList(const [1, 2, 3]),
          nonce: nonce,
          publicKey: recipientKey.publicKey,
          secretKey: senderKey.secretKey,
        );

        printOnFailure('cipher: $cipher');
        cipher.mac[0] = cipher.mac[0] ^ 0xFF;

        expect(
          () => sut.openDetached(
            cipherText: cipher.cipherText,
            mac: cipher.mac,
            nonce: nonce,
            publicKey: senderKey.publicKey,
            secretKey: recipientKey.secretKey,
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('precalculate', () {
      late PrecalculatedBox senderPreBox;
      late PrecalculatedBox recipientPreBox;

      setUp(() {
        final senderKey = sut.keyPair();
        final recipientKey = sut.keyPair();

        printOnFailure(
          'senderKey.secretKey: ${senderKey.secretKey.extractBytes()}',
        );
        printOnFailure('senderKey.publicKey: ${senderKey.publicKey}');
        printOnFailure(
          'recipientKey.secretKey: ${recipientKey.secretKey.extractBytes()}',
        );
        printOnFailure('recipientKey.publicKey: ${recipientKey.publicKey}');

        senderPreBox = sut.precalculate(
          publicKey: recipientKey.publicKey,
          secretKey: senderKey.secretKey,
        );
        recipientPreBox = sut.precalculate(
          publicKey: senderKey.publicKey,
          secretKey: recipientKey.secretKey,
        );
      });

      group('easy', () {
        test('can encrypt and decrypt data', () {
          final nonce = sodium.randombytes.buf(sut.nonceBytes);
          final message = Uint8List.fromList(
            List.generate(32, (index) => index * 2),
          );

          printOnFailure('nonce: $nonce');
          printOnFailure('message: $message');

          final cipherText = senderPreBox.easy(
            message: message,
            nonce: nonce,
          );

          printOnFailure('cipherText: $cipherText');

          final restored = recipientPreBox.openEasy(
            cipherText: cipherText,
            nonce: nonce,
          );

          printOnFailure('restored: $restored');

          expect(restored, message);
        });

        test('fails if data is invalid', () {
          final nonce = sodium.randombytes.buf(sut.nonceBytes);

          printOnFailure('nonce: $nonce');

          final cipherText = senderPreBox.easy(
            message: Uint8List.fromList(const [1, 2, 3]),
            nonce: nonce,
          );

          printOnFailure('cipherText: $cipherText');
          cipherText[0] = cipherText[0] ^ 0xFF;

          expect(
            () => recipientPreBox.openEasy(
              cipherText: cipherText,
              nonce: nonce,
            ),
            throwsA(isA<SodiumException>()),
          );
        });
      });

      group('detached', () {
        test('can encrypt and decrypt data', () {
          final nonce = sodium.randombytes.buf(sut.nonceBytes);
          final message = Uint8List.fromList(
            List.generate(32, (index) => index * 2),
          );

          printOnFailure('nonce: $nonce');
          printOnFailure('message: $message');

          final cipher = senderPreBox.detached(
            message: message,
            nonce: nonce,
          );

          printOnFailure('cipher: $cipher');

          final restored = recipientPreBox.openDetached(
            cipherText: cipher.cipherText,
            mac: cipher.mac,
            nonce: nonce,
          );

          printOnFailure('restored: $restored');

          expect(restored, message);
        });

        test('fails if data is invalid', () {
          final nonce = sodium.randombytes.buf(sut.nonceBytes);

          printOnFailure('nonce: $nonce');

          final cipher = senderPreBox.detached(
            message: Uint8List.fromList(const [1, 2, 3]),
            nonce: nonce,
          );

          printOnFailure('cipher: $cipher');
          cipher.mac[0] = cipher.mac[0] ^ 0xFF;

          expect(
            () => recipientPreBox.openDetached(
              cipherText: cipher.cipherText,
              mac: cipher.mac,
              nonce: nonce,
            ),
            throwsA(isA<SodiumException>()),
          );
        });
      });
    });

    group('seal', () {
      test('can encrypt and decrypt data', () {
        final recipientKey = sut.keyPair();
        final message = Uint8List.fromList(
          List.generate(32, (index) => index * 2),
        );

        printOnFailure(
          'recipientKey.secretKey: ${recipientKey.secretKey.extractBytes()}',
        );
        printOnFailure('recipientKey.publicKey: ${recipientKey.publicKey}');
        printOnFailure('message: $message');

        final cipherText = sut.seal(
          message: message,
          publicKey: recipientKey.publicKey,
        );

        printOnFailure('cipherText: $cipherText');

        final restored = sut.sealOpen(
          cipherText: cipherText,
          publicKey: recipientKey.publicKey,
          secretKey: recipientKey.secretKey,
        );

        printOnFailure('restored: $restored');

        expect(restored, message);
      });

      test('fails if data is invalid', () {
        final recipientKey = sut.keyPair();

        printOnFailure(
          'recipientKey.secretKey: ${recipientKey.secretKey.extractBytes()}',
        );
        printOnFailure('recipientKey.publicKey: ${recipientKey.publicKey}');

        final cipherText = sut.seal(
          message: Uint8List.fromList(const [1, 2, 3]),
          publicKey: recipientKey.publicKey,
        );

        printOnFailure('cipherText: $cipherText');
        cipherText[0] = cipherText[0] ^ 0xFF;

        expect(
          () => sut.sealOpen(
            cipherText: cipherText,
            publicKey: recipientKey.publicKey,
            secretKey: recipientKey.secretKey,
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });
  }
}
