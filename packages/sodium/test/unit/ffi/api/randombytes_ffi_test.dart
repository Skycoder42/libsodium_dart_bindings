// ignore_for_file: unnecessary_lambdas for mocking

@TestOn('dart-vm')
library;

import 'dart:ffi';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/ffi/api/randombytes_ffi.dart';
import 'package:sodium/src/ffi/bindings/libsodium.ffi.wrapper.dart';
import 'package:test/test.dart';

import '../../../test_constants_mapping.dart';
import '../pointer_test_helpers.dart';

class MockSodiumFFI extends Mock implements LibSodiumFFI {}

void main() {
  final mockSodium = MockSodiumFFI();

  late RandombytesFFI sut;

  setUpAll(() {
    registerPointers();
  });

  setUp(() {
    reset(mockSodium);

    mockAllocArray(mockSodium);

    sut = RandombytesFFI(mockSodium);
  });

  testConstantsMapping([
    (
      () => mockSodium.randombytes_seedbytes(),
      () => sut.seedBytes,
      'seedBytes',
    ),
  ]);

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
    final testData = List.generate(length, (index) => index);
    when(() => mockSodium.randombytes_buf(any(), any())).thenAnswer(
      (i) =>
          fillPointer(i.positionalArguments.first as Pointer<Void>, testData),
    );

    final res = sut.buf(length);
    expect(res, testData);

    verify(() => mockSodium.randombytes_buf(any(that: isNot(nullptr)), length));
  });

  group('bufDeterministic', () {
    test('calls randombytes_buf_deterministic', () {
      const seedBytes = 10;
      final seed = Uint8List(seedBytes);
      when(() => mockSodium.randombytes_seedbytes()).thenReturn(seedBytes);

      const length = 42;
      final testData = List.generate(length, (index) => index);
      when(
        () => mockSodium.randombytes_buf_deterministic(any(), any(), any()),
      ).thenAnswer(
        (i) =>
            fillPointer(i.positionalArguments.first as Pointer<Void>, testData),
      );

      final res = sut.bufDeterministic(length, seed);
      expect(res, testData);

      verify(
        () => mockSodium.randombytes_buf_deterministic(
          any(that: isNot(nullptr)),
          length,
          any(that: hasRawData<UnsignedChar>(seed)),
        ),
      );
    });

    test('throws for invalid seed length', () {
      const seedBytes = 10;
      when(() => mockSodium.randombytes_seedbytes()).thenReturn(seedBytes);

      final seed = Uint8List(1);

      expect(() => sut.bufDeterministic(1, seed), throwsA(isA<RangeError>()));
    });
  });

  group('close', () {
    test('calls randombytes_close', () {
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
