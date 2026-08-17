import 'dart:isolate';
import 'dart:typed_data';

import 'package:sodium/sodium.dart';

import '../test_case.dart';

class SodiumTestCase extends TestCase {
  new(super._runner);

  @override
  String get name => 'sodium';

  @override
  void setupTests() {
    test('reports correct version', (sodium) {
      final version = sodium.version;

      expect(version.major, 26);
      expect(version.minor, greaterThanOrEqualTo(1));
    });

    group('pad adds expected padding and unpad removes it', () {
      const fixtures = [(14, 16), (15, 16), (16, 32), (17, 32), (18, 32)];

      for (final fixture in fixtures) {
        test('(Variant: $fixture)', (sodium) {
          const blockSize = 16;
          final baseBuf = Uint8List(fixture.$1);

          final paddedBuf = sodium.pad(baseBuf, blockSize);
          printOnFailure('Padded buf: $paddedBuf');

          expect(paddedBuf, hasLength(fixture.$2));
          expect(paddedBuf.sublist(0, baseBuf.length), baseBuf);

          final unpaddedBuf = sodium.unpad(paddedBuf, blockSize);
          printOnFailure('Padded buf: $unpaddedBuf');

          expect(unpaddedBuf, baseBuf);
        });
      }
    });

    group('memcmp', () {
      test('returns true for buffers with identical content', (sodium) {
        final b1 = Uint8List.fromList(const [1, 2, 3, 4]);
        final b2 = Uint8List.fromList(const [1, 2, 3, 4]);

        expect(sodium.memcmp(b1, b2), isTrue);
      });

      test('returns false for buffers with different content', (sodium) {
        final b1 = Uint8List.fromList(const [1, 2, 3, 4]);
        final b2 = Uint8List.fromList(const [1, 2, 3, 5]);

        expect(sodium.memcmp(b1, b2), isFalse);
      });

      test('returns true for two empty buffers', (sodium) {
        expect(sodium.memcmp(Uint8List(0), Uint8List(0)), isTrue);
      });

      test('does not modify the inputs', (sodium) {
        final b1 = Uint8List.fromList(const [1, 2, 3, 4]);
        final b2 = Uint8List.fromList(const [1, 2, 3, 5]);

        expect(sodium.memcmp(b1, b2), isFalse);

        expect(b1, Uint8List.fromList(const [1, 2, 3, 4]));
        expect(b2, Uint8List.fromList(const [1, 2, 3, 5]));
      });

      test('throws ArgumentError if the buffers have different lengths', (
        sodium,
      ) {
        expect(
          () => sodium.memcmp(Uint8List(4), Uint8List(5)),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('compare', () {
      // (description, b1, b2, expected)
      const fixtures = <(String, List<int>, List<int>, int)>[
        ('equal buffers', [1, 2, 3], [1, 2, 3], 0),
        ('smaller in the least significant byte', [1, 0, 0], [2, 0, 0], -1),
        ('greater in the least significant byte', [2, 0, 0], [1, 0, 0], 1),
        // Little endian: [0x00, 0x01] is 256, [0xFF, 0x00] is only 255.
        ('greater in the most significant byte', [0x00, 0x01], [0xFF, 0x00], 1),
        (
          'smaller in the most significant byte',
          [0xFF, 0x00],
          [0x00, 0x01],
          -1,
        ),
      ];

      for (final fixture in fixtures) {
        test('returns ${fixture.$4} for ${fixture.$1}', (sodium) {
          final b1 = Uint8List.fromList(fixture.$2);
          final b2 = Uint8List.fromList(fixture.$3);

          expect(sodium.compare(b1, b2), fixture.$4);
        });
      }

      test('returns 0 for two empty buffers', (sodium) {
        expect(sodium.compare(Uint8List(0), Uint8List(0)), 0);
      });

      test('does not modify the inputs', (sodium) {
        final b1 = Uint8List.fromList(const [1, 2, 3]);
        final b2 = Uint8List.fromList(const [3, 2, 1]);

        expect(sodium.compare(b1, b2), 1);

        expect(b1, Uint8List.fromList(const [1, 2, 3]));
        expect(b2, Uint8List.fromList(const [3, 2, 1]));
      });

      test('throws ArgumentError if the buffers have different lengths', (
        sodium,
      ) {
        expect(
          () => sodium.compare(Uint8List(4), Uint8List(5)),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('isZero', () {
      test('returns true for an all zero buffer', (sodium) {
        expect(sodium.isZero(Uint8List(32)), isTrue);
      });

      test('returns false if the first byte is not zero', (sodium) {
        final n = Uint8List(32)..[0] = 1;

        expect(sodium.isZero(n), isFalse);
      });

      test('returns false if the last byte is not zero', (sodium) {
        final n = Uint8List(32)..[31] = 1;

        expect(sodium.isZero(n), isFalse);
      });

      test('returns true for an empty buffer', (sodium) {
        expect(sodium.isZero(Uint8List(0)), isTrue);
      });
    });

    group('increment', () {
      // (description, n, expected)
      const fixtures = <(String, List<int>, List<int>)>[
        ('increments the least significant byte', [0, 0, 0], [1, 0, 0]),
        ('carries into the next byte', [0xFF, 0x00], [0x00, 0x01]),
        (
          'carries across multiple bytes',
          [0xFF, 0xFF, 0x00],
          [0x00, 0x00, 0x01],
        ),
        ('wraps around on overflow', [0xFF, 0xFF], [0x00, 0x00]),
      ];

      for (final fixture in fixtures) {
        test(fixture.$1, (sodium) {
          final n = Uint8List.fromList(fixture.$2);

          final result = sodium.increment(n);
          printOnFailure('result: $result');

          expect(result, Uint8List.fromList(fixture.$3));
        });
      }

      test('does not modify the input', (sodium) {
        final n = Uint8List.fromList(const [0xFF, 0x00]);

        final result = sodium.increment(n);

        expect(result, Uint8List.fromList(const [0x00, 0x01]));
        expect(n, Uint8List.fromList(const [0xFF, 0x00]));
        expect(result, isNot(same(n)));
      });

      test('returns an empty buffer for an empty input', (sodium) {
        expect(sodium.increment(Uint8List(0)), isEmpty);
      });
    });

    group('add', () {
      // (description, a, b, expected)
      const fixtures = <(String, List<int>, List<int>, List<int>)>[
        ('adds without carry', [5, 7, 9], [4, 5, 6], [9, 12, 15]),
        ('adds zero', [1, 2, 3], [0, 0, 0], [1, 2, 3]),
        (
          'carries into the next byte',
          [0xFF, 0x00],
          [0x01, 0x00],
          [0x00, 0x01],
        ),
        (
          'carries across multiple bytes',
          [0xFF, 0xFF, 0x00],
          [0x01, 0x00, 0x00],
          [0x00, 0x00, 0x01],
        ),
        ('wraps around on overflow', [0xFF, 0xFF], [0x01, 0x00], [0x00, 0x00]),
        // Little endian: 0x0201 + 0x00FF == 0x0300.
        (
          'adds in little endian order',
          [0x01, 0x02],
          [0xFF, 0x00],
          [0x00, 0x03],
        ),
      ];

      for (final fixture in fixtures) {
        test(fixture.$1, (sodium) {
          final a = Uint8List.fromList(fixture.$2);
          final b = Uint8List.fromList(fixture.$3);

          final result = sodium.add(a, b);
          printOnFailure('result: $result');

          expect(result, Uint8List.fromList(fixture.$4));
        });
      }

      test('does not modify the inputs', (sodium) {
        final a = Uint8List.fromList(const [0xFF, 0x00]);
        final b = Uint8List.fromList(const [0x01, 0x00]);

        final result = sodium.add(a, b);

        expect(result, Uint8List.fromList(const [0x00, 0x01]));
        expect(a, Uint8List.fromList(const [0xFF, 0x00]));
        expect(b, Uint8List.fromList(const [0x01, 0x00]));
        expect(result, isNot(same(a)));
        expect(result, isNot(same(b)));
      });

      test('returns an empty buffer for empty inputs', (sodium) {
        expect(sodium.add(Uint8List(0), Uint8List(0)), isEmpty);
      });

      test('throws ArgumentError if the buffers have different lengths', (
        sodium,
      ) {
        expect(
          () => sodium.add(Uint8List(4), Uint8List(5)),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('sub', () {
      // (description, a, b, expected)
      const fixtures = <(String, List<int>, List<int>, List<int>)>[
        ('subtracts without borrow', [5, 7, 9], [4, 5, 6], [1, 2, 3]),
        ('subtracts zero', [1, 2, 3], [0, 0, 0], [1, 2, 3]),
        ('subtracts itself to zero', [1, 2, 3], [1, 2, 3], [0, 0, 0]),
        (
          'borrows from the next byte',
          [0x00, 0x01],
          [0x01, 0x00],
          [0xFF, 0x00],
        ),
        (
          'borrows across multiple bytes',
          [0x00, 0x00, 0x01],
          [0x01, 0x00, 0x00],
          [0xFF, 0xFF, 0x00],
        ),
        ('wraps around below zero', [0x00, 0x00], [0x01, 0x00], [0xFF, 0xFF]),
        // Little endian: 0x0200 - 0x0001 == 0x01FF.
        (
          'subtracts in little endian order',
          [0x00, 0x02],
          [0x01, 0x00],
          [0xFF, 0x01],
        ),
      ];

      for (final fixture in fixtures) {
        test(fixture.$1, (sodium) {
          final a = Uint8List.fromList(fixture.$2);
          final b = Uint8List.fromList(fixture.$3);

          final result = sodium.sub(a, b);
          printOnFailure('result: $result');

          expect(result, Uint8List.fromList(fixture.$4));
        });
      }

      test('does not modify the inputs', (sodium) {
        final a = Uint8List.fromList(const [0x00, 0x01]);
        final b = Uint8List.fromList(const [0x01, 0x00]);

        final result = sodium.sub(a, b);

        expect(result, Uint8List.fromList(const [0xFF, 0x00]));
        expect(a, Uint8List.fromList(const [0x00, 0x01]));
        expect(b, Uint8List.fromList(const [0x01, 0x00]));
        expect(result, isNot(same(a)));
        expect(result, isNot(same(b)));
      });

      test('returns an empty buffer for empty inputs', (sodium) {
        expect(sodium.sub(Uint8List(0), Uint8List(0)), isEmpty);
      });

      test('inverts add for random operands', (sodium) {
        final a = sodium.randombytes.buf(32);
        final b = sodium.randombytes.buf(32);

        printOnFailure('a: $a');
        printOnFailure('b: $b');

        expect(sodium.sub(sodium.add(a, b), b), a);
        expect(sodium.add(sodium.sub(a, b), b), a);
      });

      test('inverts increment for random operands', (sodium) {
        final a = sodium.randombytes.buf(32);
        final one = Uint8List(32)..[0] = 1;

        printOnFailure('a: $a');

        expect(sodium.sub(sodium.increment(a), one), a);
      });

      test('throws ArgumentError if the buffers have different lengths', (
        sodium,
      ) {
        expect(
          () => sodium.sub(Uint8List(4), Uint8List(5)),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('bin2hex', () {
      test('encodes bytes as lowercase hex', (sodium) {
        final bin = Uint8List.fromList(const [
          0x00,
          0x0F,
          0x10,
          0xAB,
          0xCD,
          0xEF,
          0xFF,
        ]);

        final hex = sodium.bin2hex(bin);
        printOnFailure('hex: $hex');

        expect(hex, '000f10abcdefff');
      });

      test('encodes an empty buffer as an empty string', (sodium) {
        expect(sodium.bin2hex(Uint8List(0)), isEmpty);
      });

      test('does not modify the input', (sodium) {
        final bin = Uint8List.fromList(const [0x01, 0x02]);

        expect(sodium.bin2hex(bin), '0102');

        expect(bin, Uint8List.fromList(const [0x01, 0x02]));
      });
    });

    group('hex2bin', () {
      test('decodes lowercase hex', (sodium) {
        final bin = sodium.hex2bin('000f10abcdefff');
        printOnFailure('bin: $bin');

        expect(
          bin,
          Uint8List.fromList(const [0x00, 0x0F, 0x10, 0xAB, 0xCD, 0xEF, 0xFF]),
        );
      });

      test('decodes uppercase hex', (sodium) {
        final bin = sodium.hex2bin('000F10ABCDEFFF');
        printOnFailure('bin: $bin');

        expect(
          bin,
          Uint8List.fromList(const [0x00, 0x0F, 0x10, 0xAB, 0xCD, 0xEF, 0xFF]),
        );
      });

      test('decodes an empty string as an empty buffer', (sodium) {
        expect(sodium.hex2bin(''), isEmpty);
      });

      test('round trips random bytes through bin2hex', (sodium) {
        final bin = sodium.randombytes.buf(32);

        final hex = sodium.bin2hex(bin);
        printOnFailure('hex: $hex');

        expect(hex, hasLength(bin.length * 2));
        expect(sodium.hex2bin(hex), bin);
      });

      group('rejects malformed input', () {
        const fixtures = <(String, String)>[
          ('an odd number of characters', 'abc'),
          ('a single character', 'a'),
          ('non hex characters', 'zzzz'),
          ('a leading non hex character', ':4142'),
          ('an embedded non hex character', '41:42'),
          ('a trailing non hex character', '4142:'),
          ('trailing whitespace', '4142 '),
        ];

        for (final fixture in fixtures) {
          test(fixture.$1, (sodium) {
            expect(
              () => sodium.hex2bin(fixture.$2),
              throwsA(isA<SodiumException>()),
            );
          });
        }
      });

      test('throws ArgumentError for non ASCII input', (sodium) {
        expect(() => sodium.hex2bin('41ä2'), throwsA(isA<ArgumentError>()));
      });
    });

    group('SecureKey', () {
      test('secureAlloc creates secure key of correct size', (sodium) {
        const length = 42;
        final secureKey = sodium.secureAlloc(length);
        try {
          expect(secureKey, hasLength(length));
          expect(secureKey.extractBytes(), hasLength(length));
        } finally {
          secureKey.dispose();
        }
      });

      test('secureRandom creates secure key of correct size with random data', (
        sodium,
      ) {
        const length = 42;
        final secureKey1 = sodium.secureRandom(length);
        final secureKey2 = sodium.secureRandom(length);
        try {
          expect(secureKey1, hasLength(length));
          expect(secureKey2, hasLength(length));
          expect(secureKey1.extractBytes(), hasLength(length));
          expect(secureKey2.extractBytes(), hasLength(length));
          expect(secureKey1.extractBytes(), isNot(secureKey2.extractBytes()));
        } finally {
          secureKey1.dispose();
          secureKey2.dispose();
        }
      });

      test('runUnlockedSync allows data modification', (sodium) {
        final testData = List.generate(10, (index) => index);
        final secureKey = sodium.secureAlloc(testData.length);
        try {
          // write data
          final resLen = secureKey.runUnlockedSync((data) {
            expect(data, hasLength(testData.length));
            data.setAll(0, testData);
            return data.length;
          }, writable: true);

          expect(resLen, testData.length);
          expect(secureKey.extractBytes(), testData);

          // read data
          secureKey.runUnlockedSync((data) {
            expect(data, testData);
          });
        } finally {
          secureKey.dispose();
        }
      });

      test('runUnlockedAsync allows data modification', (sodium) async {
        final testData = List.generate(10, (index) => index);
        final secureKey = sodium.secureAlloc(testData.length);
        try {
          // write data
          final resLen = await secureKey.runUnlockedAsync((data) {
            expect(data, hasLength(testData.length));
            data.setAll(0, testData);
            return data.length;
          }, writable: true);

          expect(resLen, testData.length);
          expect(secureKey.extractBytes(), testData);

          // read data
          final resAsync = await secureKey.runUnlockedAsync((data) {
            expect(data, testData);
            return Future.delayed(const Duration(milliseconds: 1), () => 42);
          });
          expect(resAsync, 42);
        } finally {
          secureKey.dispose();
        }
      });
    });

    group('runIsolated', () {
      test('with key pair as result', (sodium) async {
        final secureKey = sodium.crypto.secretBox.keygen();
        final keyPair1 = sodium.crypto.box.keyPair();
        final keyPair2 = sodium.crypto.box.keyPair();

        final message = 'Hello, World!'.toCharArray().unsignedView();
        final nonce1 = sodium.randombytes.buf(
          sodium.crypto.secretBox.nonceBytes,
        );

        final result = await sodium.runIsolated(
          secureKeys: [secureKey],
          keyPairs: [keyPair1, keyPair2],
          (secureKeys, keyPairs) {
            final secureKey = secureKeys.single;
            final keyPair1 = keyPairs[0];
            final keyPair2 = keyPairs[1];

            final cipher1 = sodium.crypto.secretBox.easy(
              message: message,
              nonce: nonce1,
              key: secureKey,
            );

            final nonce2 = sodium.randombytes.buf(sodium.crypto.box.nonceBytes);
            final cipher2 = sodium.crypto.box.easy(
              message: cipher1,
              nonce: nonce2,
              publicKey: keyPair2.publicKey,
              secretKey: keyPair1.secretKey,
            );

            final cipherKey = sodium.secureCopy(cipher2);

            return KeyPair(publicKey: nonce2, secretKey: cipherKey);
          },
        );

        final plain2 = sodium.crypto.box.openEasy(
          cipherText: result.secretKey.extractBytes(),
          nonce: result.publicKey,
          publicKey: keyPair1.publicKey,
          secretKey: keyPair2.secretKey,
        );

        final plain1 = sodium.crypto.secretBox.openEasy(
          cipherText: plain2,
          nonce: nonce1,
          key: secureKey,
        );

        expect(plain1, message);
      });

      testSumo('with secure key as result', (sodium) async {
        final secureKey = sodium.crypto.secretBox.keygen();
        final keyPair = sodium.crypto.box.keyPair();

        final result = await sodium.runIsolated(
          secureKeys: [secureKey],
          keyPairs: [keyPair],
          (secureKeys, keyPairs) {
            final [secureKey] = secureKeys;
            final [keyPair] = keyPairs;

            final base = sodium.crypto.scalarmult.base(n: secureKey);

            return sodium.crypto.scalarmult.call(n: keyPair.secretKey, p: base);
          },
        );

        final expected = sodium.crypto.scalarmult.call(
          n: secureKey,
          p: keyPair.publicKey,
        );

        expect(result, expected);
      });

      testSumo('with byte array as result', (sodium) async {
        final keyPair = sodium.crypto.box.keyPair();
        final base = await sodium.runIsolated(secureKeys: [keyPair.secretKey], (
          secureKeys,
          _,
        ) {
          final [secureKey] = secureKeys;
          return sodium.crypto.scalarmult.base(n: secureKey);
        });
        expect(base, keyPair.publicKey);
      });
    });

    test(
      'custom isolates',
      // ignore: do_not_use_environment is the same as "kIsWeb"
      skip: const bool.fromEnvironment('dart.library.js_util'),
      (sodium) async {
        final secureKey = sodium.crypto.secretBox.keygen();
        final keyPair1 = sodium.crypto.box.keyPair();
        final keyPair2 = sodium.crypto.box.keyPair();

        final message = 'Hello, World!'.toCharArray().unsignedView();
        final nonce1 = sodium.randombytes.buf(
          sodium.crypto.secretBox.nonceBytes,
        );
        final nonce2 = sodium.randombytes.buf(sodium.crypto.box.nonceBytes);

        final transferrableResult = await ioCompute(_compute, (
          sodium,
          sodium.createTransferrableSecureKey(secureKey),
          sodium.createTransferrableKeyPair(keyPair1),
          sodium.createTransferrableKeyPair(keyPair2),
          TransferableTypedData.fromList([message]),
          TransferableTypedData.fromList([nonce1]),
          TransferableTypedData.fromList([nonce2]),
        ));

        final result = sodium.materializeTransferrableSecureKey(
          transferrableResult,
        );

        final plain2 = sodium.crypto.box.openEasy(
          cipherText: result.extractBytes(),
          nonce: nonce2,
          publicKey: keyPair1.publicKey,
          secretKey: keyPair2.secretKey,
        );

        final plain1 = sodium.crypto.secretBox.openEasy(
          cipherText: plain2,
          nonce: nonce1,
          key: secureKey,
        );

        expect(plain1, message);
      },
    );
  }
}

Future<TransferrableSecureKey> _compute(
  (
    Sodium,
    TransferrableSecureKey,
    TransferrableKeyPair,
    TransferrableKeyPair,
    TransferableTypedData,
    TransferableTypedData,
    TransferableTypedData,
  )
  computeMessage,
) async {
  final (
    sodium,
    transferrableSecureKey,
    transferrableKeyPair1,
    transferrableKeyPair2,
    message,
    nonce1,
    nonce2,
  ) = computeMessage;

  final secureKey = sodium.materializeTransferrableSecureKey(
    transferrableSecureKey,
  );
  final keyPair1 = sodium.materializeTransferrableKeyPair(
    transferrableKeyPair1,
  );
  final keyPair2 = sodium.materializeTransferrableKeyPair(
    transferrableKeyPair2,
  );

  final cipher1 = sodium.crypto.secretBox.easy(
    message: message.materialize().asUint8List(),
    nonce: nonce1.materialize().asUint8List(),
    key: secureKey,
  );

  final cipher2 = sodium.crypto.box.easy(
    message: cipher1,
    nonce: nonce2.materialize().asUint8List(),
    publicKey: keyPair2.publicKey,
    secretKey: keyPair1.secretKey,
  );

  final cipherKey = sodium.secureCopy(cipher2);

  return sodium.createTransferrableSecureKey(cipherKey);
}
