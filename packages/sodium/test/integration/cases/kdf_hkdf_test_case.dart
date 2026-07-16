import 'dart:math';
import 'dart:typed_data';

import '../test_case.dart';

class KdfHkdfTestCase extends TestCase {
  KdfHkdfTestCase(super._runner);

  @override
  String get name => 'kdf_hkdf';

  @override
  void setupTests() {
    group('sha256', () {
      test('constants return correct values', (sodium) {
        final sut = sodium.crypto.kdfHkdfSha256;

        expect(sut.keyBytes, 32, reason: 'keyBytes');
        expect(sut.bytesMin, 0, reason: 'bytesMin');
        expect(sut.bytesMax, 8160, reason: 'bytesMax');
      });

      test('keygen', (sodium) {
        final sut = sodium.crypto.kdfHkdfSha256;

        final key1 = sut.keygen();
        final key2 = sut.keygen();

        printOnFailure('key1: ${key1.extractBytes()}');
        printOnFailure('key2: ${key2.extractBytes()}');

        expect(key1, hasLength(sut.keyBytes));
        expect(key2, hasLength(sut.keyBytes));

        expect(key1, isNot(key2));
      });

      group('extract', () {
        test('generates master key from ikm', (sodium) {
          final sut = sodium.crypto.kdfHkdfSha256;

          final ikm = Uint8List.fromList(List.generate(32, (index) => index));

          printOnFailure('ikm: $ikm');

          final masterKey1 = sut.extract(ikm: ikm);
          final masterKey2 = sut.extract(ikm: ikm);

          printOnFailure('masterKey1: ${masterKey1.extractBytes()}');
          printOnFailure('masterKey2: ${masterKey2.extractBytes()}');

          expect(masterKey1, hasLength(sut.keyBytes));
          expect(masterKey2, hasLength(sut.keyBytes));
          expect(masterKey1, equals(masterKey2));
        });

        test('generates different keys for different salts', (sodium) {
          final sut = sodium.crypto.kdfHkdfSha256;

          final ikm = Uint8List.fromList(List.generate(32, (index) => index));
          final salt1 = Uint8List.fromList(List.generate(16, (index) => index));
          final salt2 = Uint8List.fromList(
            List.generate(16, (index) => index + 1),
          );

          printOnFailure('ikm: $ikm');
          printOnFailure('salt1: $salt1');
          printOnFailure('salt2: $salt2');

          final masterKey1 = sut.extract(ikm: ikm, salt: salt1);
          final masterKey2 = sut.extract(ikm: ikm, salt: salt2);

          printOnFailure('masterKey1: ${masterKey1.extractBytes()}');
          printOnFailure('masterKey2: ${masterKey2.extractBytes()}');

          expect(masterKey1, hasLength(sut.keyBytes));
          expect(masterKey2, hasLength(sut.keyBytes));
          expect(masterKey1, isNot(masterKey2));
        });
      });

      test('extractStream creates a master key from a stream of data', (
        sodium,
      ) async {
        final sut = sodium.crypto.kdfHkdfSha256;

        final salt = Uint8List.fromList(List.generate(16, (index) => index));
        final ikm = Stream.fromIterable(
          List.generate(
            32,
            (i) => Uint8List.fromList(
              List.generate(32 % (i + 1), (j) => (i * j) % 256),
            ),
          ),
        );

        printOnFailure('salt: $salt');

        final masterKeyOneShot = sut.extract(
          ikm: Uint8List.fromList(await ikm.expand((chunk) => chunk).toList()),
          salt: salt,
        );
        final masterKeyStreamed = await sut.extractStream(ikm: ikm, salt: salt);

        printOnFailure('masterKey: ${masterKeyStreamed.extractBytes()}');

        expect(masterKeyStreamed, hasLength(sut.keyBytes));
        expect(masterKeyStreamed, equals(masterKeyOneShot));
      });

      group('expand', () {
        test('creates different keys for different contexts', (sodium) {
          final sut = sodium.crypto.kdfHkdfSha256;

          final masterKey = sut.keygen();
          const context1 = 'context1';
          const context2 = 'context2';

          printOnFailure('masterKey: ${masterKey.extractBytes()}');

          final key1 = sut.expand(
            masterKey: masterKey,
            context: context1,
            outLen: 32,
          );
          final key2 = sut.expand(
            masterKey: masterKey,
            context: context1,
            outLen: 64,
          );
          final key3 = sut.expand(
            masterKey: masterKey,
            context: context2,
            outLen: 32,
          );

          printOnFailure('key1: ${key1.extractBytes()}');
          printOnFailure('key2: ${key2.extractBytes()}');
          printOnFailure('key3: ${key3.extractBytes()}');

          expect(key1, hasLength(32));
          expect(key2, hasLength(64));
          expect(key3, hasLength(32));

          expect(key1, isNot(key2));
          expect(key1, isNot(key3));
          expect(key2, isNot(key3));

          expect(key2.extractBytes().sublist(0, 32), key1.extractBytes());
        });

        test('generates keys of correct length across the valid range', (
          sodium,
        ) {
          final sut = sodium.crypto.kdfHkdfSha256;

          final masterKey = sut.keygen();

          printOnFailure('masterKey: ${masterKey.extractBytes()}');

          final random = Random();
          final outLens = <int>[sut.bytesMin];
          for (
            var outLen = sut.bytesMin + 800 + random.nextInt(401);
            outLen < sut.bytesMax;
            outLen += 800 + random.nextInt(401)
          ) {
            outLens.add(outLen);
          }
          outLens.add(sut.bytesMax);

          printOnFailure('outLens: $outLens');

          for (final outLen in outLens) {
            final key = sut.expand(
              masterKey: masterKey,
              context: 'test_len',
              outLen: outLen,
            );

            expect(key, hasLength(outLen), reason: 'outLen $outLen');
          }
        });

        test('is deterministic for the same inputs', (sodium) {
          final sut = sodium.crypto.kdfHkdfSha256;

          final masterKey = sut.keygen();
          const context = 'context1';

          printOnFailure('masterKey: ${masterKey.extractBytes()}');

          final key1 = sut.expand(
            masterKey: masterKey,
            context: context,
            outLen: 64,
          );
          final key2 = sut.expand(
            masterKey: masterKey,
            context: context,
            outLen: 64,
          );

          printOnFailure('key1: ${key1.extractBytes()}');
          printOnFailure('key2: ${key2.extractBytes()}');

          expect(key1, equals(key2));
        });
      });
    });

    group('sha512', () {
      test('constants return correct values', (sodium) {
        final sut = sodium.crypto.kdfHkdfSha512;

        expect(sut.keyBytes, 64, reason: 'keyBytes');
        expect(sut.bytesMin, 0, reason: 'bytesMin');
        expect(sut.bytesMax, 16320, reason: 'bytesMax');
      });

      test('keygen', (sodium) {
        final sut = sodium.crypto.kdfHkdfSha512;

        final key1 = sut.keygen();
        final key2 = sut.keygen();

        printOnFailure('key1: ${key1.extractBytes()}');
        printOnFailure('key2: ${key2.extractBytes()}');

        expect(key1, hasLength(sut.keyBytes));
        expect(key2, hasLength(sut.keyBytes));

        expect(key1, isNot(key2));
      });

      group('extract', () {
        test('generates master key from ikm', (sodium) {
          final sut = sodium.crypto.kdfHkdfSha512;

          final ikm = Uint8List.fromList(List.generate(32, (index) => index));

          printOnFailure('ikm: $ikm');

          final masterKey1 = sut.extract(ikm: ikm);
          final masterKey2 = sut.extract(ikm: ikm);

          printOnFailure('masterKey1: ${masterKey1.extractBytes()}');
          printOnFailure('masterKey2: ${masterKey2.extractBytes()}');

          expect(masterKey1, hasLength(sut.keyBytes));
          expect(masterKey2, hasLength(sut.keyBytes));
          expect(masterKey1, equals(masterKey2));
        });

        test('generates different keys for different salts', (sodium) {
          final sut = sodium.crypto.kdfHkdfSha512;

          final ikm = Uint8List.fromList(List.generate(32, (index) => index));
          final salt1 = Uint8List.fromList(List.generate(16, (index) => index));
          final salt2 = Uint8List.fromList(
            List.generate(16, (index) => index + 1),
          );

          printOnFailure('ikm: $ikm');
          printOnFailure('salt1: $salt1');
          printOnFailure('salt2: $salt2');

          final masterKey1 = sut.extract(ikm: ikm, salt: salt1);
          final masterKey2 = sut.extract(ikm: ikm, salt: salt2);

          printOnFailure('masterKey1: ${masterKey1.extractBytes()}');
          printOnFailure('masterKey2: ${masterKey2.extractBytes()}');

          expect(masterKey1, hasLength(sut.keyBytes));
          expect(masterKey2, hasLength(sut.keyBytes));
          expect(masterKey1, isNot(masterKey2));
        });
      });

      test('extractStream creates a master key from a stream of data', (
        sodium,
      ) async {
        final sut = sodium.crypto.kdfHkdfSha512;

        final salt = Uint8List.fromList(List.generate(16, (index) => index));
        final ikm = Stream.fromIterable(
          List.generate(
            32,
            (i) => Uint8List.fromList(
              List.generate(32 % (i + 1), (j) => (i * j) % 256),
            ),
          ),
        );

        printOnFailure('salt: $salt');

        final masterKeyOneShot = sut.extract(
          ikm: Uint8List.fromList(await ikm.expand((chunk) => chunk).toList()),
          salt: salt,
        );
        final masterKeyStreamed = await sut.extractStream(ikm: ikm, salt: salt);

        printOnFailure('masterKey: ${masterKeyStreamed.extractBytes()}');

        expect(masterKeyStreamed, hasLength(sut.keyBytes));
        expect(masterKeyStreamed, equals(masterKeyOneShot));
      });

      group('expand', () {
        test('creates different keys for different contexts', (sodium) {
          final sut = sodium.crypto.kdfHkdfSha512;

          final masterKey = sut.keygen();
          const context1 = 'context1';
          const context2 = 'context2';

          printOnFailure('masterKey: ${masterKey.extractBytes()}');

          final key1 = sut.expand(
            masterKey: masterKey,
            context: context1,
            outLen: 32,
          );
          final key2 = sut.expand(
            masterKey: masterKey,
            context: context1,
            outLen: 64,
          );
          final key3 = sut.expand(
            masterKey: masterKey,
            context: context2,
            outLen: 32,
          );

          printOnFailure('key1: ${key1.extractBytes()}');
          printOnFailure('key2: ${key2.extractBytes()}');
          printOnFailure('key3: ${key3.extractBytes()}');

          expect(key1, hasLength(32));
          expect(key2, hasLength(64));
          expect(key3, hasLength(32));

          expect(key1, isNot(key2));
          expect(key1, isNot(key3));
          expect(key2, isNot(key3));

          expect(key2.extractBytes().sublist(0, 32), key1.extractBytes());
        });

        test('generates keys of correct length across the valid range', (
          sodium,
        ) {
          final sut = sodium.crypto.kdfHkdfSha512;

          final masterKey = sut.keygen();

          printOnFailure('masterKey: ${masterKey.extractBytes()}');

          final random = Random();
          final outLens = <int>[sut.bytesMin];
          for (
            var outLen = sut.bytesMin + 800 + random.nextInt(401);
            outLen < sut.bytesMax;
            outLen += 800 + random.nextInt(401)
          ) {
            outLens.add(outLen);
          }
          outLens.add(sut.bytesMax);

          printOnFailure('outLens: $outLens');

          for (final outLen in outLens) {
            final key = sut.expand(
              masterKey: masterKey,
              context: 'test_len',
              outLen: outLen,
            );

            expect(key, hasLength(outLen), reason: 'outLen $outLen');
          }
        });

        test('is deterministic for the same inputs', (sodium) {
          final sut = sodium.crypto.kdfHkdfSha512;

          final masterKey = sut.keygen();
          const context = 'context1';

          printOnFailure('masterKey: ${masterKey.extractBytes()}');

          final key1 = sut.expand(
            masterKey: masterKey,
            context: context,
            outLen: 64,
          );
          final key2 = sut.expand(
            masterKey: masterKey,
            context: context,
            outLen: 64,
          );

          printOnFailure('key1: ${key1.extractBytes()}');
          printOnFailure('key2: ${key2.extractBytes()}');

          expect(key1, equals(key2));
        });
      });
    });
  }
}
