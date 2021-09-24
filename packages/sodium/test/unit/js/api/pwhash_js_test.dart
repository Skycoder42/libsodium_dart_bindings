import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/pwhash.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/pwhash_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../test_constants_mapping.dart';

class MockLibSodiumJS extends Mock implements LibSodiumJS {}

void main() {
  final mockSodium = MockLibSodiumJS();

  late PwhashJS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);

    sut = PwhashJS(mockSodium);
  });

  testConstantsMapping([
    Tuple3(
      () => mockSodium.crypto_pwhash_BYTES_MIN,
      () => sut.bytesMin,
      'bytesMin',
    ),
    Tuple3(
      () => mockSodium.crypto_pwhash_BYTES_MAX,
      () => sut.bytesMax,
      'bytesMax',
    ),
    Tuple3(
      () => mockSodium.crypto_pwhash_MEMLIMIT_MIN,
      () => sut.memLimitMin,
      'memLimitMin',
    ),
    Tuple3(
      () => mockSodium.crypto_pwhash_MEMLIMIT_INTERACTIVE,
      () => sut.memLimitInteractive,
      'memLimitInteractive',
    ),
    Tuple3(
      () => mockSodium.crypto_pwhash_MEMLIMIT_MODERATE,
      () => sut.memLimitModerate,
      'memLimitModerate',
    ),
    Tuple3(
      () => mockSodium.crypto_pwhash_MEMLIMIT_SENSITIVE,
      () => sut.memLimitSensitive,
      'memLimitSensitive',
    ),
    Tuple3(
      () => mockSodium.crypto_pwhash_MEMLIMIT_MAX,
      () => sut.memLimitMax,
      'memLimitMax',
    ),
    Tuple3(
      () => mockSodium.crypto_pwhash_OPSLIMIT_MIN,
      () => sut.opsLimitMin,
      'opsLimitMin',
    ),
    Tuple3(
      () => mockSodium.crypto_pwhash_OPSLIMIT_INTERACTIVE,
      () => sut.opsLimitInteractive,
      'opsLimitInteractive',
    ),
    Tuple3(
      () => mockSodium.crypto_pwhash_OPSLIMIT_MODERATE,
      () => sut.opsLimitModerate,
      'opsLimitModerate',
    ),
    Tuple3(
      () => mockSodium.crypto_pwhash_OPSLIMIT_SENSITIVE,
      () => sut.opsLimitSensitive,
      'opsLimitSensitive',
    ),
    Tuple3(
      () => mockSodium.crypto_pwhash_OPSLIMIT_MAX,
      () => sut.opsLimitMax,
      'opsLimitMax',
    ),
    Tuple3(
      () => mockSodium.crypto_pwhash_PASSWD_MIN,
      () => sut.passwdMin,
      'passwdMin',
    ),
    Tuple3(
      () => mockSodium.crypto_pwhash_PASSWD_MAX,
      () => sut.passwdMax,
      'passwdMax',
    ),
    Tuple3(
      () => mockSodium.crypto_pwhash_SALTBYTES,
      () => sut.saltBytes,
      'saltBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_pwhash_STRBYTES,
      () => sut.strBytes,
      'strBytes',
    ),
    Tuple3(
      () => mockSodium.crypto_pwhash_ALG_DEFAULT,
      () => CryptoPwhashAlgorithm.defaultAlg.getValue(mockSodium),
      'CrypoPwhashAlgorithm.defaultAlg',
    ),
    Tuple3(
      () => mockSodium.crypto_pwhash_ALG_DEFAULT,
      () => CryptoPwhashAlgorithm.defaultAlg.getValue(mockSodium),
      'CrypoPwhashAlgorithm.defaultAlg',
    ),
    Tuple3(
      () => mockSodium.crypto_pwhash_ALG_ARGON2I13,
      () => CryptoPwhashAlgorithm.argon2i13.getValue(mockSodium),
      'CrypoPwhashAlgorithm.argon2i13',
    ),
    Tuple3(
      () => mockSodium.crypto_pwhash_ALG_ARGON2ID13,
      () => CryptoPwhashAlgorithm.argon2id13.getValue(mockSodium),
      'CrypoPwhashAlgorithm.argon2id13',
    ),
  ]);

  group('methods', () {
    setUp(() {
      when(() => mockSodium.crypto_pwhash_BYTES_MIN).thenReturn(0);
      when(() => mockSodium.crypto_pwhash_BYTES_MAX).thenReturn(10);
      when(() => mockSodium.crypto_pwhash_MEMLIMIT_MIN).thenReturn(0);
      when(() => mockSodium.crypto_pwhash_MEMLIMIT_MAX).thenReturn(10);
      when(() => mockSodium.crypto_pwhash_OPSLIMIT_MIN).thenReturn(0);
      when(() => mockSodium.crypto_pwhash_OPSLIMIT_MAX).thenReturn(10);
      when(() => mockSodium.crypto_pwhash_PASSWD_MIN).thenReturn(0);
      when(() => mockSodium.crypto_pwhash_PASSWD_MAX).thenReturn(10);
      when(() => mockSodium.crypto_pwhash_SALTBYTES).thenReturn(5);
      when(() => mockSodium.crypto_pwhash_STRBYTES).thenReturn(5);
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

        verify(() => mockSodium.crypto_pwhash_BYTES_MIN);
        verify(() => mockSodium.crypto_pwhash_BYTES_MAX);
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

        verify(() => mockSodium.crypto_pwhash_PASSWD_MIN);
        verify(() => mockSodium.crypto_pwhash_PASSWD_MAX);
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

        verify(() => mockSodium.crypto_pwhash_SALTBYTES);
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

        verify(() => mockSodium.crypto_pwhash_OPSLIMIT_MIN);
        verify(() => mockSodium.crypto_pwhash_OPSLIMIT_MAX);
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

        verify(() => mockSodium.crypto_pwhash_MEMLIMIT_MIN);
        verify(() => mockSodium.crypto_pwhash_MEMLIMIT_MAX);
      });

      test('calls crypto_pwhash with correct arguments', () {
        when(() => mockSodium.crypto_pwhash_ALG_ARGON2ID13).thenReturn(42);
        when(
          () => mockSodium.crypto_pwhash(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(Uint8List(0));

        const password = [1, 2, 3];
        final salt = Uint8List.fromList(const [0, 2, 4, 6, 8]);
        sut.call(
          outLen: 5,
          password: Int8List.fromList(password),
          salt: salt,
          opsLimit: 3,
          memLimit: 7,
          alg: CryptoPwhashAlgorithm.argon2id13,
        );

        verify(() => mockSodium.crypto_pwhash_ALG_ARGON2ID13);
        verify(
          () => mockSodium.crypto_pwhash(
            5,
            Uint8List.fromList(password),
            salt,
            3,
            7,
            42,
          ),
        );
      });

      test('returns secure key with result of correct length', () {
        when(() => mockSodium.crypto_pwhash_ALG_DEFAULT).thenReturn(2);
        final testData = Uint8List.fromList(const [5, 4, 3, 2, 1]);
        when(
          () => mockSodium.crypto_pwhash(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenReturn(testData);
        final res = sut.call(
          outLen: testData.length,
          password: Int8List.fromList(const [1, 2, 3]),
          salt: Uint8List.fromList(const [0, 2, 4, 6, 8]),
          opsLimit: 3,
          memLimit: 7,
        );

        expect(res.extractBytes(), testData);
        verify(() => mockSodium.crypto_pwhash_ALG_DEFAULT);
      });

      test('throws SodiumException on JsError', () {
        when(() => mockSodium.crypto_pwhash_ALG_ARGON2I13).thenReturn(3);
        when(
          () => mockSodium.crypto_pwhash(
            any(),
            any(),
            any(),
            any(),
            any(),
            any(),
          ),
        ).thenThrow(JsError());

        expect(
          () => sut.call(
            outLen: 5,
            password: Int8List.fromList(const [1, 2, 3]),
            salt: Uint8List.fromList(const [0, 2, 4, 6, 8]),
            opsLimit: 5,
            memLimit: 5,
            alg: CryptoPwhashAlgorithm.argon2i13,
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('str', () {
      test('asserts if password is invalid', () {
        expect(
          () => sut.str(
            password: 'x' * 20,
            opsLimit: 0,
            memLimit: 0,
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_pwhash_PASSWD_MIN);
        verify(() => mockSodium.crypto_pwhash_PASSWD_MAX);
      });

      test('asserts if opsLimit is invalid', () {
        expect(
          () => sut.str(
            password: '',
            opsLimit: 20,
            memLimit: 0,
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_pwhash_OPSLIMIT_MIN);
        verify(() => mockSodium.crypto_pwhash_OPSLIMIT_MAX);
      });

      test('asserts if memLimit is invalid', () {
        expect(
          () => sut.str(
            password: '',
            opsLimit: 0,
            memLimit: 20,
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_pwhash_MEMLIMIT_MIN);
        verify(() => mockSodium.crypto_pwhash_MEMLIMIT_MAX);
      });

      test('calls crypto_pwhash_str with correct arguments', () {
        when(
          () => mockSodium.crypto_pwhash_str(
            any(),
            any(),
            any(),
          ),
        ).thenReturn('');

        sut.str(
          password: 'ABC',
          opsLimit: 5,
          memLimit: 2,
        );

        verify(
          () => mockSodium.crypto_pwhash_str(
            Uint8List.fromList(const [0x41, 0x42, 0x43]),
            5,
            2,
          ),
        );
      });

      test('returns password hash ', () {
        const testHashStr = 'ABC';
        when(
          () => mockSodium.crypto_pwhash_str(
            any(),
            any(),
            any(),
          ),
        ).thenReturn(testHashStr);

        final result = sut.str(
          password: 'abc123',
          opsLimit: 5,
          memLimit: 2,
        );

        expect(result, 'ABC');
      });

      test('throws SodiumException on JsError', () {
        when(
          () => mockSodium.crypto_pwhash_str(
            any(),
            any(),
            any(),
          ),
        ).thenThrow(JsError());

        expect(
          () => sut.str(
            password: 'abc123',
            opsLimit: 5,
            memLimit: 2,
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('strVerify', () {
      setUp(() {
        when(() => mockSodium.crypto_pwhash_str_verify(any(), any()))
            .thenReturn(true);
      });

      test('asserts if passwordHash is invalid', () {
        expect(
          () => sut.strVerify(
            passwordHash: 'x' * 20,
            password: '',
          ),
          throwsA(isA<ArgumentError>()),
        );

        verify(() => mockSodium.crypto_pwhash_STRBYTES);
      });

      test('asserts if password is invalid', () {
        expect(
          () => sut.strVerify(
            passwordHash: 'x' * 5,
            password: 'x' * 20,
          ),
          throwsA(isA<RangeError>()),
        );

        verify(() => mockSodium.crypto_pwhash_PASSWD_MIN);
        verify(() => mockSodium.crypto_pwhash_PASSWD_MAX);
      });

      test('calls crypto_pwhash_str_verify with correct arguments', () {
        const password = 'ABC';
        const passwordHash = 'xyz12';
        final result = sut.strVerify(
          passwordHash: passwordHash,
          password: password,
        );

        expect(result, isTrue);
        verify(
          () => mockSodium.crypto_pwhash_str_verify(
            passwordHash,
            Uint8List.fromList(const [0x41, 0x42, 0x43]),
          ),
        );
      });

      test('throws SodiumException on JsError', () {
        when(
          () => mockSodium.crypto_pwhash_str_verify(
            any(),
            any(),
          ),
        ).thenThrow(JsError());

        expect(
          () => sut.strVerify(
            password: 'abc123',
            passwordHash: 'xyz89',
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    group('strNeedsRehash', () {
      setUp(() {
        when(
          () => mockSodium.crypto_pwhash_str_needs_rehash(any(), any(), any()),
        ).thenReturn(true);
      });

      test('asserts if passwordHash is invalid', () {
        expect(
          () => sut.strNeedsRehash(
            passwordHash: 'x' * 20,
            opsLimit: 0,
            memLimit: 0,
          ),
          throwsA(isA<ArgumentError>()),
        );

        verify(() => mockSodium.crypto_pwhash_STRBYTES);
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

        verify(() => mockSodium.crypto_pwhash_OPSLIMIT_MIN);
        verify(() => mockSodium.crypto_pwhash_OPSLIMIT_MAX);
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

        verify(() => mockSodium.crypto_pwhash_MEMLIMIT_MIN);
        verify(() => mockSodium.crypto_pwhash_MEMLIMIT_MAX);
      });

      test('calls crypto_pwhash_str_needs_rehash with correct arguments', () {
        const passwordHash = 'xyz12';
        final result = sut.strNeedsRehash(
          passwordHash: passwordHash,
          opsLimit: 9,
          memLimit: 8,
        );

        expect(result, isTrue);
        verify(
          () => mockSodium.crypto_pwhash_str_needs_rehash(
            passwordHash,
            9,
            8,
          ),
        );
      });

      test('throws SodiumException on JsError', () {
        when(
          () => mockSodium.crypto_pwhash_str_needs_rehash(
            any(),
            any(),
            any(),
          ),
        ).thenThrow(JsError());

        expect(
          () => sut.strNeedsRehash(
            passwordHash: 'xyz89',
            opsLimit: 9,
            memLimit: 8,
          ),
          throwsA(isA<SodiumException>()),
        );
      });
    });
  });
}
