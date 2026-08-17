// ignore_for_file: unnecessary_lambdas for mocking

@TestOn('dart-vm')
library;

import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:ffi/ffi.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/key_pair.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/api/transferrable_secure_key.dart';
import 'package:sodium/src/ffi/api/crypto_ffi.dart';
import 'package:sodium/src/ffi/api/helpers/isolates/transferrable_key_pair_ffi.dart';
import 'package:sodium/src/ffi/api/helpers/isolates/transferrable_secure_key_ffi.dart';
import 'package:sodium/src/ffi/api/ip_address_ffi.dart';
import 'package:sodium/src/ffi/api/randombytes_ffi.dart';
import 'package:sodium/src/ffi/api/sodium_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.wrapper.dart';
import 'package:sodium/src/ffi/bindings/sodium_pointer.dart';
import 'package:test/test.dart';

import '../../../secure_key_fake.dart';
import '../../../test_data.dart';
import '../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI;

class FakeTransferrableSecureKey extends Fake implements TransferrableSecureKey;

class FakeTransferrableKeyPair extends Fake implements TransferrableKeyPair;

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
      verify(() => mockSodium.sodium_free(any())).called(1);
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
      verify(() => mockSodium.sodium_free(any())).called(1);
    });

    test('throws if sodium_unpad fails', () {
      when(() => mockSodium.sodium_unpad(any(), any(), any(), any()))
          .thenReturn(1);

      expect(() => sut.unpad(testData, 10), throwsA(isA<SodiumException>()));

      verify(() => mockSodium.sodium_free(any())).called(2);
    });
  });

  group('memcmp', () {
    final b1 = Uint8List.fromList(const [1, 2, 3, 4]);
    final b2 = Uint8List.fromList(const [5, 6, 7, 8]);

    setUp(() {
      mockAllocArray(mockSodium);
      when(() => mockSodium.sodium_memcmp(any(), any(), any())).thenReturn(0);
    });

    test('asserts if b2 has a different length', () {
      expect(() => sut.memcmp(b1, Uint8List(3)), throwsA(isA<RangeError>()));

      verifyNever(() => mockSodium.sodium_allocarray(any(), any()));
      verifyNever(() => mockSodium.sodium_malloc(any()));
    });

    test('calls sodium_memcmp with correct arguments', () {
      sut.memcmp(b1, b2);

      verify(() => mockSodium.sodium_allocarray(b1.length, 1)).called(2);
      verify(
        () => mockSodium.sodium_memcmp(
          any(that: hasRawData<Void>(b1)),
          any(that: hasRawData<Void>(b2)),
          b1.length,
        ),
      );
    });

    test('returns true if sodium_memcmp returns 0', () {
      final res = sut.memcmp(b1, b2);

      expect(res, isTrue);
      verify(() => mockSodium.sodium_free(any())).called(2);
    });

    test('returns false if sodium_memcmp returns -1', () {
      when(() => mockSodium.sodium_memcmp(any(), any(), any())).thenReturn(-1);

      final res = sut.memcmp(b1, b2);

      expect(res, isFalse);
      verify(() => mockSodium.sodium_free(any())).called(2);
    });

    test('works with empty buffers', () {
      final res = sut.memcmp(Uint8List(0), Uint8List(0));

      expect(res, isTrue);
      verify(() => mockSodium.sodium_memcmp(any(), any(), 0));
    });
  });

  group('compare', () {
    final b1 = Uint8List.fromList(const [1, 2, 3, 4]);
    final b2 = Uint8List.fromList(const [5, 6, 7, 8]);

    setUp(() {
      mockAllocArray(mockSodium);
      when(() => mockSodium.sodium_compare(any(), any(), any())).thenReturn(0);
    });

    test('asserts if b2 has a different length', () {
      expect(() => sut.compare(b1, Uint8List(3)), throwsA(isA<RangeError>()));

      verifyNever(() => mockSodium.sodium_allocarray(any(), any()));
      verifyNever(() => mockSodium.sodium_malloc(any()));
    });

    test('calls sodium_compare with correct arguments', () {
      sut.compare(b1, b2);

      verify(() => mockSodium.sodium_allocarray(b1.length, 1)).called(2);
      verify(
        () => mockSodium.sodium_compare(
          any(that: hasRawData<UnsignedChar>(b1)),
          any(that: hasRawData<UnsignedChar>(b2)),
          b1.length,
        ),
      );
    });

    testData<int>(
      'returns the value reported by sodium_compare',
      const [-1, 0, 1],
      (fixture) {
        when(() => mockSodium.sodium_compare(any(), any(), any()))
            .thenReturn(fixture);

        final res = sut.compare(b1, b2);

        expect(res, fixture);
        verify(() => mockSodium.sodium_free(any())).called(2);
      },
    );

    test('works with empty buffers', () {
      final res = sut.compare(Uint8List(0), Uint8List(0));

      expect(res, 0);
      verify(() => mockSodium.sodium_compare(any(), any(), 0));
    });
  });

  group('isZero', () {
    final testData = Uint8List.fromList(const [1, 2, 3, 4]);

    setUp(() {
      mockAllocArray(mockSodium);
      when(() => mockSodium.sodium_is_zero(any(), any())).thenReturn(1);
    });

    test('calls sodium_is_zero with correct arguments', () {
      sut.isZero(testData);

      verify(() => mockSodium.sodium_allocarray(testData.length, 1)).called(1);
      verify(
        () => mockSodium.sodium_is_zero(
          any(that: hasRawData<UnsignedChar>(testData)),
          testData.length,
        ),
      );
    });

    test('returns true if sodium_is_zero returns 1', () {
      final res = sut.isZero(testData);

      expect(res, isTrue);
      verify(() => mockSodium.sodium_free(any())).called(1);
    });

    test('returns false if sodium_is_zero returns 0', () {
      when(() => mockSodium.sodium_is_zero(any(), any())).thenReturn(0);

      final res = sut.isZero(testData);

      expect(res, isFalse);
      verify(() => mockSodium.sodium_free(any())).called(1);
    });

    test('works with an empty buffer', () {
      final res = sut.isZero(Uint8List(0));

      expect(res, isTrue);
      verify(() => mockSodium.sodium_is_zero(any(), 0));
    });
  });

  group('increment', () {
    final testData = Uint8List.fromList(const [1, 2, 3, 4]);

    setUp(() {
      mockAllocArray(mockSodium);
      when(() => mockSodium.sodium_increment(any(), any())).thenAnswer((_) {});
    });

    test('allocs a writable copy of the input and calls sodium_increment', () {
      sut.increment(testData);

      verify(() => mockSodium.sodium_allocarray(testData.length, 1)).called(1);
      verifyNever(() => mockSodium.sodium_mprotect_readonly(any()));
      verify(
        () => mockSodium.sodium_increment(
          any(that: hasRawData<UnsignedChar>(testData)),
          testData.length,
        ),
      );
    });

    test('returns the incremented buffer without mutating the input', () {
      const incremented = [2, 2, 3, 4];
      when(() => mockSodium.sodium_increment(any(), any())).thenAnswer((i) {
        fillPointer(
          i.positionalArguments.first as Pointer<UnsignedChar>,
          incremented,
        );
      });

      final input = Uint8List.fromList(const [1, 2, 3, 4]);
      final res = sut.increment(input);

      expect(res, incremented);
      expect(input, const [1, 2, 3, 4]);
      expect(res, isNot(same(input)));
      verifyNever(() => mockSodium.sodium_free(any()));
    });

    test('works with an empty buffer', () {
      final res = sut.increment(Uint8List(0));

      expect(res, isEmpty);
      verify(() => mockSodium.sodium_increment(any(), 0));
    });
  });

  group('add', () {
    final a = Uint8List.fromList(const [1, 2, 3, 4]);
    final b = Uint8List.fromList(const [5, 6, 7, 8]);

    setUp(() {
      mockAllocArray(mockSodium);
      when(() => mockSodium.sodium_add(any(), any(), any())).thenAnswer((_) {});
    });

    test('asserts if b has a different length', () {
      expect(() => sut.add(a, Uint8List(3)), throwsA(isA<RangeError>()));

      verifyNever(() => mockSodium.sodium_allocarray(any(), any()));
      verifyNever(() => mockSodium.sodium_malloc(any()));
    });

    test('calls sodium_add with correct arguments', () {
      sut.add(a, b);

      verify(() => mockSodium.sodium_allocarray(a.length, 1)).called(2);
      verify(
        () => mockSodium.sodium_add(
          any(that: hasRawData<UnsignedChar>(a)),
          any(that: hasRawData<UnsignedChar>(b)),
          a.length,
        ),
      );
    });

    test('allocs a writable first and a read only second operand', () {
      sut.add(a, b);

      verifyNever(
        () => mockSodium.sodium_mprotect_readonly(any(that: hasRawData(a))),
      );
      verify(
        () => mockSodium.sodium_mprotect_readonly(any(that: hasRawData(b))),
      ).called(1);
    });

    test('returns the sum without mutating the inputs', () {
      const sum = [6, 8, 10, 12];
      when(() => mockSodium.sodium_add(any(), any(), any())).thenAnswer((i) {
        fillPointer(i.positionalArguments.first as Pointer<UnsignedChar>, sum);
      });

      final aInput = Uint8List.fromList(const [1, 2, 3, 4]);
      final bInput = Uint8List.fromList(const [5, 6, 7, 8]);
      final res = sut.add(aInput, bInput);

      expect(res, sum);
      expect(aInput, const [1, 2, 3, 4]);
      expect(bInput, const [5, 6, 7, 8]);
      expect(res, isNot(same(aInput)));
      verify(() => mockSodium.sodium_free(any())).called(1);
    });

    test('works with empty buffers', () {
      final res = sut.add(Uint8List(0), Uint8List(0));

      expect(res, isEmpty);
      verify(() => mockSodium.sodium_add(any(), any(), 0));
    });
  });

  group('sub', () {
    final a = Uint8List.fromList(const [5, 6, 7, 8]);
    final b = Uint8List.fromList(const [1, 2, 3, 4]);

    setUp(() {
      mockAllocArray(mockSodium);
      when(() => mockSodium.sodium_sub(any(), any(), any())).thenAnswer((_) {});
    });

    test('asserts if b has a different length', () {
      expect(() => sut.sub(a, Uint8List(3)), throwsA(isA<RangeError>()));

      verifyNever(() => mockSodium.sodium_allocarray(any(), any()));
      verifyNever(() => mockSodium.sodium_malloc(any()));
    });

    test('calls sodium_sub with correct arguments', () {
      sut.sub(a, b);

      verify(() => mockSodium.sodium_allocarray(a.length, 1)).called(2);
      verify(
        () => mockSodium.sodium_sub(
          any(that: hasRawData<UnsignedChar>(a)),
          any(that: hasRawData<UnsignedChar>(b)),
          a.length,
        ),
      );
    });

    test('allocs a writable first and a read only second operand', () {
      sut.sub(a, b);

      verifyNever(
        () => mockSodium.sodium_mprotect_readonly(any(that: hasRawData(a))),
      );
      verify(
        () => mockSodium.sodium_mprotect_readonly(any(that: hasRawData(b))),
      ).called(1);
    });

    test('returns the difference without mutating the inputs', () {
      const difference = [4, 4, 4, 4];
      when(() => mockSodium.sodium_sub(any(), any(), any())).thenAnswer((i) {
        fillPointer(
          i.positionalArguments.first as Pointer<UnsignedChar>,
          difference,
        );
      });

      final aInput = Uint8List.fromList(const [5, 6, 7, 8]);
      final bInput = Uint8List.fromList(const [1, 2, 3, 4]);
      final res = sut.sub(aInput, bInput);

      expect(res, difference);
      expect(aInput, const [5, 6, 7, 8]);
      expect(bInput, const [1, 2, 3, 4]);
      expect(res, isNot(same(aInput)));
      verify(() => mockSodium.sodium_free(any())).called(1);
    });

    test('works with empty buffers', () {
      final res = sut.sub(Uint8List(0), Uint8List(0));

      expect(res, isEmpty);
      verify(() => mockSodium.sodium_sub(any(), any(), 0));
    });
  });

  group('bin2hex', () {
    final testData = Uint8List.fromList(const [0x01, 0xab, 0xff]);

    setUp(() {
      mockAllocArray(mockSodium);
      mockAlloc(mockSodium, 0);
      when(() => mockSodium.sodium_bin2hex(any(), any(), any(), any()))
          .thenReturn(nullptr);
    });

    test('allocs a zeroed hex buffer of bin.length * 2 + 1 bytes', () {
      sut.bin2hex(testData);

      verify(() => mockSodium.sodium_allocarray(testData.length * 2 + 1, 1));
      verify(
        () => mockSodium.sodium_memzero(
          any(that: isNot(nullptr)),
          testData.length * 2 + 1,
        ),
      );
    });

    test('calls sodium_bin2hex with correct arguments', () {
      sut.bin2hex(testData);

      verify(
        () => mockSodium.sodium_bin2hex(
          any(that: isNot(nullptr)),
          testData.length * 2 + 1,
          any(that: hasRawData<UnsignedChar>(testData)),
          testData.length,
        ),
      );
    });

    test('returns the zero terminated hex string as written by libsodium', () {
      const hex = '01abff';
      when(() => mockSodium.sodium_bin2hex(any(), any(), any(), any()))
          .thenAnswer((i) {
            fillPointer(
              i.positionalArguments.first as Pointer<Char>,
              hex.codeUnits,
            );
            return nullptr;
          });

      final res = sut.bin2hex(testData);

      expect(res, hex);
      verify(() => mockSodium.sodium_free(any())).called(2);
    });

    test('decodes the hex buffer as ascii, not as utf8', () {
      // valid utf8 for 'Ä', but not valid ascii - sodium_bin2hex can never
      // produce this, so decoding it must fail instead of silently succeeding
      const nonAsciiHex = [0xC3, 0x84];
      when(
        () => mockSodium.sodium_bin2hex(any(), any(), any(), any()),
      ).thenAnswer((i) {
        fillPointer(i.positionalArguments.first as Pointer<Char>, nonAsciiHex);
        return nullptr;
      });

      expect(() => sut.bin2hex(testData), throwsFormatException);

      verify(() => mockSodium.sodium_free(any())).called(2);
    });

    test('returns an empty string for an empty input', () {
      final res = sut.bin2hex(Uint8List(0));

      expect(res, isEmpty);
      verify(() => mockSodium.sodium_malloc(1));
      verify(() => mockSodium.sodium_bin2hex(any(), 1, any(), 0));
    });
  });

  group('hex2bin', () {
    const hex = '0a1b2c';
    const binData = [0x0a, 0x1b, 0x2c];

    setUp(() {
      mockAllocArray(mockSodium);
      mockAlloc(mockSodium, binData.length);
      when(
        () => mockSodium.sodium_hex2bin(
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenReturn(0);
    });

    test('throws if hex is not ascii', () {
      expect(() => sut.hex2bin('0ä1b'), throwsA(isA<ArgumentError>()));

      verifyNever(() => mockSodium.sodium_allocarray(any(), any()));
      verifyNever(() => mockSodium.sodium_malloc(any()));
    });

    test('calls sodium_hex2bin with correct arguments', () {
      sut.hex2bin(hex);

      verify(() => mockSodium.sodium_allocarray(hex.length, 1));
      verify(() => mockSodium.sodium_allocarray(hex.length ~/ 2, 1));
      verify(() => mockSodium.sodium_malloc(sizeOf<Uint64>()));
      verify(
        () => mockSodium.sodium_hex2bin(
          any(that: isNot(nullptr)),
          hex.length ~/ 2,
          any(that: hasRawData<Char>(hex.codeUnits)),
          hex.length,
          any(that: hasAddress(0)),
          any(that: isNot(nullptr)),
          any(that: hasAddress(0)),
        ),
      );
    });

    test('returns the bin data truncated to the reported bin_len', () {
      const reportedLength = 2;
      mockAlloc(mockSodium, reportedLength);
      when(
        () => mockSodium.sodium_hex2bin(
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
          binData,
        );
        return 0;
      });

      final res = sut.hex2bin(hex);

      expect(res, binData.sublist(0, reportedLength));
      verify(() => mockSodium.sodium_free(any())).called(2);
    });

    test('throws if sodium_hex2bin fails', () {
      when(
        () => mockSodium.sodium_hex2bin(
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
          any(),
        ),
      ).thenReturn(-1);

      expect(() => sut.hex2bin(hex), throwsA(isA<SodiumException>()));

      verify(() => mockSodium.sodium_free(any())).called(3);
    });

    test('returns an empty list for an empty hex string', () {
      mockAlloc(mockSodium, 0);

      final res = sut.hex2bin('');

      expect(res, isEmpty);
      verify(
        () => mockSodium.sodium_hex2bin(
          any(),
          0,
          any(),
          0,
          any(that: hasAddress(0)),
          any(),
          any(that: hasAddress(0)),
        ),
      );
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

  group('ipFromAddress', () {
    test('returns IpAddressFFI for IPv6 address', () {
      mockAllocArray(mockSodium);

      final result = sut.ipFromAddress(InternetAddress('::1'));

      expect(
        result,
        isA<IpAddressFFI>().having((p) => p.sodium, 'sodium', mockSodium),
      );
    });

    test('returns IpAddressFFI for IPv4 address via parse', () {
      mockAllocArray(mockSodium);
      when(() => mockSodium.sodium_ip2bin(any(), any(), any())).thenReturn(0);

      final result = sut.ipFromAddress(InternetAddress('192.168.0.1'));

      expect(
        result,
        isA<IpAddressFFI>().having((p) => p.sodium, 'sodium', mockSodium),
      );
    });
  });

  group('ipFromString', () {
    test('returns IpAddressFFI by parsing the address string', () {
      mockAllocArray(mockSodium);
      when(() => mockSodium.sodium_ip2bin(any(), any(), any())).thenReturn(0);

      final result = sut.ipFromString('192.168.0.1');

      expect(
        result,
        isA<IpAddressFFI>().having((p) => p.sodium, 'sodium', mockSodium),
      );
    });
  });

  group('ipFromBytes', () {
    test('returns IpAddressFFI with the given bytes', () {
      mockAllocArray(mockSodium);

      final bytes = Uint8List.fromList(List.generate(16, (i) => i));
      final result = sut.ipFromBytes(bytes);

      expect(
        result,
        isA<IpAddressFFI>().having((p) => p.sodium, 'sodium', mockSodium),
      );
      expect(result.bytes, bytes);
    });
  });

  group('runIsolated', () {
    setUp(() {
      SodiumPointer.debugOverwriteFinalizer = MockSodiumFinalizer();
    });

    test('invokes the given callback on a custom isolate', () async {
      final currentIsolateName = Isolate.current.debugName;
      final callbackIsolateName = await sut.runIsolated(
        (secureKeys, keyPairs) => Isolate.current.debugName,
      );

      expect(callbackIsolateName, isNot(currentIsolateName));
    });

    test('passes over keys via the transferable secure key', () async {
      mockAllocArray(mockSodium);

      const testSecureKeyData = [1, 2, 3, 4, 5];
      final testSecureKey = SecureKeyFake(testSecureKeyData);

      final result = await sut.runIsolated(secureKeys: [testSecureKey], (
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

      final result = await sut.runIsolated((_, _) => testData);

      expect(result, testData);
      expect(result, isNot(same(testData)));
    });
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
