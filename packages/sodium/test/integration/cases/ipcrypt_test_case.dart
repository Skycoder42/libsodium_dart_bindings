import '../test_case.dart';

class IpcryptTestCase extends TestCase {
  IpcryptTestCase(super._runner);

  @override
  String get name => 'ipcrypt';

  @override
  void setupTests() {
    group('(default)', () {
      test('constants return correct values', (sodium) {
        final sut = sodium.crypto.ipcrypt;

        expect(sut.bytes, 16, reason: 'bytes');
        expect(sut.keyBytes, 16, reason: 'keyBytes');
      });

      test('keygen generates different correct length keys', (sodium) {
        final sut = sodium.crypto.ipcrypt;

        final key1 = sut.keygen();
        final key2 = sut.keygen();

        printOnFailure('key1: ${key1.extractBytes()}');
        printOnFailure('key2: ${key2.extractBytes()}');

        expect(key1, hasLength(sut.keyBytes));
        expect(key2, hasLength(sut.keyBytes));

        expect(key1, isNot(key2));
      });

      test('can encrypt and decrypt data', (sodium) {
        final sut = sodium.crypto.ipcrypt;

        final key = sut.keygen();
        final ipAddress = sodium.ipFromString('127.0.0.1');

        printOnFailure('key: ${key.extractBytes()}');
        printOnFailure('address: $ipAddress');

        final cipherText = sut.encrypt(input: ipAddress, key: key);

        printOnFailure('cipherText: $cipherText');

        final restored = sut.decrypt(input: cipherText, key: key);

        printOnFailure('restored: $restored');

        expect(restored, ipAddress);
      });
    });

    group('nd', () {
      test('constants return correct values', (sodium) {
        final sut = sodium.crypto.ipcrypt.nd;

        expect(sut.keyBytes, 16, reason: 'keyBytes');
        expect(sut.tweakBytes, 8, reason: 'tweakBytes');
        expect(sut.inputBytes, 16, reason: 'inputBytes');
        expect(sut.outputBytes, 24, reason: 'outputBytes');
      });

      test('keygen generates different correct length keys', (sodium) {
        final sut = sodium.crypto.ipcrypt.nd;

        final key1 = sut.keygen();
        final key2 = sut.keygen();

        printOnFailure('key1: ${key1.extractBytes()}');
        printOnFailure('key2: ${key2.extractBytes()}');

        expect(key1, hasLength(sut.keyBytes));
        expect(key2, hasLength(sut.keyBytes));

        expect(key1, isNot(key2));
      });

      test('can encrypt and decrypt data', (sodium) {
        final sut = sodium.crypto.ipcrypt.nd;

        final key = sut.keygen();
        final ipAddress = sodium.ipFromString('127.0.0.1');
        final tweak = sodium.randombytes.buf(sut.tweakBytes);

        printOnFailure('key: ${key.extractBytes()}');
        printOnFailure('address: $ipAddress');
        printOnFailure('tweak: $tweak');

        final cipherText = sut.encrypt(
          input: ipAddress,
          key: key,
          tweak: tweak,
        );

        printOnFailure('cipherText: $cipherText');

        final restored = sut.decrypt(ciphertext: cipherText, key: key);

        printOnFailure('restored: $restored');

        expect(restored, ipAddress);
      });
    });

    group('ndx', () {
      test('constants return correct values', (sodium) {
        final sut = sodium.crypto.ipcrypt.ndx;

        expect(sut.keyBytes, 32, reason: 'keyBytes');
        expect(sut.tweakBytes, 16, reason: 'tweakBytes');
        expect(sut.inputBytes, 16, reason: 'inputBytes');
        expect(sut.outputBytes, 32, reason: 'outputBytes');
      });

      test('keygen generates different correct length keys', (sodium) {
        final sut = sodium.crypto.ipcrypt.ndx;

        final key1 = sut.keygen();
        final key2 = sut.keygen();

        printOnFailure('key1: ${key1.extractBytes()}');
        printOnFailure('key2: ${key2.extractBytes()}');

        expect(key1, hasLength(sut.keyBytes));
        expect(key2, hasLength(sut.keyBytes));

        expect(key1, isNot(key2));
      });

      test('can encrypt and decrypt data', (sodium) {
        final sut = sodium.crypto.ipcrypt.ndx;

        final key = sut.keygen();
        final ipAddress = sodium.ipFromString('127.0.0.1');
        final tweak = sodium.randombytes.buf(sut.tweakBytes);

        printOnFailure('key: ${key.extractBytes()}');
        printOnFailure('address: $ipAddress');
        printOnFailure('tweak: $tweak');

        final cipherText = sut.encrypt(
          input: ipAddress,
          key: key,
          tweak: tweak,
        );

        printOnFailure('cipherText: $cipherText');

        final restored = sut.decrypt(ciphertext: cipherText, key: key);

        printOnFailure('restored: $restored');

        expect(restored, ipAddress);
      });
    });

    group('pfx', () {
      test('constants return correct values', (sodium) {
        final sut = sodium.crypto.ipcrypt.pfx;

        expect(sut.bytes, 16, reason: 'bytes');
        expect(sut.keyBytes, 32, reason: 'keyBytes');
      });

      test('keygen generates different correct length keys', (sodium) {
        final sut = sodium.crypto.ipcrypt.pfx;

        final key1 = sut.keygen();
        final key2 = sut.keygen();

        printOnFailure('key1: ${key1.extractBytes()}');
        printOnFailure('key2: ${key2.extractBytes()}');

        expect(key1, hasLength(sut.keyBytes));
        expect(key2, hasLength(sut.keyBytes));

        expect(key1, isNot(key2));
      });

      test('can encrypt and decrypt data', (sodium) {
        final sut = sodium.crypto.ipcrypt.pfx;

        final key = sut.keygen();
        final ipAddress = sodium.ipFromString('127.0.0.1');

        printOnFailure('key: ${key.extractBytes()}');
        printOnFailure('address: $ipAddress');

        final cipherText = sut.encrypt(input: ipAddress, key: key);

        printOnFailure('cipherText: $cipherText');

        final restored = sut.decrypt(input: cipherText, key: key);

        printOnFailure('restored: $restored');

        expect(restored, ipAddress);
      });
    });
  }
}
