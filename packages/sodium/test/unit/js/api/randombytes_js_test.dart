// ignore_for_file: unnecessary_lambdas

@TestOn('js')
library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/randombytes_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:test/test.dart';

import '../sodium_js_mock.dart';

void main() {
  final mockSodium = MockLibSodiumJS();

  late RandombytesJS sut;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);

    sut = RandombytesJS(mockSodium.asLibSodiumJS);
  });

  test('seedBytes returns 32', () {
    const bytes = 32;

    final res = sut.seedBytes;
    expect(res, bytes);
  });

  group('random', () {
    test('calls randombytes_random', () {
      const value = 42;
      when(() => mockSodium.randombytes_random()).thenReturn(value);

      final res = sut.random();
      expect(res, value);

      verify(() => mockSodium.randombytes_random());
    });

    test('throws SodiumException on JSError', () {
      when(() => mockSodium.randombytes_random()).thenThrow(JSError());

      expect(() => sut.random(), throwsA(isA<SodiumException>()));
    });
  });

  group('uniform', () {
    test('calls randombytes_uniform', () {
      const value = 42;
      when(() => mockSodium.randombytes_uniform(any())).thenReturn(value);

      const upperBound = 100;
      final res = sut.uniform(upperBound);
      expect(res, value);

      verify(() => mockSodium.randombytes_uniform(upperBound));
    });

    test('throws SodiumException on JSError', () {
      when(() => mockSodium.randombytes_uniform(any())).thenThrow(JSError());

      expect(() => sut.uniform(10), throwsA(isA<SodiumException>()));
    });
  });

  group('buf', () {
    test('calls randombytes_buf', () {
      const length = 42;
      final testData = List.generate(length, (index) => index);
      when(() => mockSodium.randombytes_buf(any()))
          .thenReturn(Uint8List.fromList(testData).toJS);

      final res = sut.buf(length);
      expect(res, testData);

      verify(() => mockSodium.randombytes_buf(length));
    });

    test('throws SodiumException on JSError', () {
      when(() => mockSodium.randombytes_buf(any())).thenThrow(JSError());

      expect(() => sut.buf(10), throwsA(isA<SodiumException>()));
    });
  });

  group('bufDeterministic', () {
    test('calls randombytes_buf_deterministic', () {
      const seedBytes = 32;
      final seed = Uint8List(seedBytes);

      const length = 42;
      final testData = List.generate(length, (index) => index);
      when(() => mockSodium.randombytes_buf_deterministic(any(), any()))
          .thenReturn(Uint8List.fromList(testData).toJS);

      final res = sut.bufDeterministic(length, seed);
      expect(res, testData);

      verify(() => mockSodium.randombytes_buf_deterministic(length, seed.toJS));
    });

    test('throws for invalid seed length', () {
      final seed = Uint8List(1);

      expect(
        () => sut.bufDeterministic(1, seed),
        throwsA(isA<RangeError>()),
      );
    });

    test('throws SodiumException on JSError', () {
      when(() => mockSodium.randombytes_buf_deterministic(any(), any()))
          .thenThrow(JSError());

      expect(
        () => sut.bufDeterministic(10, Uint8List(32)),
        throwsA(isA<SodiumException>()),
      );
    });
  });

  group('close', () {
    test('calls randombytes_close', () {
      sut.close();

      verify(() => mockSodium.randombytes_close());
    });

    test('throws SodiumException on JSError', () {
      when(() => mockSodium.randombytes_close()).thenThrow(JSError());

      expect(() => sut.close(), throwsA(isA<SodiumException>()));
    });
  });

  group('stir', () {
    test('stir calls randombytes_stir', () {
      sut.stir();

      verify(() => mockSodium.randombytes_stir());
    });

    test('throws SodiumException on JSError', () {
      when(() => mockSodium.randombytes_stir()).thenThrow(JSError());

      expect(() => sut.stir(), throwsA(isA<SodiumException>()));
    });
  });
}
