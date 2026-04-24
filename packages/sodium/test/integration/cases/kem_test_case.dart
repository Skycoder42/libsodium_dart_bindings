import '../test_case.dart';

class KemTestCase extends TestCase {
  KemTestCase(super._runner);

  @override
  String get name => 'kem';

  @override
  void setupTests() {
    test('constants return correct values', (sodium) {
      final sut = sodium.crypto.kem;
      expect(sut.publicKeyBytes, 1216, reason: 'publicKeyBytes');
      expect(sut.secretKeyBytes, 32, reason: 'secretKeyBytes');
      expect(sut.ciphertextBytes, 1120, reason: 'ciphertextBytes');
      expect(sut.sharedSecretBytes, 32, reason: 'sharedSecretBytes');
      expect(sut.seedBytes, 32, reason: 'seedBytes');
      expect(sut.primitive, 'xwing', reason: 'primitive');
    });

    test('keyPair generates different correct length keys', (sodium) {
      final sut = sodium.crypto.kem;

      final key1 = sut.keyPair();
      final key2 = sut.keyPair();

      printOnFailure('key1.secretKey: ${key1.secretKey.extractBytes()}');
      printOnFailure('key1.publicKey: ${key1.publicKey}');
      printOnFailure('key2.secretKey: ${key2.secretKey.extractBytes()}');
      printOnFailure('key2.publicKey: ${key2.publicKey}');

      expect(key1.secretKey, hasLength(sut.secretKeyBytes));
      expect(key1.publicKey, hasLength(sut.publicKeyBytes));
      expect(key2.secretKey, hasLength(sut.secretKeyBytes));
      expect(key2.publicKey, hasLength(sut.publicKeyBytes));

      expect(key1.secretKey, isNot(key2.secretKey));
      expect(key1.publicKey, isNot(key2.publicKey));
    });

    group('seedKeyPair', () {
      test('generates different correct length keys for different seeds', (
        sodium,
      ) {
        final sut = sodium.crypto.kem;

        final seed1 = sodium.secureRandom(sut.seedBytes);
        final seed2 = sodium.secureRandom(sut.seedBytes);

        printOnFailure('seed1: ${seed1.extractBytes()}');
        printOnFailure('seed2: ${seed2.extractBytes()}');

        final key1 = sut.seedKeyPair(seed1);
        final key2 = sut.seedKeyPair(seed2);

        printOnFailure('key1.secretKey: ${key1.secretKey.extractBytes()}');
        printOnFailure('key1.publicKey: ${key1.publicKey}');
        printOnFailure('key2.secretKey: ${key2.secretKey.extractBytes()}');
        printOnFailure('key2.publicKey: ${key2.publicKey}');

        expect(key1.secretKey, hasLength(sut.secretKeyBytes));
        expect(key1.publicKey, hasLength(sut.publicKeyBytes));
        expect(key2.secretKey, hasLength(sut.secretKeyBytes));
        expect(key2.publicKey, hasLength(sut.publicKeyBytes));

        expect(key1.secretKey, isNot(key2.secretKey));
        expect(key1.publicKey, isNot(key2.publicKey));
      });

      test('generates same correct length keys for same seeds', (sodium) {
        final sut = sodium.crypto.kem;

        final seed = sodium.secureRandom(sut.seedBytes);

        printOnFailure('seed: ${seed.extractBytes()}');

        final key1 = sut.seedKeyPair(seed);
        final key2 = sut.seedKeyPair(seed);

        printOnFailure('key1.secretKey: ${key1.secretKey.extractBytes()}');
        printOnFailure('key1.publicKey: ${key1.publicKey}');
        printOnFailure('key2.secretKey: ${key2.secretKey.extractBytes()}');
        printOnFailure('key2.publicKey: ${key2.publicKey}');

        expect(key1.secretKey, hasLength(sut.secretKeyBytes));
        expect(key1.publicKey, hasLength(sut.publicKeyBytes));
        expect(key2.secretKey, hasLength(sut.secretKeyBytes));
        expect(key2.publicKey, hasLength(sut.publicKeyBytes));

        expect(key1.secretKey, key2.secretKey);
        expect(key1.publicKey, key2.publicKey);
      });
    });

    group('shared secret', () {
      test('generates shared secret for two peers', (sodium) {
        final sut = sodium.crypto.kem;

        final recipientKey = sut.keyPair();

        final (:ciphertext, sharedSecret: sharedSecret1) = sut.enc(
          publicKey: recipientKey.publicKey,
        );
        final sharedSecret2 = sut.dec(
          ciphertext: ciphertext,
          secretKey: recipientKey.secretKey,
        );

        printOnFailure('sharedSecret1: ${sharedSecret1.extractBytes()}');
        printOnFailure('sharedSecret2: ${sharedSecret2.extractBytes()}');

        expect(sharedSecret1, hasLength(sut.sharedSecretBytes));
        expect(sharedSecret2, hasLength(sut.sharedSecretBytes));

        expect(sharedSecret1, sharedSecret2);
      });

      test('fails if decoded by different key', (sodium) {
        final sut = sodium.crypto.kem;

        final recipientKey = sut.keyPair();
        final otherKey = sut.keyPair();

        final (:ciphertext, sharedSecret: sharedSecret1) = sut.enc(
          publicKey: recipientKey.publicKey,
        );
        final sharedSecret2 = sut.dec(
          ciphertext: ciphertext,
          secretKey: otherKey.secretKey,
        );

        printOnFailure('sharedSecret1: ${sharedSecret1.extractBytes()}');
        printOnFailure('sharedSecret2: ${sharedSecret2.extractBytes()}');

        expect(sharedSecret1, hasLength(sut.sharedSecretBytes));
        expect(sharedSecret2, hasLength(sut.sharedSecretBytes));

        expect(sharedSecret1, isNot(sharedSecret2));
      });
    });
  }
}
