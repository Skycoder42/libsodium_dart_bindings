@TestOn('js')
library secure_key_js_test;

import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/secure_key_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:test/test.dart';

class MockLibSodiumJS extends Mock implements LibSodiumJS {}

void main() {
  final mockSodium = MockLibSodiumJS();

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);
  });

  group('construction', () {
    test('raw initializes members', () {
      final sut = SecureKeyJS(mockSodium, Uint8List(3));

      expect(sut.sodium, mockSodium);
    });

    test('alloc allocates new memory', () {
      const length = 42;
      final sut = SecureKeyJS.alloc(mockSodium, length);

      expect(sut.extractBytes().length, length);
    });

    group('random', () {
      test('fills buffer with random data', () {
        const length = 10;

        when(() => mockSodium.randombytes_buf(any()))
            .thenReturn(Uint8List(length));

        SecureKeyJS.random(mockSodium, length);

        verify(() => mockSodium.randombytes_buf(length));
      });

      test('throws SodiumException on JsError', () {
        when(() => mockSodium.randombytes_buf(any())).thenThrow(JsError());

        expect(
          () => SecureKeyJS.random(mockSodium, 10),
          throwsA(isA<SodiumException>()),
        );
      });
    });
  });

  group('members', () {
    const testList = [0, 1, 2, 3, 4];

    late SecureKeyJS sut;

    setUp(() {
      sut = SecureKeyJS(mockSodium, Uint8List.fromList(testList));
    });

    test('length returns pointer length', () {
      expect(sut.length, testList.length);
    });

    test('runUnlockedSync calls callback with data', () {
      final res = sut.runUnlockedSync((data) {
        expect(data, testList);
        return 42;
      });
      expect(res, 42);
    });

    test('runUnlockedAsync calls callback with data', () async {
      final res = await sut.runUnlockedAsync((data) {
        expect(data, testList);
        return 42;
      });
      expect(res, 42);
    });

    test('extractBytes returns copy of bytes', () {
      final bytes = sut.extractBytes();

      expect(bytes, testList);

      sut.runUnlockedSync((data) => data[0] = data[0 + 1]);

      expect(bytes, testList);
    });

    test('copy returns independent copy of bytes', () {
      final keyCopy = sut.copy();

      expect(keyCopy.extractBytes(), testList);

      sut.runUnlockedSync((data) => data[0] = data[0 + 1]);

      expect(keyCopy.extractBytes(), testList);
      expect(sut.extractBytes(), isNot(testList));
    });

    group('dispose', () {
      test('clears the memory', () {
        sut.dispose();

        verify(() => mockSodium.memzero(Uint8List.fromList(testList)));
      });

      test('throws SodiumException on JsError', () {
        when(() => mockSodium.memzero(any())).thenThrow(JsError());

        expect(
          () => sut.dispose(),
          throwsA(isA<SodiumException>()),
        );
      });
    });

    test('nativeHandle returns internally used byte array', () {
      final handle = sut.nativeHandle;

      expect(handle, testList);
    });
  });
}
