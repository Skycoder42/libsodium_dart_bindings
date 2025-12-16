// ignore_for_file: unnecessary_lambdas for mocking

@TestOn('dart-vm')
library;

import 'dart:ffi';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:ffi/ffi.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/key_pair.dart';
import 'package:sodium/src/api/secure_key.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/api/transferrable_secure_key.dart';
import 'package:sodium/src/ffi/api/crypto_ffi.dart';
import 'package:sodium/src/ffi/api/helpers/isolates/transferrable_key_pair_ffi.dart';
import 'package:sodium/src/ffi/api/helpers/isolates/transferrable_secure_key_ffi.dart';
import 'package:sodium/src/ffi/api/randombytes_ffi.dart';
import 'package:sodium/src/ffi/api/sodium_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

class FakeTransferrableSecureKey extends Fake
    implements TransferrableSecureKey {}

class FakeTransferrableKeyPair extends Fake implements TransferrableKeyPair {}

void main() {
  final mockSodium = MockSodiumFFI();

  late SodiumFFI sut;

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);

    sut = SodiumFFI(mockSodium, () {
      registerPointers();
      final sodium = MockSodiumFFI();
      mockAllocArray(sodium, delayedFree: false);
      return sodium;
    });
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
      when(
        () => mockSodium.sodium_pad(any(), any(), any(), any(), any()),
      ).thenReturn(0);
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
      verify(() => mockSodium.sodium_free(any())).called(1);
    });

    test('throws if sodium_pad fails', () {
      when(
        () => mockSodium.sodium_pad(any(), any(), any(), any(), any()),
      ).thenReturn(1);

      expect(() => sut.pad(testData, 10), throwsA(isA<SodiumException>()));

      verify(() => mockSodium.sodium_free(any())).called(2);
    });
  });

  group('unpad', () {
    final testData = Uint8List.fromList(const [1, 2, 3, 4]);

    setUp(() {
      mockAllocArray(mockSodium);
      mockAlloc(mockSodium, 4);
      when(
        () => mockSodium.sodium_unpad(any(), any(), any(), any()),
      ).thenReturn(0);
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
      verify(() => mockSodium.sodium_free(any())).called(1);
    });

    test('throws if sodium_unpad fails', () {
      when(
        () => mockSodium.sodium_unpad(any(), any(), any(), any()),
      ).thenReturn(1);

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
      isA<RandombytesFFI>().having((p) => p.sodium, 'sodium', mockSodium),
    );
  });

  test('crypto returns CryptoFFI instance', () {
    expect(
      sut.crypto,
      isA<CryptoFFI>().having((p) => p.sodium, 'sodium', mockSodium),
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

      final result = await sut.runIsolated(secureKeys: [testSecureKey], (
        sodium,
        secureKeys,
        keyPairs,
      ) {
        assert(keyPairs.isEmpty, '$keyPairs.isEmpty');
        assert(secureKeys.length == 1, '$secureKeys.length == 1');
        final secureKey = secureKeys.single;
        assert(
          const ListEquality<int>().equals(
            secureKey.extractBytes(),
            testSecureKeyData,
          ),
          '${secureKey.extractBytes()} == $testSecureKeyData',
        );
        return secureKey;
      });

      expect(result, testSecureKey);
      expect(testSecureKey.disposed, isFalse);
    });

    test('passes over key pairs via the transferable key key', () async {
      mockAllocArray(mockSodium);

      const testPublicKeyData = [1, 2, 3, 4, 5];
      const testSecretKeyData = [2, 4, 6, 8, 10];
      final testKeyPair = KeyPair(
        publicKey: Uint8List.fromList(testPublicKeyData),
        secretKey: SecureKeyFake(testSecretKeyData),
      );

      final result = await sut.runIsolated(keyPairs: [testKeyPair], (
        sodium,
        secureKeys,
        keyPairs,
      ) {
        assert(secureKeys.isEmpty, '$secureKeys.isEmpty');
        assert(keyPairs.length == 1, '$keyPairs == 1');
        final keyPair = keyPairs.single;
        assert(
          const ListEquality<int>().equals(
            keyPair.publicKey,
            testPublicKeyData,
          ),
          '${keyPair.publicKey} == $testPublicKeyData',
        );
        assert(
          const ListEquality<int>().equals(
            keyPair.secretKey.extractBytes(),
            testSecretKeyData,
          ),
          '${keyPair.secretKey.extractBytes()} == $testSecretKeyData',
        );
        return keyPair;
      });

      expect(result, testKeyPair);
    });

    test('passes over byte arrays via the transferable typed data', () async {
      mockAllocArray(mockSodium);

      final testData = Uint8List.fromList([1, 2, 3, 4, 5]);

      final result = await sut.runIsolated((sodium, _, _) => testData);

      expect(result, testData);
      expect(result, isNot(same(testData)));
    });
  });

  test('isolateFactory returns a factory that '
      'can create a sodium instance with a different ffi reference', () async {
    when(() => mockSodium.sodium_library_version_major()).thenReturn(1);
    when(() => mockSodium.sodium_library_version_minor()).thenReturn(2);
    when(() => mockSodium.sodium_version_string()).thenReturn(nullptr);

    final factory = sut.isolateFactory;

    final newSodium = await factory();

    expect(
      newSodium,
      isA<SodiumFFI>().having(
        (m) => m.sodium,
        'sodium',
        isNot(same(mockSodium)),
      ),
    );
    expect(
      newSodium.secureAlloc(10),
      isA<SecureKey>().having((m) => m.length, 'length', 10),
    );
  });

  test('createTransferrableSecureKey creates a transferrable key', () {
    mockAllocArray(mockSodium);

    final testBytes = [1, 3, 5, 7];
    final result = sut.createTransferrableSecureKey(SecureKeyFake(testBytes));

    expect(result, isA<TransferrableSecureKeyFFI>());
    final transferrableKey = result as TransferrableSecureKeyFFI;

    final restored = transferrableKey.toSecureKey(sut);
    expect(restored.extractBytes(), testBytes);
  });

  group('materializeTransferrableSecureKey', () {
    test('restores the original key', () {
      mockAllocArray(mockSodium);

      final transferBytes = Uint8List.fromList([2, 4, 6, 8]);

      final result = sut.materializeTransferrableSecureKey(
        TransferrableSecureKeyFFI.generic(
          TransferableTypedData.fromList([transferBytes]),
        ),
      );

      expect(result.extractBytes(), transferBytes);
    });

    test('throws if not an FFI key', () {
      expect(
        () =>
            sut.materializeTransferrableSecureKey(FakeTransferrableSecureKey()),
        throwsA(
          isA<SodiumException>().having(
            (m) => m.originalMessage,
            'originalMessage',
            contains('$FakeTransferrableSecureKey'),
          ),
        ),
      );
    });
  });

  test('createTransferrableKeyPair creates a transferrable key pair', () {
    mockAllocArray(mockSodium);

    final testPublicBytes = [1, 3, 5, 7];
    final testSecretBytes = [1, 2, 3, 4];
    final result = sut.createTransferrableKeyPair(
      KeyPair(
        publicKey: Uint8List.fromList(testPublicBytes),
        secretKey: SecureKeyFake(testSecretBytes),
      ),
    );

    expect(result, isA<TransferrableKeyPairFFI>());
    final transferrableKeyPair = result as TransferrableKeyPairFFI;

    final restored = transferrableKeyPair.toKeyPair(sut);
    expect(restored.publicKey, testPublicBytes);
    expect(restored.secretKey.extractBytes(), testSecretBytes);
  });

  group('materializeTransferrableKeyPair', () {
    test('restores the original key pair', () {
      mockAllocArray(mockSodium);

      final transferPublicBytes = Uint8List.fromList([2, 4, 6, 8]);
      final transferSecureBytes = Uint8List.fromList([5, 6, 7, 8]);

      final result = sut.materializeTransferrableKeyPair(
        TransferrableKeyPairFFI.generic(
          publicKeyBytes: TransferableTypedData.fromList([transferPublicBytes]),
          secretKeyBytes: TransferableTypedData.fromList([transferSecureBytes]),
        ),
      );

      expect(result.publicKey, transferPublicBytes);
      expect(result.secretKey.extractBytes(), transferSecureBytes);
    });

    test('throws if not an FFI key', () {
      expect(
        () => sut.materializeTransferrableKeyPair(FakeTransferrableKeyPair()),
        throwsA(
          isA<SodiumException>().having(
            (m) => m.originalMessage,
            'originalMessage',
            contains('$FakeTransferrableKeyPair'),
          ),
        ),
      );
    });
  });
}
