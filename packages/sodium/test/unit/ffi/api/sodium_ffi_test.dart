import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/ffi/api/crypto_ffi.dart';
import 'package:sodium/src/ffi/api/randombytes_ffi.dart';
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
