import 'dart:typed_data';

// dart_pre_commit:ignore-library-import
import 'package:sodium/sodium.dart';
import 'package:test/test.dart';

import '../test_case.dart';

class ShortHashTestCase extends TestCase {
  @override
  String get name => 'shorthash';

  ShortHash get sut => sodium.crypto.shortHash;

  @override
  void setupTests() {
    test('constants return correct values', () {
      expect(sut.bytes, 8, reason: 'bytes');
      expect(sut.keyBytes, 16, reason: 'keyBytes');
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

    group('hash', () {
      test('generates same hash for same data and key', () {
        final key = sut.keygen();
        final message = Uint8List.fromList(
          List.generate(64, (index) => index + 32),
        );

        printOnFailure('message: $message');

        final hash1 = sut(
          message: message,
          key: key,
        );
        final hash2 = sut(
          message: message,
          key: key,
        );

        printOnFailure('hash1: $hash1');
        printOnFailure('hash2: $hash2');

        expect(hash1, hasLength(sut.bytes));
        expect(hash2, hasLength(sut.bytes));

        expect(hash1, hash2);
      });
      test('generates same hash for different keys', () {
        final key1 = sut.keygen();
        final key2 = sut.keygen();
        final message = Uint8List.fromList(
          List.generate(64, (index) => index + 32),
        );

        printOnFailure('message: $message');

        final hash1 = sut(
          message: message,
          key: key1,
        );
        final hash2 = sut(
          message: message,
          key: key2,
        );

        printOnFailure('hash1: $hash1');
        printOnFailure('hash2: $hash2');

        expect(hash1, hasLength(sut.bytes));
        expect(hash2, hasLength(sut.bytes));

        expect(hash1, isNot(hash2));
      });
    });
  }
}
