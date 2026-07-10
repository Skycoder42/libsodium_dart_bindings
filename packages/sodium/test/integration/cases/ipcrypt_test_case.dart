import 'package:sodium/src/api/helpers/platform_types/internet_address_fallback.dart'
    if (dart.library.io) 'package:sodium/src/api/helpers/platform_types/internet_address_io.dart'
    as ia;

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

        final restored = sut.decrypt(cipherText: cipherText, key: key);

        printOnFailure('restored: $restored');

        expect(restored, ipAddress);
      });

      test('encrypts deterministically', (sodium) {
        final sut = sodium.crypto.ipcrypt;

        final key = sut.keygen();
        final ipAddress = sodium.ipFromString('192.0.2.1');

        final cipherText1 = sut.encrypt(input: ipAddress, key: key);
        final cipherText2 = sut.encrypt(input: ipAddress, key: key);

        printOnFailure('cipherText1: $cipherText1');
        printOnFailure('cipherText2: $cipherText2');

        // Identical input + key always produce identical ciphertext.
        expect(cipherText1, cipherText2);

        // A different key produces a different ciphertext.
        final otherKey = sut.keygen();
        final cipherText3 = sut.encrypt(input: ipAddress, key: otherKey);
        expect(cipherText3, isNot(cipherText1));
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

        final restored = sut.decrypt(cipherText: cipherText, key: key);

        printOnFailure('restored: $restored');

        expect(restored, ipAddress);
      });

      test('encrypts non-deterministically with different tweaks', (sodium) {
        final sut = sodium.crypto.ipcrypt.nd;

        final key = sut.keygen();
        final ipAddress = sodium.ipFromString('192.0.2.1');
        final tweak1 = sodium.randombytes.buf(sut.tweakBytes);
        final tweak2 = sodium.randombytes.buf(sut.tweakBytes);

        printOnFailure('tweak1: $tweak1');
        printOnFailure('tweak2: $tweak2');

        final cipherText1 = sut.encrypt(
          input: ipAddress,
          key: key,
          tweak: tweak1,
        );
        final cipherText2 = sut.encrypt(
          input: ipAddress,
          key: key,
          tweak: tweak2,
        );

        printOnFailure('cipherText1: $cipherText1');
        printOnFailure('cipherText2: $cipherText2');

        // Same input + key but different tweaks produce different ciphertexts.
        expect(cipherText1, isNot(cipherText2));

        // Both still decrypt back to the original address.
        expect(sut.decrypt(cipherText: cipherText1, key: key), ipAddress);
        expect(sut.decrypt(cipherText: cipherText2, key: key), ipAddress);
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

        final restored = sut.decrypt(cipherText: cipherText, key: key);

        printOnFailure('restored: $restored');

        expect(restored, ipAddress);
      });

      test('encrypts non-deterministically with different tweaks', (sodium) {
        final sut = sodium.crypto.ipcrypt.ndx;

        final key = sut.keygen();
        final ipAddress = sodium.ipFromString('192.0.2.1');
        final tweak1 = sodium.randombytes.buf(sut.tweakBytes);
        final tweak2 = sodium.randombytes.buf(sut.tweakBytes);

        printOnFailure('tweak1: $tweak1');
        printOnFailure('tweak2: $tweak2');

        final cipherText1 = sut.encrypt(
          input: ipAddress,
          key: key,
          tweak: tweak1,
        );
        final cipherText2 = sut.encrypt(
          input: ipAddress,
          key: key,
          tweak: tweak2,
        );

        printOnFailure('cipherText1: $cipherText1');
        printOnFailure('cipherText2: $cipherText2');

        // Same input + key but different tweaks produce different ciphertexts.
        expect(cipherText1, isNot(cipherText2));

        // Both still decrypt back to the original address.
        expect(sut.decrypt(cipherText: cipherText1, key: key), ipAddress);
        expect(sut.decrypt(cipherText: cipherText2, key: key), ipAddress);
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

        final restored = sut.decrypt(cipherText: cipherText, key: key);

        printOnFailure('restored: $restored');

        expect(restored, ipAddress);
      });

      test('preserves shared address prefixes', (sodium) {
        final sut = sodium.crypto.ipcrypt.pfx;

        final key = sut.keygen();

        // Two addresses in the same /24 subnet: their 16-byte IPv4-mapped forms
        // are identical through byte index 14 and differ only in the final
        // octet (byte 15).
        final address1 = sodium.ipFromString('192.0.2.10');
        final address2 = sodium.ipFromString('192.0.2.20');

        final cipherText1 = sut.encrypt(input: address1, key: key);
        final cipherText2 = sut.encrypt(input: address2, key: key);

        printOnFailure('cipherText1: $cipherText1');
        printOnFailure('cipherText2: $cipherText2');

        // Prefix preservation: the shared prefix survives at the same byte
        // offset as in the plaintext, and only the differing host part changes.
        expect(cipherText1.sublist(0, 15), cipherText2.sublist(0, 15));
        expect(cipherText1[15], isNot(cipherText2[15]));
      });
    });

    group('IpAddress', () {
      test('round-trips an IPv4 string', (sodium) {
        final ipAddress = sodium.ipFromString('192.0.2.1');

        printOnFailure('bytes: ${ipAddress.bytes}');

        expect(ipAddress.addressString, '192.0.2.1');
        expect(ipAddress.bytes, hasLength(16));
      });

      test('round-trips an IPv6 string', (sodium) {
        final ipAddress = sodium.ipFromString('2001:db8::1');

        printOnFailure('bytes: ${ipAddress.bytes}');

        expect(ipAddress.addressString, '2001:db8::1');
        expect(ipAddress.bytes, hasLength(16));
      });

      test('round-trips raw bytes', (sodium) {
        final original = sodium.ipFromString('2001:db8::1');
        final restored = sodium.ipFromBytes(original.bytes);

        printOnFailure('bytes: ${original.bytes}');

        expect(restored.bytes, original.bytes);
        expect(restored.addressString, '2001:db8::1');
        expect(restored, original);
      });

      test('maps an IPv4 address to an equivalent IPv6 address', (sodium) {
        final ipAddress = sodium.ipFromAddress(
          ia.internetAddressFromString('127.0.0.1'),
        );

        printOnFailure('address: ${ipAddress.address}');
        printOnFailure('bytes: ${ipAddress.bytes}');

        // The platform-native address is a valid IPv4-mapped IPv6 address.
        expect(
          ipAddress.address,
          ia.internetAddressFromString('::ffff:127.0.0.1'),
        );

        // ...that is equivalent to the original IPv4 address: it collapses
        // back to the IPv4 string form and is byte-identical to parsing the
        // IPv4-mapped IPv6 representation directly.
        expect(ipAddress.addressString, '127.0.0.1');
        expect(ipAddress, sodium.ipFromString('::ffff:127.0.0.1'));
      }, testOn: 'vm');
    });
  }
}
