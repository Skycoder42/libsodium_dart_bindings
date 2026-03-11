// ignore_for_file: unnecessary_lambdas for mocking

@TestOn('dart-vm')
library;

import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/api/string_x.dart';
import 'package:sodium/src/api/sumo/pwhash.dart';
import 'package:sodium/src/ffi/api/sumo/pwhash_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.wrapper.dart';
import 'package:test/test.dart';

import '../../../../test_constants_mapping.dart';
import '../../../../test_data.dart';
import '../../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  late PwhashFFI sut;

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);

    sut = PwhashFFI(mockSodium);
  });

  testConstantsMapping([
    (
      () => mockSodium.crypto_pwhash_bytes_min(),
      () => sut.bytesMin,
      'bytesMin',
    ),
    (
      () => mockSodium.crypto_pwhash_bytes_max(),
      () => sut.bytesMax,
      'bytesMax',
    ),
    (
      () => mockSodium.crypto_pwhash_memlimit_min(),
      () => sut.memLimitMin,
      'memLimitMin',
    ),
    (
      () => mockSodium.crypto_pwhash_memlimit_interactive(),
      () => sut.memLimitInteractive,
      'memLimitInteractive',
    ),
    (
      () => mockSodium.crypto_pwhash_memlimit_moderate(),
      () => sut.memLimitModerate,
      'memLimitModerate',
    ),
    (
      () => mockSodium.crypto_pwhash_memlimit_sensitive(),
      () => sut.memLimitSensitive,
      'memLimitSensitive',
    ),
    (
      () => mockSodium.crypto_pwhash_memlimit_max(),
      () => sut.memLimitMax,
      'memLimitMax',
    ),
    (
      () => mockSodium.crypto_pwhash_opslimit_min(),
      () => sut.opsLimitMin,
      'opsLimitMin',
    ),
    (
      () => mockSodium.crypto_pwhash_opslimit_interactive(),
      () => sut.opsLimitInteractive,
      'opsLimitInteractive',
    ),
    (
      () => mockSodium.crypto_pwhash_opslimit_moderate(),
      () => sut.opsLimitModerate,
      'opsLimitModerate',
    ),
    (
      () => mockSodium.crypto_pwhash_opslimit_sensitive(),
      () => sut.opsLimitSensitive,
      'opsLimitSensitive',
    ),
    (
      () => mockSodium.crypto_pwhash_opslimit_max(),
      () => sut.opsLimitMax,
      'opsLimitMax',
    ),
    (
      () => mockSodium.crypto_pwhash_passwd_min(),
      () => sut.passwdMin,
      'passwdMin',
    ),
    (
      () => mockSodium.crypto_pwhash_passwd_max(),
      () => sut.passwdMax,
      'passwdMax',
    ),
    (
      () => mockSodium.crypto_pwhash_saltbytes(),
      () => sut.saltBytes,
      'saltBytes',
    ),
    (() => mockSodium.crypto_pwhash_strbytes(), () => sut.strBytes, 'strBytes'),
    (
      () => mockSodium.crypto_pwhash_alg_default(),
      () => CryptoPwhashAlgorithm.defaultAlg.toValue(mockSodium),
      'CrypoPwhashAlgorithm.defaultAlg',
    ),
    (
      () => mockSodium.crypto_pwhash_alg_argon2i13(),
      () => CryptoPwhashAlgorithm.argon2i13.toValue(mockSodium),
      'CrypoPwhashAlgorithm.argon2i13',
    ),
    (
      () => mockSodium.crypto_pwhash_alg_argon2id13(),
      () => CryptoPwhashAlgorithm.argon2id13.toValue(mockSodium),
      'CrypoPwhashAlgorithm.argon2id13',
    ),
  ]);

  group('methods', () {
    setUp(() {
      mockAllocArray(mockSodium);
      when(() => mockSodium.crypto_pwhash_bytes_min()).thenReturn(0);
      when(() => mockSodium.crypto_pwhash_bytes_max()).thenReturn(10);
      when(() => mockSodium.crypto_pwhash_memlimit_min()).thenReturn(0);
      when(() => mockSodium.crypto_pwhash_memlimit_max()).thenReturn(10);
      when(() => mockSodium.crypto_pwhash_opslimit_min()).thenReturn(0);
      when(() => mockSodium.crypto_pwhash_opslimit_max()).thenReturn(10);
      when(() => mockSodium.crypto_pwhash_passwd_min()).thenReturn(0);
      when(() => mockSodium.crypto_pwhash_passwd_max()).thenReturn(10);
      when(() => mockSodium.crypto_pwhash_saltbytes()).thenReturn(5);
      when(() => mockSodium.crypto_pwhash_strbytes()).thenReturn(5);
    });

    group('call', () {
      test('asserts if outlen is invalid', () {
        expect(
          () => sut.call(
            outLen: 20,
            password: Int8List(0),
            salt: Uint8List(5),
            opsLimit: 0,
            memLimit: 0,
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_pwhash_bytes_min());
        verify(() => mockSodium.crypto_pwhash_bytes_max());
      });

      test('asserts if password is invalid', () {
        expect(
          () => sut.call(
            outLen: 0,
            password: Int8List(20),
            salt: Uint8List(5),
            opsLimit: 0,
            memLimit: 0,
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_pwhash_passwd_min());
        verify(() => mockSodium.crypto_pwhash_passwd_max());
      });

      test('asserts if salt is invalid', () {
        expect(
          () => sut.call(
            outLen: 0,
            password: Int8List(0),
            salt: Uint8List(20),
            opsLimit: 0,
            memLimit: 0,
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_pwhash_saltbytes());
      });

      test('asserts if opsLimit is invalid', () {
        expect(
          () => sut.call(
            outLen: 0,
            password: Int8List(0),
            salt: Uint8List(5),
            opsLimit: 20,
            memLimit: 0,
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_pwhash_opslimit_min());
        verify(() => mockSodium.crypto_pwhash_opslimit_max());
      });

      test('asserts if memLimit is invalid', () {
        expect(
          () => sut.call(
            outLen: 0,
            password: Int8List(0),
            salt: Uint8List(5),
            opsLimit: 0,
            memLimit: 20,
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_pwhash_memlimit_min());
        verify(() => mockSodium.crypto_pwhash_memlimit_max());
      });

      test('calls crypto_pwhash with correct arguments', () {
        when(() => mockSodium.crypto_pwhash_alg_argon2id13()).thenReturn(42);
        when(
          () => mockSodium.crypto_pwhash(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(0);

        const password = [1, 2, 3];
        const salt = [0, 2, 4, 6, 8];
        sut.call(
          outLen: 5,
          password: Int8List.fromList(password),
          salt: Uint8List.fromList(salt),
          opsLimit: 3,
          memLimit: 7,
          alg: CryptoPwhashAlgorithm.argon2id13,
        );

        verify(() => mockSodium.crypto_pwhash_alg_argon2id13());
        verify(
          () => mockSodium.crypto_pwhash(
            any(that: isNot(nullptr)),
            5,
            any(that: hasRawData<Char>(password)),
            password.length,
            any(that: hasRawData<UnsignedChar>(salt)),
            3,
            7,
            42,
          ),
        );
        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test('throws if crypto_pwhash returns non zero result', () {
        when(() => mockSodium.crypto_pwhash_alg_argon2i13()).thenReturn(0);
        when(
          () => mockSodium.crypto_pwhash(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(1);

        expect(
          () => sut.call(
            outLen: 5,
            password: Int8List.fromList(const [1, 2, 3]),
            salt: Uint8List.fromList(const [0, 2, 4, 6, 8]),
            opsLimit: 3,
            memLimit: 7,
            alg: CryptoPwhashAlgorithm.argon2i13,
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.crypto_pwhash_alg_argon2i13());
        verify(() => mockSodium.sodium_free(any())).called(3);
      });

      test('returns secure key with result of correct length', () {
        when(() => mockSodium.crypto_pwhash_alg_default()).thenReturn(2);
        const testData = [5, 4, 3, 2, 1];
        when(
          () => mockSodium.crypto_pwhash(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenAnswer((i) {
          fillPointer(
            i.positionalArguments.first as Pointer<UnsignedChar>,
            testData,
          );
          return 0;
        });

        final res = sut.call(
          outLen: testData.length,
          password: Int8List.fromList(const [1, 2, 3]),
          salt: Uint8List.fromList(const [0, 2, 4, 6, 8]),
          opsLimit: 3,
          memLimit: 7,
        );

        expect(res.extractBytes(), testData);
        verify(() => mockSodium.crypto_pwhash_alg_default());
      });
    });

    group('str', () {
      test('asserts if password is invalid', () {
        expect(
          () => sut.str(password: 'x' * 20, opsLimit: 0, memLimit: 0),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_pwhash_passwd_min());
        verify(() => mockSodium.crypto_pwhash_passwd_max());
      });

      test('asserts if opsLimit is invalid', () {
        expect(
          () => sut.str(password: '', opsLimit: 20, memLimit: 0),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_pwhash_opslimit_min());
        verify(() => mockSodium.crypto_pwhash_opslimit_max());
      });

      test('asserts if memLimit is invalid', () {
        expect(
          () => sut.str(password: '', opsLimit: 0, memLimit: 20),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_pwhash_memlimit_min());
        verify(() => mockSodium.crypto_pwhash_memlimit_max());
      });

      test('calls crypto_pwhash_str with correct arguments', () {
        when(
          () => mockSodium.crypto_pwhash_str(any(), any(), any(), any(), any()),
        ).thenReturn(0);

        const password = 'abc123';
        sut.str(password: password, opsLimit: 5, memLimit: 2);

        verify(
          () => mockSodium.crypto_pwhash_str(
            any(that: hasRawData<Char>(List.filled(5, 0))),
            any(that: hasRawData<Char>(password.toCharArray())),
            password.length,
            5,
            2,
          ),
        );
        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test('throws if crypto_pwhash_str returns non zero result', () {
        when(
          () => mockSodium.crypto_pwhash_str(any(), any(), any(), any(), any()),
        ).thenReturn(1);

        expect(
          () => sut.str(password: 'abc123', opsLimit: 5, memLimit: 2),
          throwsA(isA<SodiumException>()),
        );
        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test('returns password hash of full length', () {
        const testHash = [0x41, 0x42, 0x44, 0x48, 0x50];
        when(
          () => mockSodium.crypto_pwhash_str(any(), any(), any(), any(), any()),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments.first as Pointer<Char>, testHash);
          return 0;
        });

        final result = sut.str(password: 'abc123', opsLimit: 5, memLimit: 2);

        expect(result, 'ABDHP');
      });

      test('returns password hash of shorter length', () {
        const testHash = [0x41, 0x42, 0x43];
        when(
          () => mockSodium.crypto_pwhash_str(any(), any(), any(), any(), any()),
        ).thenAnswer((i) {
          fillPointer(i.positionalArguments.first as Pointer<Char>, testHash);
          return 0;
        });

        final result = sut.str(password: 'abc123', opsLimit: 5, memLimit: 2);

        expect(result, 'ABC');
      });
    });

    group('strVerify', () {
      test('asserts if passwordHash is invalid', () {
        expect(
          () => sut.strVerify(passwordHash: 'x' * 20, password: ''),
          throwsA(isA<ArgumentError>()),
        );

        verify(() => mockSodium.crypto_pwhash_strbytes());
      });

      test('asserts if password is invalid', () {
        expect(
          () => sut.strVerify(passwordHash: 'x' * 5, password: 'x' * 20),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_pwhash_passwd_min());
        verify(() => mockSodium.crypto_pwhash_passwd_max());
      });

      test('calls crypto_pwhash_str_verify with correct arguments', () {
        when(
          () => mockSodium.crypto_pwhash_str_verify(any(), any(), any()),
        ).thenReturn(0);

        const password = 'abc123';
        const passwordHash = 'xy';
        final result = sut.strVerify(
          passwordHash: passwordHash,
          password: password,
        );

        expect(result, isTrue);
        verify(
          () => mockSodium.crypto_pwhash_str_verify(
            any(
              that: hasRawData<Char>(passwordHash.toCharArray(memoryWidth: 5)),
            ),
            any(that: hasRawData<Char>(password.toCharArray())),
            password.length,
          ),
        );
        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test(
        'returns false if crypto_pwhash_str_verify returns non zero result',
        () {
          when(
            () => mockSodium.crypto_pwhash_str_verify(any(), any(), any()),
          ).thenReturn(1);

          final result = sut.strVerify(
            password: 'abc123',
            passwordHash: '12345',
          );

          expect(result, isFalse);
          verify(() => mockSodium.sodium_free(any())).called(2);
        },
      );
    });

    group('strNeedsRehash', () {
      test('asserts if passwordHash is invalid', () {
        expect(
          () => sut.strNeedsRehash(
            passwordHash: 'x' * 20,
            opsLimit: 0,
            memLimit: 0,
          ),
          throwsA(isA<ArgumentError>()),
        );

        verify(() => mockSodium.crypto_pwhash_strbytes());
      });

      test('asserts if opsLimit is invalid', () {
        expect(
          () => sut.strNeedsRehash(
            passwordHash: 'x' * 5,
            opsLimit: 20,
            memLimit: 0,
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_pwhash_opslimit_min());
        verify(() => mockSodium.crypto_pwhash_opslimit_max());
      });

      test('asserts if memLimit is invalid', () {
        expect(
          () => sut.strNeedsRehash(
            passwordHash: 'x' * 5,
            opsLimit: 0,
            memLimit: 20,
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_pwhash_memlimit_min());
        verify(() => mockSodium.crypto_pwhash_memlimit_max());
      });

      test('calls crypto_pwhash_str_needs_rehash with correct arguments', () {
        when(
          () => mockSodium.crypto_pwhash_str_needs_rehash(any(), any(), any()),
        ).thenReturn(0);

        const passwordHash = 'wz_';
        sut.strNeedsRehash(
          passwordHash: passwordHash,
          opsLimit: 9,
          memLimit: 8,
        );

        verify(
          () => mockSodium.crypto_pwhash_str_needs_rehash(
            any(
              that: hasRawData<Char>(passwordHash.toCharArray(memoryWidth: 5)),
            ),
            9,
            8,
          ),
        );
        verify(() => mockSodium.sodium_free(any())).called(1);
      });

      testData<(int, bool)>(
        'maps return value to correct result',
        const [(0, false), (1, true)],
        (fixture) {
          when(
            () =>
                mockSodium.crypto_pwhash_str_needs_rehash(any(), any(), any()),
          ).thenReturn(fixture.$1);

          final result = sut.strNeedsRehash(
            passwordHash: 'hash',
            opsLimit: 0,
            memLimit: 0,
          );

          expect(result, fixture.$2);
        },
      );

      test(
        'throws if crypto_pwhash_str_needs_rehash returns invalid value',
        () {
          when(
            () =>
                mockSodium.crypto_pwhash_str_needs_rehash(any(), any(), any()),
          ).thenReturn(-1);

          expect(
            () => sut.strNeedsRehash(
              passwordHash: 'hash',
              opsLimit: 0,
              memLimit: 0,
            ),
            throwsA(isA<SodiumException>()),
          );
          verify(() => mockSodium.sodium_free(any())).called(1);
        },
      );
    });
  });
}
