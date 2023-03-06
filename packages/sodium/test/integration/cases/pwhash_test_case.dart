import 'dart:typed_data';

import '../test_case.dart';

class PwhashTestCase extends TestCase {
  final bool is32Bit;

  PwhashTestCase(super.runner, {this.is32Bit = false});

  @override
  String get name => 'pwhash';

  @override
  void setupTests() {
    testSumo('constants return correct values', (sodium) {
      final sut = sodium.crypto.pwhash;

      expect(sut.bytesMin, 16, reason: 'bytesMin');
      expect(sut.bytesMax, 4294967295, reason: 'bytesMax');

      expect(sut.memLimitMin, 8192, reason: 'memLimitMin');
      expect(sut.memLimitInteractive, 67108864, reason: 'memLimitInteractive');
      expect(sut.memLimitModerate, 268435456, reason: 'memLimitModerate');
      expect(sut.memLimitSensitive, 1073741824, reason: 'memLimitSensitive');
      expect(
        sut.memLimitMax,
        is32Bit ? 2147483648 : 4398046510080,
        reason: 'memLimitMax',
      );

      expect(sut.opsLimitMin, 1, reason: 'opsLimitMin');
      expect(sut.opsLimitInteractive, 2, reason: 'opsLimitInteractive');
      expect(sut.opsLimitModerate, 3, reason: 'opsLimitModerate');
      expect(sut.opsLimitSensitive, 4, reason: 'opsLimitSensitive');
      expect(sut.opsLimitMax, 4294967295, reason: 'opsLimitMax');

      expect(sut.passwdMin, 0, reason: 'passwdMin');
      expect(sut.passwdMax, 4294967295, reason: 'passwdMax');

      expect(sut.saltBytes, 16, reason: 'saltBytes');

      expect(sut.strBytes, 128, reason: 'strBytes');
    });

    group('call', () {
      testSumo('generates different hashes for different inputs', (sodium) {
        final sut = sodium.crypto.pwhash;

        const outLen = 32;
        final password = Int8List.fromList(List.generate(10, (index) => index));

        final pwHash1 = sut(
          outLen: outLen,
          password: password,
          salt: sodium.randombytes.buf(sut.saltBytes),
          memLimit: sut.memLimitMin,
          opsLimit: sut.opsLimitMin,
        );
        final pwHash2 = sut(
          outLen: outLen,
          password: password,
          salt: sodium.randombytes.buf(sut.saltBytes),
          memLimit: sut.memLimitMin,
          opsLimit: sut.opsLimitMin,
        );
        printOnFailure('pwHash1: $pwHash1');
        printOnFailure('pwHash2: $pwHash2');

        expect(pwHash1, hasLength(outLen));
        expect(pwHash2, hasLength(outLen));
        expect(pwHash1, isNot(pwHash2));
      });

      testSumo('generates same hashes for same inputs', (sodium) {
        final sut = sodium.crypto.pwhash;

        const outLen = 32;
        final password = Int8List.fromList(List.generate(10, (index) => index));
        final salt = sodium.randombytes.buf(sut.saltBytes);

        final pwHash1 = sut(
          outLen: outLen,
          password: password,
          salt: salt,
          memLimit: sut.memLimitMin,
          opsLimit: sut.opsLimitMin,
        );
        final pwHash2 = sut(
          outLen: outLen,
          password: password,
          salt: salt,
          memLimit: sut.memLimitMin,
          opsLimit: sut.opsLimitMin,
        );
        printOnFailure('pwHash1: $pwHash1');
        printOnFailure('pwHash2: $pwHash2');

        expect(pwHash1, hasLength(outLen));
        expect(pwHash2, hasLength(outLen));
        expect(pwHash1, pwHash2);
      });
    });

    group('str and strVerify', () {
      testSumo('verify succeeds if password is same', (sodium) {
        final sut = sodium.crypto.pwhash;

        const password = 'password1';
        final pwHash = sut.str(
          password: password,
          memLimit: sut.memLimitMin,
          opsLimit: sut.opsLimitMin,
        );
        printOnFailure('pwHash: $pwHash');

        expect(pwHash, hasLength(lessThanOrEqualTo(sut.strBytes)));

        final verified = sut.strVerify(
          passwordHash: pwHash,
          password: password,
        );

        expect(verified, isTrue);
      });

      testSumo('verify failes if password is different', (sodium) {
        final sut = sodium.crypto.pwhash;

        final pwHash = sut.str(
          password: 'password1',
          memLimit: sut.memLimitMin,
          opsLimit: sut.opsLimitMin,
        );
        printOnFailure('pwHash: $pwHash');

        expect(pwHash, hasLength(lessThanOrEqualTo(sut.strBytes)));

        final verified = sut.strVerify(
          passwordHash: pwHash,
          password: 'password2',
        );

        expect(verified, isFalse);
      });
    });

    group('str and strNeedsRehash', () {
      testSumo('does not need rehash if params are the same', (sodium) {
        final sut = sodium.crypto.pwhash;

        final pwHash = sut.str(
          password: 'password1',
          memLimit: sut.memLimitMin,
          opsLimit: sut.opsLimitMin,
        );
        printOnFailure('pwHash: $pwHash');

        final needsRehash = sut.strNeedsRehash(
          passwordHash: pwHash,
          memLimit: sut.memLimitMin,
          opsLimit: sut.opsLimitMin,
        );

        expect(needsRehash, isFalse);
      });

      testSumo('does need rehash if params are different same', (sodium) {
        final sut = sodium.crypto.pwhash;

        final pwHash = sut.str(
          password: 'password1',
          memLimit: sut.memLimitMin,
          opsLimit: sut.opsLimitMin,
        );
        printOnFailure('pwHash: $pwHash');

        final needsRehash = sut.strNeedsRehash(
          passwordHash: pwHash,
          memLimit: sut.memLimitInteractive,
          opsLimit: sut.opsLimitMin,
        );

        expect(needsRehash, isTrue);
      });
    });
  }
}
