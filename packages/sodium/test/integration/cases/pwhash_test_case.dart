import 'dart:typed_data';

// dart_pre_commit:ignore-library-import
import 'package:sodium/sodium.dart';
import 'package:test/test.dart';

import '../test_case.dart';

class PwhashTestCase extends TestCase {
  @override
  String get name => 'pwhash';

  Pwhash get sut => sodium.crypto.pwhash;

  @override
  void setupTests() {
    test('constants return correct values', () {
      expect(sut.bytesMin, 16, reason: 'bytesMin');
      expect(sut.bytesMax, 4294967295, reason: 'bytesMax');

      expect(sut.memLimitMin, 8192, reason: 'memLimitMin');
      expect(sut.memLimitInteractive, 67108864, reason: 'memLimitInteractive');
      expect(sut.memLimitModerate, 268435456, reason: 'memLimitModerate');
      expect(sut.memLimitSensitive, 1073741824, reason: 'memLimitSensitive');
      expect(sut.memLimitMax, 4398046510080, reason: 'memLimitMax');

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
      test('generates different hashes for different inputs', () {
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

      test('generates same hashes for same inputs', () {
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
      test('verify succeeds if password is same', () {
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

      test('verify failes if password is different', () {
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
      test('does not need rehash if params are the same', () {
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

      test('does need rehash if params are different same', () {
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
