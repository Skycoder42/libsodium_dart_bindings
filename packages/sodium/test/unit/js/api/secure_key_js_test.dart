import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/js/api/secure_key_js.dart';
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

    group('random fills buffer with random data', () {
      const length = 10;

      when(() => mockSodium.randombytes_buf(any()))
          .thenReturn(Uint8List(length));

      SecureKeyJS.random(mockSodium, length);

      verify(() => mockSodium.randombytes_buf(length));
    });
  });

  group('members', () {
    final testList = Uint8List.fromList(const [0, 1, 2, 3, 4]);

    late SecureKeyJS sut;

    setUp(() {
      sut = SecureKeyJS(mockSodium, testList);
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
    });

    test('dispose clears the memory', () {
      sut.dispose();

      verify(() => mockSodium.memzero(testList));
    });
  });
}
