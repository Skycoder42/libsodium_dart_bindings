import 'dart:typed_data';

import '../test_case.dart';

class ShortHashTestCase extends TestCase {
  ShortHashTestCase(super._runner);

  @override
  String get name => 'shorthash';

  @override
  void setupTests() {
    test('constants return correct values', (sodium) {
      final sut = sodium.crypto.shortHash;

      expect(sut.bytes, 8, reason: 'bytes');
      expect(sut.keyBytes, 16, reason: 'keyBytes');
    });

    test('keygen generates different correct length keys', (sodium) {
      final sut = sodium.crypto.shortHash;

      final key1 = sut.keygen();
      final key2 = sut.keygen();

      printOnFailure('key1: ${key1.extractBytes()}');
      printOnFailure('key2: ${key2.extractBytes()}');

      expect(key1, hasLength(sut.keyBytes));
      expect(key2, hasLength(sut.keyBytes));

      expect(key1, isNot(key2));
    });

    group('hash', () {
      test('generates same hash for same data and key', (sodium) {
        final sut = sodium.crypto.shortHash;

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
      test('generates same hash for different keys', (sodium) {
        final sut = sodium.crypto.shortHash;

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
