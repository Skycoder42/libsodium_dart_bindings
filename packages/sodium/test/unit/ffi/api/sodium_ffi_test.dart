// ignore_for_file: unnecessary_lambdas, prefer_asserts_with_message

@TestOn('dart-vm')
library;

import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:ffi/ffi.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/key_pair.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/crypto_ffi.dart';
import 'package:sodium/src/ffi/api/randombytes_ffi.dart';
import 'package:sodium/src/ffi/api/sodium_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  late SodiumFFI sut;

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);

    sut = SodiumFFI(
      mockSodium,
      () {
        registerPointers();
        final sodium = MockSodiumFFI();
        mockAllocArray(sodium);
        return sodium;
      },
    );
  });

  test('fromFactory returns instance created by the factory', () async {
    final sut = await SodiumFFI.fromFactory(() => MockSodiumFFI());
    expect(sut.sodium, isNot(same(mockSodium)));
  });

  test('version returns correct library version', () {
    final vStr = 'version'.toNativeUtf8();
    try {
      when(() => mockSodium.sodium_library_version_major()).thenReturn(1);
      when(() => mockSodium.sodium_library_version_minor()).thenReturn(2);
      when(() => mockSodium.sodium_version_string()).thenReturn(vStr.cast());

      final version = sut.version;

      expect(version.major, 1);
      expect(version.minor, 2);
      expect(version.toString(), 'version');

      verify(() => mockSodium.sodium_library_version_major());
      verify(() => mockSodium.sodium_library_version_minor());
      verify(() => mockSodium.sodium_version_string());
    } finally {
      malloc.free(vStr);
    }
  });

  group('pad', () {
    final testData = Uint8List.fromList(const [1, 2, 3, 4]);

    setUp(() {
      mockAllocArray(mockSodium);
      mockAlloc(mockSodium, 4);
      when(() => mockSodium.sodium_pad(any(), any(), any(), any(), any()))
          .thenReturn(0);
    });

    test('allocs extended buffer with extra len', () {
      const blocksize = 42;
      sut.pad(testData, blocksize);

      verify(() => mockSodium.sodium_allocarray(46, 1));
    });

    test('allocs result size buffer and zeros memory', () {
      sut.pad(testData, 42);

      verify(() => mockSodium.sodium_malloc(sizeOf<Uint64>()));
      verify(
        () => mockSodium.sodium_memzero(
          any(that: isNot(nullptr)),
          sizeOf<Uint64>(),
        ),
      );
    });

    test('calls sodium_pad on data', () {
      const blocksize = 42;
      sut.pad(testData, blocksize);

      verify(
        () => mockSodium.sodium_pad(
          any(that: isNot(nullptr)),
          any(that: hasRawData<UnsignedChar>(testData)),
          testData.length,
          blocksize,
          46,
        ),
      );
    });

    test('returns extended buffer with padded length', () {
      const resultSize = 6;
      mockAlloc(mockSodium, resultSize);

      final res = sut.pad(testData, 3);

      expect(res, hasLength(resultSize));
      expect(Uint8List.view(res.buffer, 0, testData.length), testData);
      verify(() => mockSodium.sodium_free(any())).called(2);
    });

    test('throws if sodium_pad fails', () {
      when(() => mockSodium.sodium_pad(any(), any(), any(), any(), any()))
          .thenReturn(1);

      expect(() => sut.pad(testData, 10), throwsA(isA<SodiumException>()));

      verify(() => mockSodium.sodium_free(any())).called(2);
    });
  });

  group('unpad', () {
    final testData = Uint8List.fromList(const [1, 2, 3, 4]);

    setUp(() {
      mockAllocArray(mockSodium);
      mockAlloc(mockSodium, 4);
      when(() => mockSodium.sodium_unpad(any(), any(), any(), any()))
          .thenReturn(0);
    });

    test('allocs extended buffer with data len and read only', () {
      const blocksize = 42;
      sut.unpad(testData, blocksize);

      verify(() => mockSodium.sodium_allocarray(testData.length, 1));
      verify(
        () => mockSodium.sodium_mprotect_readonly(
          any(that: hasRawData(testData)),
        ),
      );
    });

    test('allocs result size buffer and zeros memory', () {
      sut.unpad(testData, 42);

      verify(() => mockSodium.sodium_malloc(sizeOf<Uint64>()));
      verify(
        () => mockSodium.sodium_memzero(
          any(that: isNot(nullptr)),
          sizeOf<Uint64>(),
        ),
      );
    });

    test('calls sodium_unpad on data', () {
      const blocksize = 42;
      sut.unpad(testData, blocksize);

      verify(
        () => mockSodium.sodium_unpad(
          any(that: isNot(nullptr)),
          any(that: hasRawData<UnsignedChar>(testData)),
          testData.length,
          blocksize,
        ),
      );
    });

    test('returns shortened buffer with unpadded length', () {
      const resultSize = 2;
      mockAlloc(mockSodium, resultSize);

      final res = sut.unpad(testData, 3);

      expect(res, testData.sublist(0, resultSize));
      verify(() => mockSodium.sodium_free(any())).called(2);
    });

    test('throws if sodium_unpad fails', () {
      when(() => mockSodium.sodium_unpad(any(), any(), any(), any()))
          .thenReturn(1);

      expect(() => sut.unpad(testData, 10), throwsA(isA<SodiumException>()));

      verify(() => mockSodium.sodium_free(any())).called(2);
    });
  });

  test('secureAlloc creates SecureKey instance', () {
    mockAllocArray(mockSodium);

    const length = 10;
    final res = sut.secureAlloc(length);

    expect(res.length, length);
  });

  test('secureRandom creates random SecureKey instance', () {
    mockAllocArray(mockSodium);

    const length = 10;
    final res = sut.secureRandom(length);

    expect(res.length, length);

    verify(() => mockSodium.randombytes_buf(any(that: isNot(nullptr)), length));
  });

  test('secureCopy creates SecureKey instance with copied data', () {
    mockAllocArray(mockSodium);

    final data = Uint8List.fromList(List.generate(15, (index) => index));
    final res = sut.secureCopy(data);

    expect(res.extractBytes(), data);
  });

  test('randombytes returns RandombytesFFI instance', () {
    expect(
      sut.randombytes,
      isA<RandombytesFFI>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });

  test('crypto returns CryptoFFI instance', () {
    expect(
      sut.crypto,
      isA<CryptoFFI>().having(
        (p) => p.sodium,
        'sodium',
        mockSodium,
      ),
    );
  });

  group('runIsolated', () {
    test('invokes the given callback on a custom isolate', () async {
      final currentIsolateName = Isolate.current.debugName;
      final callbackIsolateName = await sut.runIsolated(
        (sodium, secureKeys, keyPairs) => Isolate.current.debugName,
      );

      expect(callbackIsolateName, isNot(currentIsolateName));
    });

    test('invokes the given callback with a sodium instance', () async {
      final isSodium = await sut.runIsolated(
        (sodium, secureKeys, keyPairs) => sodium is SodiumFFI,
      );

      expect(isSodium, isTrue);
    });

    test('passes over keys via the transferable secure key', () async {
      mockAllocArray(mockSodium);

      const testSecureKeyData = [1, 2, 3, 4, 5];
      final testSecureKey = SecureKeyFake(testSecureKeyData);

      final result = await sut.runIsolated(
        secureKeys: [testSecureKey],
        (sodium, secureKeys, keyPairs) {
          assert(keyPairs.isEmpty, '$keyPairs.isEmpty');
          assert(secureKeys.length == 1, '$secureKeys.length == 1');
          final secureKey = secureKeys.single;
          assert(
            const ListEquality<int>()
                .equals(secureKey.extractBytes(), testSecureKeyData),
            '${secureKey.extractBytes()} == $testSecureKeyData',
          );
          return secureKey;
        },
      );

      expect(result, testSecureKey);
    });

    test('passes over key pairs via the transferable key key', () async {
      mockAllocArray(mockSodium);

      const testPublicKeyData = [1, 2, 3, 4, 5];
      const testSecretKeyData = [2, 4, 6, 8, 10];
      final testKeyPair = KeyPair(
        publicKey: Uint8List.fromList(testPublicKeyData),
        secretKey: SecureKeyFake(testSecretKeyData),
      );

      final result = await sut.runIsolated(
        keyPairs: [testKeyPair],
        (sodium, secureKeys, keyPairs) {
          assert(secureKeys.isEmpty, '$secureKeys.isEmpty');
          assert(keyPairs.length == 1, '$keyPairs == 1');
          final keyPair = keyPairs.single;
          assert(
            const ListEquality<int>()
                .equals(keyPair.publicKey, testPublicKeyData),
            '${keyPair.publicKey} == $testPublicKeyData',
          );
          assert(
            const ListEquality<int>()
                .equals(keyPair.secretKey.extractBytes(), testSecretKeyData),
            '${keyPair.secretKey.extractBytes()} == $testSecretKeyData',
          );
          return keyPair;
        },
      );

      expect(result, testKeyPair);
    });
  });
}
