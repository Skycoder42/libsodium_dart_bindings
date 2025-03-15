import 'dart:typed_data';

import '../test_case.dart';

class AuthTestCase extends TestCase {
  AuthTestCase(super._runner);

  @override
  String get name => 'auth';

  @override
  void setupTests() {
    test('constants return correct values', (sodium) {
      final sut = sodium.crypto.auth;

      expect(sut.bytes, 32, reason: 'bytes');
      expect(sut.keyBytes, 32, reason: 'keyBytes');
    });

    test('keygen generates different correct length keys', (sodium) {
      final sut = sodium.crypto.auth;

      final key1 = sut.keygen();
      final key2 = sut.keygen();

      printOnFailure('key1: ${key1.extractBytes()}');
      printOnFailure('key2: ${key2.extractBytes()}');

      expect(key1, hasLength(sut.keyBytes));
      expect(key2, hasLength(sut.keyBytes));

      expect(key1, isNot(key2));
    });

    test('can create and verify auth tag', (sodium) {
      final sut = sodium.crypto.auth;

      final key = sut.keygen();
      final message = Uint8List.fromList(
        List.generate(32, (index) => index * 2),
      );

      printOnFailure('key: ${key.extractBytes()}');
      printOnFailure('message: $message');

      final tag = sut(message: message, key: key);

      printOnFailure('tag: $tag');

      final verified = sut.verify(tag: tag, message: message, key: key);

      expect(verified, isTrue);
    });

    test('fails if tag is invalid', (sodium) {
      final sut = sodium.crypto.auth;

      final key = sut.keygen();
      final message = Uint8List.fromList(
        List.generate(32, (index) => index * 2),
      );

      printOnFailure('key: ${key.extractBytes()}');
      printOnFailure('message: $message');

      final tag = sut(message: message, key: key);

      printOnFailure('tag: $tag');

      tag[0] = tag[0] ^ 0xFF;
      final verified = sut.verify(tag: tag, message: message, key: key);

      expect(verified, isFalse);
    });
  }
}
