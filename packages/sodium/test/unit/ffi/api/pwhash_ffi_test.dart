import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/pwhash.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/pwhash_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../../test_data.dart';
import '../pointer_test_helpers.dart';

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

  testData<Tuple3<int Function(), int Function(), String>>(
    'maps integer constants correctly',
    [
      Tuple3(
        () => mockSodium.crypto_pwhash_bytes_min(),
        () => sut.bytesMin,
        'bytesMin',
      ),
      Tuple3(
        () => mockSodium.crypto_pwhash_bytes_max(),
        () => sut.bytesMax,
        'bytesMax',
      ),
      Tuple3(
        () => mockSodium.crypto_pwhash_memlimit_min(),
        () => sut.memLimitMin,
        'memLimitMin',
      ),
      Tuple3(
        () => mockSodium.crypto_pwhash_memlimit_interactive(),
        () => sut.memLimitInteractive,
        'memLimitInteractive',
      ),
      Tuple3(
        () => mockSodium.crypto_pwhash_memlimit_moderate(),
        () => sut.memLimitModerate,
        'memLimitModerate',
      ),
      Tuple3(
        () => mockSodium.crypto_pwhash_memlimit_sensitive(),
        () => sut.memLimitSensitive,
        'memLimitSensitive',
      ),
      Tuple3(
        () => mockSodium.crypto_pwhash_memlimit_max(),
        () => sut.memLimitMax,
        'memLimitMax',
      ),
      Tuple3(
        () => mockSodium.crypto_pwhash_opslimit_min(),
        () => sut.opsLimitMin,
        'opsLimitMin',
      ),
      Tuple3(
        () => mockSodium.crypto_pwhash_opslimit_interactive(),
        () => sut.opsLimitInteractive,
        'opsLimitInteractive',
      ),
      Tuple3(
        () => mockSodium.crypto_pwhash_opslimit_moderate(),
        () => sut.opsLimitModerate,
        'opsLimitModerate',
      ),
      Tuple3(
        () => mockSodium.crypto_pwhash_opslimit_sensitive(),
        () => sut.opsLimitSensitive,
        'opsLimitSensitive',
      ),
      Tuple3(
        () => mockSodium.crypto_pwhash_opslimit_max(),
        () => sut.opsLimitMax,
        'opsLimitMax',
      ),
      Tuple3(
        () => mockSodium.crypto_pwhash_passwd_min(),
        () => sut.passwdMin,
        'passwdMin',
      ),
      Tuple3(
        () => mockSodium.crypto_pwhash_passwd_max(),
        () => sut.passwdMax,
        'passwdMax',
      ),
      Tuple3(
        () => mockSodium.crypto_pwhash_saltbytes(),
        () => sut.saltBytes,
        'saltBytes',
      ),
      Tuple3(
        () => mockSodium.crypto_pwhash_strbytes(),
        () => sut.strBytes,
        'strBytes',
      ),
    ],
    (fixture) {
      const value = 10;
      when(fixture.item1).thenReturn(value);

      final res = fixture.item2();

      expect(res, value);
      verify(fixture.item1);
    },
    fixtureToString: (fixture) => fixture.item3,
  );
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
        when(() => mockSodium.crypto_pwhash(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            )).thenReturn(0);

        const password = [1, 2, 3];
        const salt = [0, 2, 4, 6, 8];
        sut.call(
          outLen: 5,
          password: Int8List.fromList(password),
          salt: Uint8List.fromList(salt),
          opsLimit: 3,
          memLimit: 7,
          alg: CrypoPwhashAlgorithm.argon2id13,
        );

        verify(() => mockSodium.crypto_pwhash_alg_argon2id13());
        verify(
          () => mockSodium.crypto_pwhash(
            any(),
            5,
            any(that: hasRawData(password)),
            password.length,
            any(that: hasRawData(salt)),
            3,
            7,
            42,
          ),
        );
        verify(() => mockSodium.sodium_free(any())).called(2);
      });

      test('throws if crypto_pwhash returns non zero result', () {
        when(() => mockSodium.crypto_pwhash_alg_argon2i13()).thenReturn(0);
        when(() => mockSodium.crypto_pwhash(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            )).thenReturn(1);

        expect(
          () => sut.call(
            outLen: 5,
            password: Int8List.fromList(const [1, 2, 3]),
            salt: Uint8List.fromList(const [0, 2, 4, 6, 8]),
            opsLimit: 3,
            memLimit: 7,
            alg: CrypoPwhashAlgorithm.argon2i13,
          ),
          throwsA(isA<SodiumException>()),
        );

        verify(() => mockSodium.crypto_pwhash_alg_argon2i13());
        verify(() => mockSodium.sodium_free(any())).called(3);
      });

      test('returns secure key with result of correct length', () {
        when(() => mockSodium.crypto_pwhash_alg_default()).thenReturn(2);
        when(() => mockSodium.crypto_pwhash(
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
              any(),
            )).thenReturn(0);

        const outLen = 5;
        final res = sut.call(
          outLen: outLen,
          password: Int8List.fromList(const [1, 2, 3]),
          salt: Uint8List.fromList(const [0, 2, 4, 6, 8]),
          opsLimit: 3,
          memLimit: 7,
        );
        verify(() => mockSodium.crypto_pwhash_alg_default());
        res.runUnlockedSync((data) {
          expect(data.length, outLen);

          final outData = List.generate(outLen, (index) => index);
          data.setAll(0, outData);

          verify(() => mockSodium.crypto_pwhash(
                any(that: hasRawData(outData)),
                outLen,
                any(),
                any(),
                any(),
                any(),
                any(),
                2,
              ));
        });
      });
    });
  });
}
