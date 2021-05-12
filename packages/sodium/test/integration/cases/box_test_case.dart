import 'dart:typed_data';

// dart_pre_commit:ignore-library-import
import 'package:sodium/sodium.dart';
import 'package:test/test.dart';

import '../test_case.dart';

class BoxTestCase extends TestCase {
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
    });

    test('keygen generates different correct length keys', () {
      final key1 = sut.keyPair();
      final key2 = sut.keyPair();

      printOnFailure('key1.secretKey: ${key1.secretKey.extractBytes()}');
      printOnFailure('key1.publicKey: ${key1.publicKey}');
      printOnFailure('key2.secretKey: ${key2.secretKey.extractBytes()}');
      printOnFailure('key2.publicKey: ${key2.publicKey}');

      expect(key1.secretKey, hasLength(32));
      expect(key1.publicKey, hasLength(32));
      expect(key2.secretKey, hasLength(32));
      expect(key2.publicKey, hasLength(32));

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

        expect(key1.secretKey, hasLength(32));
        expect(key1.publicKey, hasLength(32));
        expect(key2.secretKey, hasLength(32));
        expect(key2.publicKey, hasLength(32));

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

        expect(key1.secretKey, hasLength(32));
        expect(key1.publicKey, hasLength(32));
        expect(key2.secretKey, hasLength(32));
        expect(key2.publicKey, hasLength(32));

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
          recipientPublicKey: recipientKey.publicKey,
          senderSecretKey: senderKey.secretKey,
        );

        printOnFailure('cipherText: $cipherText');

        final restored = sut.openEasy(
          cipherText: cipherText,
          nonce: nonce,
          senderPublicKey: senderKey.publicKey,
          recipientSecretKey: recipientKey.secretKey,
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
          recipientPublicKey: recipientKey.publicKey,
          senderSecretKey: senderKey.secretKey,
        );

        printOnFailure('cipherText: $cipherText');
        cipherText[0] = cipherText[0] ^ 0xFF;

        expect(
          () => sut.openEasy(
            cipherText: cipherText,
            nonce: nonce,
            senderPublicKey: senderKey.publicKey,
            recipientSecretKey: recipientKey.secretKey,
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
          recipientPublicKey: recipientKey.publicKey,
          senderSecretKey: senderKey.secretKey,
        );

        printOnFailure('cipher: $cipher');

        final restored = sut.openDetached(
          cipherText: cipher.cipherText,
          mac: cipher.mac,
          nonce: nonce,
          senderPublicKey: senderKey.publicKey,
          recipientSecretKey: recipientKey.secretKey,
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
          recipientPublicKey: recipientKey.publicKey,
          senderSecretKey: senderKey.secretKey,
        );

        printOnFailure('cipher: $cipher');
        cipher.mac[0] = cipher.mac[0] ^ 0xFF;

        expect(
          () => sut.openDetached(
            cipherText: cipher.cipherText,
            mac: cipher.mac,
            nonce: nonce,
            senderPublicKey: senderKey.publicKey,
            recipientSecretKey: recipientKey.secretKey,
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });
  }
}
