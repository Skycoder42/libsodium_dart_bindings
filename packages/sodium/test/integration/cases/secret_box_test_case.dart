import 'dart:typed_data';

// ignore: test_library_import
import 'package:sodium/sodium.dart';

import '../test_case.dart';

class SecretBoxTestCase extends TestCase {
  SecretBoxTestCase(super.runner);

  @override
  String get name => 'secretbox';

  SecretBox get sut => sodium.crypto.secretBox;

  @override
  void setupTests() {
    test('constants return correct values', () {
      expect(sut.keyBytes, 32, reason: 'keyBytes');
      expect(sut.macBytes, 16, reason: 'macBytes');
      expect(sut.nonceBytes, 24, reason: 'nonceBytes');
    });

    test('keygen generates different correct length keys', () {
      final key1 = sut.keygen();
      final key2 = sut.keygen();

      printOnFailure('key1: ${key1.extractBytes()}');
      printOnFailure('key2: ${key2.extractBytes()}');

      expect(key1, hasLength(32));
      expect(key2, hasLength(32));

      expect(key1, isNot(key2));
    });

    group('easy', () {
      test('can encrypt and decrypt data', () {
        final key = sut.keygen();
        final nonce = sodium.randombytes.buf(sut.nonceBytes);
        final message = Uint8List.fromList(
          List.generate(32, (index) => index * 2),
        );

        printOnFailure('key: ${key.extractBytes()}');
        printOnFailure('nonce: $nonce');
        printOnFailure('message: $message');

        final cipherText = sut.easy(
          message: message,
          nonce: nonce,
          key: key,
        );

        printOnFailure('cipherText: $cipherText');

        final restored = sut.openEasy(
          cipherText: cipherText,
          nonce: nonce,
          key: key,
        );

        printOnFailure('restored: $restored');

        expect(restored, message);
      });

      test('fails if data is invalid', () {
        final key = sut.keygen();
        final nonce = sodium.randombytes.buf(sut.nonceBytes);

        printOnFailure('key: ${key.extractBytes()}');
        printOnFailure('nonce: $nonce');

        final cipherText = sut.easy(
          message: Uint8List.fromList(const [1, 2, 3]),
          nonce: nonce,
          key: key,
        );

        printOnFailure('cipherText: $cipherText');
        cipherText[0] = cipherText[0] ^ 0xFF;

        expect(
          () => sut.openEasy(
            cipherText: cipherText,
            nonce: nonce,
            key: key,
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('detached', () {
      test('can encrypt and decrypt data', () {
        final key = sut.keygen();
        final nonce = sodium.randombytes.buf(sut.nonceBytes);
        final message = Uint8List.fromList(
          List.generate(32, (index) => index * 2),
        );

        printOnFailure('key: ${key.extractBytes()}');
        printOnFailure('nonce: $nonce');
        printOnFailure('message: $message');

        final cipher = sut.detached(
          message: message,
          nonce: nonce,
          key: key,
        );

        printOnFailure('cipher: $cipher');

        final restored = sut.openDetached(
          cipherText: cipher.cipherText,
          mac: cipher.mac,
          nonce: nonce,
          key: key,
        );

        printOnFailure('restored: $restored');

        expect(restored, message);
      });

      test('fails if data is invalid', () {
        final key = sut.keygen();
        final nonce = sodium.randombytes.buf(sut.nonceBytes);

        printOnFailure('key: ${key.extractBytes()}');
        printOnFailure('nonce: $nonce');

        final cipher = sut.detached(
          message: Uint8List.fromList(const [1, 2, 3]),
          nonce: nonce,
          key: key,
        );

        printOnFailure('cipherText: $cipher');
        cipher.mac[0] = cipher.mac[0] ^ 0xFF;

        expect(
          () => sut.openDetached(
            cipherText: cipher.cipherText,
            mac: cipher.mac,
            nonce: nonce,
            key: key,
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });
  }
}
