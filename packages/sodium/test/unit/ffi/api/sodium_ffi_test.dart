@TestOn('dart-vm')

import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/crypto_ffi.dart';
import 'package:sodium/src/ffi/api/randombytes_ffi.dart';
import 'package:sodium/src/ffi/api/secure_key_ffi.dart';
import 'package:sodium/src/ffi/api/sodium_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';

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

    sut = SodiumFFI(mockSodium);
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

  group('secureHandle', () {
    test('creates SecureKeyFFI instance with copied data', () {
      mockAllocArray(mockSodium);

      const data = [11, 22];
      final res = sut.secureHandle(data) as SecureKeyFFI;

      // ignore: cascade_invocations
      res.runUnlockedNative<void>((pointer) {
        expect(pointer.sodium, mockSodium);
        expect(pointer.ptr.address, data[0]);
        expect(pointer.count, data[1]);
      });
    });

    test('throws if handle is not exactly 2 elements', () {
      expect(
        () => sut.secureHandle([1, 2, 3]),
        throwsArgumentError,
      );
    });
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
}
