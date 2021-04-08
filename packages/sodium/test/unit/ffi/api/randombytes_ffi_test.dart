import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/randombytes_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.dart';
import 'package:test/test.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final nullptr = Pointer<Void>.fromAddress(0);

  final mockSodium = MockSodiumFFI();

  late RandombytesFFI sut;

  setUpAll(() {
    registerFallbackValue<Pointer<Void>>(nullptr);
    registerFallbackValue<Pointer<Uint8>>(nullptr.cast());
  });

  setUp(() {
    reset(mockSodium);

    when(() => mockSodium.sodium_allocarray(any(), any())).thenAnswer(
      (i) => calloc<Uint8>(
        (i.positionalArguments[0] as int) * (i.positionalArguments[1] as int),
      ).cast(),
    );
    when(() => mockSodium.sodium_mprotect_readonly(any())).thenReturn(0);

    sut = RandombytesFFI(mockSodium);
  });

  test('seedBytes returns randombytes_seedbytes', () {
    const bytes = 42;
    when(() => mockSodium.randombytes_seedbytes()).thenReturn(bytes);

    final res = sut.seedBytes;
    expect(res, bytes);

    verify(() => mockSodium.randombytes_seedbytes());
  });

  test('random calls randombytes_random', () {
    const value = 42;
    when(() => mockSodium.randombytes_random()).thenReturn(value);

    final res = sut.random();
    expect(res, value);

    verify(() => mockSodium.randombytes_random());
  });

  test('uniform calls randombytes_uniform', () {
    const value = 42;
    when(() => mockSodium.randombytes_uniform(any())).thenReturn(value);

    const upperBound = 100;
    final res = sut.uniform(upperBound);
    expect(res, value);

    verify(() => mockSodium.randombytes_uniform(upperBound));
  });

  test('buf calls randombytes_buf', () {
    const length = 42;

    final res = sut.buf(length);
    expect(res.length, length);

    verify(() => mockSodium.randombytes_buf(any(that: isNot(nullptr)), length));
  });

  group('bufDeterministic', () {
    test('calls randombytes_buf_deterministic', () {
      const seedBytes = 10;
      when(() => mockSodium.randombytes_seedbytes()).thenReturn(seedBytes);

      const length = 42;
      final seed = Uint8List(seedBytes);

      final res = sut.bufDeterministic(length, seed);
      expect(res.length, length);

      verify(
        () => mockSodium.randombytes_buf_deterministic(
          any(that: isNot(nullptr)),
          length,
          any(that: isNot(nullptr)),
        ),
      );
    });

    test('throws for invalid seed length', () {
      const seedBytes = 10;
      when(() => mockSodium.randombytes_seedbytes()).thenReturn(seedBytes);

      final seed = Uint8List(1);

      expect(
        () => sut.bufDeterministic(1, seed),
        throwsA(isA<RangeError>()),
      );
    });
  });

  group('close', () {
    test(' calls randombytes_close', () {
      when(() => mockSodium.randombytes_close()).thenReturn(0);

      sut.close();

      verify(() => mockSodium.randombytes_close());
    });

    test('throws if randombytes_close fails', () {
      when(() => mockSodium.randombytes_close()).thenReturn(1);

      expect(() => sut.close(), throwsA(isA<SodiumException>()));

      verify(() => mockSodium.randombytes_close());
    });
  });

  test('stir calls randombytes_stir', () {
    sut.stir();

    verify(() => mockSodium.randombytes_stir());
  });
}
