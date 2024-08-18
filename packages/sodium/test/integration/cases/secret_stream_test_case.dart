import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

// ignore: no_self_package_imports
import 'package:sodium/sodium.dart';

import '../test_case.dart';

class SecretStreamTestCase extends TestCase {
  SecretStreamTestCase(super._runner);

  @override
  String get name => 'secretstream';

  @override
  void setupTests() {
    test('constants return correct values', (sodium) {
      final sut = sodium.crypto.secretStream;

      expect(sut.aBytes, 17, reason: 'aBytes');
      expect(sut.headerBytes, 24, reason: 'headerBytes');
      expect(sut.keyBytes, 32, reason: 'keyBytes');
    });

    test('keygen generates different correct length keys', (sodium) {
      final sut = sodium.crypto.secretStream;

      final key1 = sut.keygen();
      final key2 = sut.keygen();

      printOnFailure('key1: ${key1.extractBytes()}');
      printOnFailure('key2: ${key2.extractBytes()}');

      expect(key1, hasLength(32));
      expect(key2, hasLength(32));

      expect(key1, isNot(key2));
    });

    test('chunked correctly transforms simple filestream', (sodium) async {
      final sut = sodium.crypto.secretStream;
      final rand = Random.secure();

      final testDir = await Directory.systemTemp.createTemp();
      addTearDown(() => testDir.delete(recursive: true));
      final plainFile = File.fromUri(testDir.uri.resolve('plain.bin'));
      final cipherFile = File.fromUri(testDir.uri.resolve('cipher.bin'));
      final restoredFile = File.fromUri(testDir.uri.resolve('restored.bin'));

      await plainFile.writeAsBytes(
        List.generate(
          10 * 1024 * 1024 + 3, // 10 MB
          (_) => rand.nextInt(256),
        ),
        flush: true,
      );

      const chunkSize = 4094; // 4 KB
      final key = sut.keygen();

      final cipherStream = sut.pushChunked(
        messageStream: plainFile.openRead(),
        chunkSize: chunkSize,
        key: key,
      );
      final cipherSink = cipherFile.openWrite();
      try {
        await cipherStream.pipe(cipherSink);
        await cipherSink.flush();
      } finally {
        await cipherSink.close();
      }

      expect(cipherFile.lengthSync(), 10529341);

      final restoredStream = sut.pullChunked(
        cipherStream: cipherFile.openRead(),
        chunkSize: chunkSize,
        key: key,
      );
      final restoredSink = restoredFile.openWrite();
      try {
        await restoredStream.pipe(restoredSink);
        await restoredSink.flush();
      } finally {
        await restoredSink.close();
      }

      expect(
        await restoredFile.readAsBytes(),
        await plainFile.readAsBytes(),
      );
    });

    group('extended', () {
      test('correctly transforms complex datastream', (sodium) async {
        final sut = sodium.crypto.secretStream;

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

      test('works with manual rekey', (sodium) async {
        final sut = sodium.crypto.secretStream;

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

      test('fails for broken rekey', (sodium) async {
        final sut = sodium.crypto.secretStream;

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
