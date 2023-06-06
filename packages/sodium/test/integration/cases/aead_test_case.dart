import 'dart:typed_data';

// ignore: no_self_package_imports
import 'package:sodium/sodium.dart';

import '../test_case.dart';

class AeadTestCase extends TestCase {
  AeadTestCase(super._runner);

  @override
  String get name => 'aead';

  @override
  void setupTests() {
    test('constants return correct values', (sodium) {
      final sut = sodium.crypto.aead;

      expect(sut.keyBytes, 32, reason: 'keyBytes');
      expect(sut.nonceBytes, 24, reason: 'nonceBytes');
      expect(sut.aBytes, 16, reason: 'aBytes');
    });

    test('keygen generates different correct length keys', (sodium) {
      final sut = sodium.crypto.aead;

      final key1 = sut.keygen();
      final key2 = sut.keygen();

      printOnFailure('key1: ${key1.extractBytes()}');
      printOnFailure('key2: ${key2.extractBytes()}');

      expect(key1, hasLength(sut.keyBytes));
      expect(key2, hasLength(sut.keyBytes));

      expect(key1, isNot(key2));
    });

    group('easy', () {
      test('can encrypt and decrypt data without additional data', (sodium) {
        final sut = sodium.crypto.aead;

        final key = sut.keygen();
        final nonce = sodium.randombytes.buf(sut.nonceBytes);
        final message = Uint8List.fromList(
          List.generate(32, (index) => index * 2),
        );

        printOnFailure('key: ${key.extractBytes()}');
        printOnFailure('nonce: $nonce');
        printOnFailure('message: $message');

        final cipherText = sut.encrypt(
          message: message,
          nonce: nonce,
          key: key,
        );

        printOnFailure('cipherText: $cipherText');

        final restored = sut.decrypt(
          cipherText: cipherText,
          nonce: nonce,
          key: key,
        );

        printOnFailure('restored: $restored');

        expect(restored, message);
      });

      test('can encrypt and decrypt data with additional data', (sodium) {
        final sut = sodium.crypto.aead;

        final key = sut.keygen();
        final nonce = sodium.randombytes.buf(sut.nonceBytes);
        final message = Uint8List.fromList(
          List.generate(32, (index) => index * 2),
        );
        final additionalData = Uint8List.fromList(
          List.generate(22, (index) => 100 - index),
        );

        printOnFailure('key: ${key.extractBytes()}');
        printOnFailure('nonce: $nonce');
        printOnFailure('message: $message');
        printOnFailure('additionalData: $additionalData');

        final cipherText = sut.encrypt(
          message: message,
          additionalData: additionalData,
          nonce: nonce,
          key: key,
        );

        printOnFailure('cipherText: $cipherText');

        final restored = sut.decrypt(
          cipherText: cipherText,
          additionalData: additionalData,
          nonce: nonce,
          key: key,
        );

        printOnFailure('restored: $restored');

        expect(restored, message);
      });

      test('fails if additional data is different', (sodium) {
        final sut = sodium.crypto.aead;

        final key = sut.keygen();
        final nonce = sodium.randombytes.buf(sut.nonceBytes);
        final message = Uint8List.fromList(
          List.generate(32, (index) => index * 2),
        );
        final additionalData1 = Uint8List.fromList(
          List.generate(22, (index) => 100 - index),
        );

        final additionalData2 = Uint8List.fromList(
          List.generate(22, (index) => 200 - index),
        );

        printOnFailure('key: ${key.extractBytes()}');
        printOnFailure('nonce: $nonce');
        printOnFailure('message: $message');
        printOnFailure('additionalData1: $additionalData1');
        printOnFailure('additionalData2: $additionalData2');

        final cipherText = sut.encrypt(
          message: message,
          additionalData: additionalData1,
          nonce: nonce,
          key: key,
        );

        printOnFailure('cipherText: $cipherText');

        expect(
          () => sut.decrypt(
            cipherText: cipherText,
            additionalData: additionalData2,
            nonce: nonce,
            key: key,
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('detached', () {
      test('can encrypt and decrypt data without additional data', (sodium) {
        final sut = sodium.crypto.aead;

        final key = sut.keygen();
        final nonce = sodium.randombytes.buf(sut.nonceBytes);
        final message = Uint8List.fromList(
          List.generate(32, (index) => index * 2),
        );

        printOnFailure('key: ${key.extractBytes()}');
        printOnFailure('nonce: $nonce');
        printOnFailure('message: $message');

        final cipher = sut.encryptDetached(
          message: message,
          nonce: nonce,
          key: key,
        );

        printOnFailure('cipher: $cipher');

        final restored = sut.decryptDetached(
          cipherText: cipher.cipherText,
          mac: cipher.mac,
          nonce: nonce,
          key: key,
        );

        printOnFailure('restored: $restored');

        expect(restored, message);
      });

      test('can encrypt and decrypt data with additional data', (sodium) {
        final sut = sodium.crypto.aead;

        final key = sut.keygen();
        final nonce = sodium.randombytes.buf(sut.nonceBytes);
        final message = Uint8List.fromList(
          List.generate(32, (index) => index * 2),
        );
        final additionalData = Uint8List.fromList(
          List.generate(22, (index) => 100 - index),
        );

        printOnFailure('key: ${key.extractBytes()}');
        printOnFailure('nonce: $nonce');
        printOnFailure('message: $message');
        printOnFailure('additionalData: $additionalData');

        final cipher = sut.encryptDetached(
          message: message,
          additionalData: additionalData,
          nonce: nonce,
          key: key,
        );

        printOnFailure('cipher: $cipher');

        final restored = sut.decryptDetached(
          cipherText: cipher.cipherText,
          mac: cipher.mac,
          additionalData: additionalData,
          nonce: nonce,
          key: key,
        );

        printOnFailure('restored: $restored');

        expect(restored, message);
      });

      test('fails if additional data is different', (sodium) {
        final sut = sodium.crypto.aead;

        final key = sut.keygen();
        final nonce = sodium.randombytes.buf(sut.nonceBytes);
        final message = Uint8List.fromList(
          List.generate(32, (index) => index * 2),
        );
        final additionalData1 = Uint8List.fromList(
          List.generate(22, (index) => 100 - index),
        );

        final additionalData2 = Uint8List.fromList(
          List.generate(22, (index) => 200 - index),
        );

        printOnFailure('key: ${key.extractBytes()}');
        printOnFailure('nonce: $nonce');
        printOnFailure('message: $message');
        printOnFailure('additionalData1: $additionalData1');
        printOnFailure('additionalData2: $additionalData2');

        final cipher = sut.encryptDetached(
          message: message,
          additionalData: additionalData1,
          nonce: nonce,
          key: key,
        );

        printOnFailure('cipher: $cipher');

        expect(
          () => sut.decryptDetached(
            cipherText: cipher.cipherText,
            mac: cipher.mac,
            additionalData: additionalData2,
            nonce: nonce,
            key: key,
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });
  }
}
