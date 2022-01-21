import 'dart:async';
import 'dart:typed_data';

// ignore: test_library_import
import 'package:sodium/sodium.dart';

import '../test_case.dart';
import '../test_runner.dart';

class SecretStreamTestCase extends TestCase {
  SecretStreamTestCase(TestRunner runner) : super(runner);

  @override
  String get name => 'secretstream';

  SecretStream get sut => sodium.crypto.secretStream;

  @override
  void setupTests() {
    test('constants return correct values', () {
      expect(sut.aBytes, 17, reason: 'aBytes');
      expect(sut.headerBytes, 24, reason: 'headerBytes');
      expect(sut.keyBytes, 32, reason: 'keyBytes');
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

    test('simple correctly transforms simple datastream', () async {
      final key = sut.keygen();
      final plainEvents = [
        Uint8List.fromList(const [1, 2, 3]),
        Uint8List.fromList(const [4, 5]),
        Uint8List.fromList(const [6, 7, 8, 9]),
      ];

      final cipherStream = sut.push(
        messageStream: Stream.fromIterable(plainEvents),
        key: key,
      );

      final cipherEvents = await cipherStream.toList();
      printOnFailure(cipherEvents.toString());
      expect(cipherEvents, hasLength(plainEvents.length + 2));

      final restoredStream = sut.pull(
        cipherStream: Stream.fromIterable(cipherEvents),
        key: key,
      );

      final result = await restoredStream.toList();
      expect(result, plainEvents);
    });

    group('extended', () {
      test('correctly transforms complex datastream', () async {
        final key = sut.keygen();
        final plainEvents = [
          SecretStreamPlainMessage(Uint8List.fromList(const [1, 2, 3])),
          SecretStreamPlainMessage(Uint8List.fromList(const [3, 2, 1])),
          SecretStreamPlainMessage(
            Uint8List.fromList(const [4, 5]),
            additionalData: Uint8List.fromList(const [0, 10, 100]),
            tag: SecretStreamMessageTag.push,
          ),
          SecretStreamPlainMessage(
            Uint8List.fromList(const [6, 7, 8, 9]),
            tag: SecretStreamMessageTag.rekey,
          ),
          SecretStreamPlainMessage(Uint8List.fromList(const [6, 6, 6])),
          SecretStreamPlainMessage(
            Uint8List.fromList(const [10, 11, 12]),
            tag: SecretStreamMessageTag.finalPush,
          ),
        ];

        final cipherStream = sut.pushEx(
          messageStream: Stream.fromIterable(plainEvents),
          key: key,
        );

        final cipherEvents = await cipherStream.toList();
        printOnFailure(cipherEvents.toString());
        expect(cipherEvents, hasLength(plainEvents.length + 1));

        final restoredStream = sut.pullEx(
          cipherStream: Stream.fromIterable(cipherEvents),
          key: key,
        );

        final result = await restoredStream.toList();
        expect(result, plainEvents);
      });

      test('works with manual rekey', () async {
        final plainEvents = [
          SecretStreamPlainMessage(Uint8List.fromList(const [1, 1, 1])),
          SecretStreamPlainMessage(Uint8List.fromList(const [2, 2, 2])),
          SecretStreamPlainMessage(Uint8List.fromList(const [3, 3, 3])),
          SecretStreamPlainMessage(
            Uint8List.fromList(const [4, 4, 4]),
            tag: SecretStreamMessageTag.finalPush,
          ),
        ];

        final key = sut.keygen();
        final controller = StreamController<SecretStreamPlainMessage>();

        final cipherStream = sut.pushEx(
          messageStream: controller.stream,
          key: key,
        );

        final restoredStream = sut.pullEx(
          cipherStream: cipherStream,
          key: key,
        );

        expect(restoredStream, emitsInOrder(plainEvents));

        controller
          ..add(plainEvents[0])
          ..add(plainEvents[1]);
        await Future<void>.delayed(const Duration(milliseconds: 100));

        cipherStream.rekey();
        restoredStream.rekey();

        controller
          ..add(plainEvents[2])
          ..add(plainEvents[3]);
        await controller.close();
      });

      test('fails for broken rekey', () async {
        final plainEvents = [
          SecretStreamPlainMessage(Uint8List.fromList(const [1, 1, 1])),
          SecretStreamPlainMessage(Uint8List.fromList(const [2, 2, 2])),
          SecretStreamPlainMessage(Uint8List.fromList(const [3, 3, 3])),
          SecretStreamPlainMessage(
            Uint8List.fromList(const [4, 4, 4]),
            tag: SecretStreamMessageTag.finalPush,
          ),
        ];

        final key = sut.keygen();
        final controller = StreamController<SecretStreamPlainMessage>();

        final cipherStream = sut.pushEx(
          messageStream: controller.stream,
          key: key,
        );

        final restoredStream = sut.pullEx(
          cipherStream: cipherStream,
          key: key,
        );

        expect(restoredStream, emitsError(isA<SodiumException>()));

        controller
          ..add(plainEvents[0])
          ..add(plainEvents[1]);
        cipherStream.rekey();
        controller
          ..add(plainEvents[2])
          ..add(plainEvents[3]);
        await controller.close();
      });
    });
  }
}
