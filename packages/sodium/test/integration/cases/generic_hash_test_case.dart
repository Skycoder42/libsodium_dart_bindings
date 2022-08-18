import 'dart:typed_data';

// ignore: test_library_import
import 'package:sodium/sodium.dart';

import '../test_case.dart';

class GenericHashTestCase extends TestCase {
  GenericHashTestCase(super.runner);

  @override
  String get name => 'generichash';

  GenericHash get sut => sodium.crypto.genericHash;

  @override
  void setupTests() {
    test('constants return correct values', () {
      expect(sut.bytes, 32, reason: 'bytes');
      expect(sut.bytesMin, 16, reason: 'bytesMin');
      expect(sut.bytesMax, 64, reason: 'bytesMax');
      expect(sut.keyBytes, 32, reason: 'keyBytes');
      expect(sut.keyBytesMin, 16, reason: 'keyBytesMin');
      expect(sut.keyBytesMax, 64, reason: 'keyBytesMax');
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
      test('generates same hash for same data', () {
        final message = Uint8List.fromList(
          List.generate(64, (index) => index + 32),
        );

        printOnFailure('message: $message');

        final hash1 = sut(message: message);
        final hash2 = sut(message: message);

        printOnFailure('hash1: $hash1');
        printOnFailure('hash2: $hash2');

        expect(hash1, hasLength(sut.bytes));
        expect(hash2, hasLength(sut.bytes));

        expect(hash1, hash2);
      });

      test('generates different hashes for different data', () {
        final message1 = Uint8List.fromList(
          List.generate(64, (index) => index + 32),
        );
        final message2 = Uint8List.fromList(
          List.generate(64, (index) => index - 32),
        );

        printOnFailure('message1: $message1');
        printOnFailure('message2: $message2');

        final hash1 = sut(message: message1);
        final hash2 = sut(message: message2);

        printOnFailure('hash1: $hash1');
        printOnFailure('hash2: $hash2');

        expect(hash1, hasLength(sut.bytes));
        expect(hash2, hasLength(sut.bytes));

        expect(hash1, isNot(hash2));
      });

      test('generates same hash for same key', () {
        final key = sut.keygen();
        final message = Uint8List.fromList(
          List.generate(64, (index) => index),
        );

        printOnFailure('message: $message');

        final hash1 = sut(
          message: message,
          outLen: sut.bytesMax,
          key: key,
        );
        final hash2 = sut(
          message: message,
          outLen: sut.bytesMax,
          key: key,
        );

        printOnFailure('hash1: $hash1');
        printOnFailure('hash2: $hash2');

        expect(hash1, hasLength(sut.bytesMax));
        expect(hash2, hasLength(sut.bytesMax));

        expect(hash1, hash2);
      });

      test('generates different hashes for different keys', () {
        final key1 = sut.keygen();
        final key2 = sut.keygen();
        final message = Uint8List.fromList(
          List.generate(64, (index) => index),
        );

        printOnFailure('message: $message');

        final hash1 = sut(
          message: message,
          outLen: sut.bytesMin,
          key: key1,
        );
        final hash2 = sut(
          message: message,
          outLen: sut.bytesMin,
          key: key2,
        );

        printOnFailure('hash1: $hash1');
        printOnFailure('hash2: $hash2');

        expect(hash1, hasLength(sut.bytesMin));
        expect(hash2, hasLength(sut.bytesMin));

        expect(hash1, isNot(hash2));
      });
    });

    group('stream', () {
      test('generates same hash for same data', () async {
        final messages = List.generate(
          10,
          (i) => Uint8List.fromList(
            List.generate(32, (j) => i + j),
          ),
        );

        printOnFailure('message: $messages');

        final hash1 = await sut.stream(messages: Stream.fromIterable(messages));
        final hash2 = await sut.stream(messages: Stream.fromIterable(messages));

        printOnFailure('hash1: $hash1');
        printOnFailure('hash2: $hash2');

        expect(hash1, hasLength(sut.bytes));
        expect(hash2, hasLength(sut.bytes));

        expect(hash1, hash2);
      });

      test('generates different hashes for different data', () async {
        final messages1 = List.generate(
          10,
          (i) => Uint8List.fromList(
            List.generate(20, (j) => i + j),
          ),
        );
        final messages2 = List.generate(
          10,
          (i) => Uint8List.fromList(
            List.generate(20, (j) => i * j),
          ),
        );

        printOnFailure('message1: $messages1');
        printOnFailure('message2: $messages2');

        final hash1 = await sut.stream(
          messages: Stream.fromIterable(messages1),
        );
        final hash2 = await sut.stream(
          messages: Stream.fromIterable(messages2),
        );

        printOnFailure('hash1: $hash1');
        printOnFailure('hash2: $hash2');

        expect(hash1, hasLength(sut.bytes));
        expect(hash2, hasLength(sut.bytes));

        expect(hash1, isNot(hash2));
      });

      test('generates same hash for same key', () async {
        final key = sut.keygen();
        final messages = List.generate(
          10,
          (i) => Uint8List.fromList(
            List.generate(32, (j) => i + j),
          ),
        );

        printOnFailure('message: $messages');

        final hash1 = await sut.stream(
          messages: Stream.fromIterable(messages),
          outLen: sut.bytesMax,
          key: key,
        );
        final hash2 = await sut.stream(
          messages: Stream.fromIterable(messages),
          outLen: sut.bytesMax,
          key: key,
        );

        printOnFailure('hash1: $hash1');
        printOnFailure('hash2: $hash2');

        expect(hash1, hasLength(sut.bytesMax));
        expect(hash2, hasLength(sut.bytesMax));

        expect(hash1, hash2);
      });

      test('generates different hashes for different keys', () async {
        final key1 = sut.keygen();
        final key2 = sut.keygen();
        final messages = List.generate(
          10,
          (i) => Uint8List.fromList(
            List.generate(32, (j) => i + j),
          ),
        );

        printOnFailure('message: $messages');

        final hash1 = await sut.stream(
          messages: Stream.fromIterable(messages),
          outLen: sut.bytesMin,
          key: key1,
        );
        final hash2 = await sut.stream(
          messages: Stream.fromIterable(messages),
          outLen: sut.bytesMin,
          key: key2,
        );

        printOnFailure('hash1: $hash1');
        printOnFailure('hash2: $hash2');

        expect(hash1, hasLength(sut.bytesMin));
        expect(hash2, hasLength(sut.bytesMin));

        expect(hash1, isNot(hash2));
      });
    });
  }
}
