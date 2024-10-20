import 'dart:isolate';
import 'dart:typed_data';

// ignore: no_self_package_imports
import 'package:sodium/sodium.dart';

import '../test_case.dart';

class SodiumTestCase extends TestCase {
  SodiumTestCase(super._runner);

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
      const fixtures = [
        (14, 16),
        (15, 16),
        (16, 32),
        (17, 32),
        (18, 32),
      ];

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

      test('secureRandom creates secure key of correct size with random data',
          (sodium) {
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
          final resLen = secureKey.runUnlockedSync(
            (data) {
              expect(data, hasLength(testData.length));
              data.setAll(0, testData);
              return data.length;
            },
            writable: true,
          );

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
          final resLen = await secureKey.runUnlockedAsync(
            (data) {
              expect(data, hasLength(testData.length));
              data.setAll(0, testData);
              return data.length;
            },
            writable: true,
          );

          expect(resLen, testData.length);
          expect(secureKey.extractBytes(), testData);

          // read data
          final resAsync = await secureKey.runUnlockedAsync((data) async {
            expect(data, testData);
            return Future.delayed(
              const Duration(milliseconds: 1),
              () => 42,
            );
          });
          expect(resAsync, 42);
        } finally {
          secureKey.dispose();
        }
      });
    });

    test('runIsolated', (sodium) async {
      final secureKey = sodium.crypto.secretBox.keygen();
      final keyPair1 = sodium.crypto.box.keyPair();
      final keyPair2 = sodium.crypto.box.keyPair();

      final message = 'Hello, World!'.toCharArray().unsignedView();
      final nonce1 = sodium.randombytes.buf(sodium.crypto.secretBox.nonceBytes);
      final nonce2 = sodium.randombytes.buf(sodium.crypto.box.nonceBytes);

      final result = await sodium.runIsolated(
        secureKeys: [secureKey],
        keyPairs: [keyPair1, keyPair2],
        (sodium, secureKeys, keyPairs) {
          final secureKey = secureKeys.single;
          final keyPair1 = keyPairs[0];
          final keyPair2 = keyPairs[1];

          final cipher1 = sodium.crypto.secretBox.easy(
            message: message,
            nonce: nonce1,
            key: secureKey,
          );

          final cipher2 = sodium.crypto.box.easy(
            message: cipher1,
            nonce: nonce2,
            publicKey: keyPair2.publicKey,
            secretKey: keyPair1.secretKey,
          );

          final cipherKey = sodium.secureCopy(cipher2);

          return cipherKey;
        },
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
    });

    testSumo('runIsolated', (sodium) async {
      final secureKey = sodium.crypto.secretBox.keygen();
      final keyPair = sodium.crypto.box.keyPair();

      final result = await sodium.runIsolated(
        secureKeys: [secureKey],
        keyPairs: [keyPair],
        (sodium, secureKeys, keyPairs) {
          final [secureKey] = secureKeys;
          final [keyPair] = keyPairs;

          final base = sodium.crypto.scalarmult.base(n: secureKey);

          return sodium.crypto.scalarmult.call(
            n: keyPair.secretKey,
            p: base,
          );
        },
      );

      final expected = sodium.crypto.scalarmult.call(
        n: secureKey,
        p: keyPair.publicKey,
      );

      expect(result, expected);
    });

    test('custom isolates',
        // ignore: do_not_use_environment is the same as "kIsWeb"
        skip: const bool.fromEnvironment('dart.library.js_util'),
        (sodium) async {
      final secureKey = sodium.crypto.secretBox.keygen();
      final keyPair1 = sodium.crypto.box.keyPair();
      final keyPair2 = sodium.crypto.box.keyPair();

      final message = 'Hello, World!'.toCharArray().unsignedView();
      final nonce1 = sodium.randombytes.buf(sodium.crypto.secretBox.nonceBytes);
      final nonce2 = sodium.randombytes.buf(sodium.crypto.box.nonceBytes);

      final transferrableResult = await ioCompute(
        _compute,
        (
          sodium.isolateFactory,
          sodium.createTransferrableSecureKey(secureKey),
          sodium.createTransferrableKeyPair(keyPair1),
          sodium.createTransferrableKeyPair(keyPair2),
          TransferableTypedData.fromList([message]),
          TransferableTypedData.fromList([nonce1]),
          TransferableTypedData.fromList([nonce2]),
        ),
      );

      final result =
          sodium.materializeTransferrableSecureKey(transferrableResult);

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
    });
  }
}

Future<TransferrableSecureKey> _compute(
  (
    SodiumFactory,
    TransferrableSecureKey,
    TransferrableKeyPair,
    TransferrableKeyPair,
    TransferableTypedData,
    TransferableTypedData,
    TransferableTypedData,
  ) computeMessage,
) async {
  final (
    isolateFactory,
    transferrableSecureKey,
    transferrableKeyPair1,
    transferrableKeyPair2,
    message,
    nonce1,
    nonce2,
  ) = computeMessage;

  final sodium = await isolateFactory();
  final secureKey =
      sodium.materializeTransferrableSecureKey(transferrableSecureKey);
  final keyPair1 =
      sodium.materializeTransferrableKeyPair(transferrableKeyPair1);
  final keyPair2 =
      sodium.materializeTransferrableKeyPair(transferrableKeyPair2);

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
