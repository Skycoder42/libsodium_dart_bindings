import 'dart:typed_data';

// dart_pre_commit:ignore-library-import
import 'package:sodium/sodium.dart';

import '../test_case.dart';
import '../test_runner.dart';

class AuthTestCase extends TestCase {
  AuthTestCase(TestRunner runner) : super(runner);

  @override
  String get name => 'auth';

  Auth get sut => sodium.crypto.auth;

  @override
  void setupTests() {
    test('constants return correct values', () {
      expect(sut.bytes, 32, reason: 'bytes');
      expect(sut.keyBytes, 32, reason: 'keyBytes');
    });

    test('keygen generates different correct length keys', () {
      final key1 = sut.keygen();
      final key2 = sut.keygen();

      printOnFailure('key1: ${key1.extractBytes()}');
      printOnFailure('key2: ${key2.extractBytes()}');

      expect(key1, hasLength(sut.keyBytes));
      expect(key2, hasLength(sut.keyBytes));

      expect(key1, isNot(key2));
    });

    test('can create and verify auth tag', () {
      final key = sut.keygen();
      final message = Uint8List.fromList(
        List.generate(32, (index) => index * 2),
      );

      printOnFailure('key: ${key.extractBytes()}');
      printOnFailure('message: $message');

      final tag = sut(
        message: message,
        key: key,
      );

      printOnFailure('tag: $tag');

      final verified = sut.verify(
        tag: tag,
        message: message,
        key: key,
      );

      expect(verified, isTrue);
    });

    test('fails if tag is invalid', () {
      final key = sut.keygen();
      final message = Uint8List.fromList(
        List.generate(32, (index) => index * 2),
      );

      printOnFailure('key: ${key.extractBytes()}');
      printOnFailure('message: $message');

      final tag = sut(
        message: message,
        key: key,
      );

      printOnFailure('tag: $tag');

      tag[0] = tag[0] ^ 0xFF;
      final verified = sut.verify(
        tag: tag,
        message: message,
        key: key,
      );

      expect(verified, isFalse);
    });
  }
}
