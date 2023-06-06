import '../test_case.dart';

class KxTestCase extends TestCase {
  KxTestCase(super._runner);

  @override
  String get name => 'kx';

  @override
  void setupTests() {
    test('constants return correct values', (sodium) {
      final sut = sodium.crypto.kx;

      expect(sut.publicKeyBytes, 32, reason: 'publicKeyBytes');
      expect(sut.secretKeyBytes, 32, reason: 'secretKeyBytes');
      expect(sut.seedBytes, 32, reason: 'seedBytes');
      expect(sut.sessionKeyBytes, 32, reason: 'sessionKeyBytes');
    });

    test('keyPair generates different correct length keys', (sodium) {
      final sut = sodium.crypto.kx;

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

    group('seedKeypair', () {
      test('generates different correct length keys for different seeds',
          (sodium) {
        final sut = sodium.crypto.kx;

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
        final sut = sodium.crypto.kx;

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

    group('sessionKeys', () {
      test('generates correct session key pairs', (sodium) {
        final sut = sodium.crypto.kx;

        final clientKeys = sut.keyPair();
        final serverKeys = sut.keyPair();

        printOnFailure(
          'clientKeys.secretKey: ${clientKeys.secretKey.extractBytes()}',
        );
        printOnFailure('clientKeys.publicKey: ${clientKeys.publicKey}');
        printOnFailure(
          'serverKeys.secretKey: ${serverKeys.secretKey.extractBytes()}',
        );
        printOnFailure('serverKeys.publicKey: ${serverKeys.publicKey}');

        final clientSession = sut.clientSessionKeys(
          clientPublicKey: clientKeys.publicKey,
          clientSecretKey: clientKeys.secretKey,
          serverPublicKey: serverKeys.publicKey,
        );
        final serverSession = sut.serverSessionKeys(
          serverPublicKey: serverKeys.publicKey,
          serverSecretKey: serverKeys.secretKey,
          clientPublicKey: clientKeys.publicKey,
        );

        printOnFailure('clientSession.rx: ${clientSession.rx.extractBytes()}');
        printOnFailure('clientSession.tx: ${clientSession.tx.extractBytes()}');
        printOnFailure('serverSession.rx: ${serverSession.rx.extractBytes()}');
        printOnFailure('serverSession.tx: ${serverSession.tx.extractBytes()}');

        expect(clientSession.rx, isNot(clientSession.tx));
        expect(serverSession.rx, isNot(serverSession.tx));
        expect(clientSession.rx, serverSession.tx);
        expect(clientSession.tx, serverSession.rx);
      });
    });
  }
}
