@TestOn('js')
library;

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium_exception.dart';
import 'package:sodium/src/js/api/secure_key_js.dart';
import 'package:sodium/src/js/bindings/js_error.dart';
import 'package:sodium/src/js/bindings/sodium.js.dart';
import 'package:sodium/src/js/bindings/sodium_finalizer.dart';
import 'package:test/test.dart';

import '../sodium_js_mock.dart';

class MockSodiumFinalizer extends Mock implements SodiumFinalizer {}

void main() {
  final mockSodium = MockLibSodiumJS();
  final mockSodiumFinalizer = MockSodiumFinalizer();

  late LibSodiumJS mockSodiumJS;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  setUp(() {
    reset(mockSodium);
    reset(mockSodiumFinalizer);

    mockSodiumJS = mockSodium.asLibSodiumJS;
    SecureKeyJS.debugOverwriteFinalizer(mockSodiumJS, mockSodiumFinalizer);
  });

  group('construction', () {
    test('raw initializes members and attaches to finalizer', () {
      final jsArray = Uint8List(3).toJS;
      final sut = SecureKeyJS(mockSodiumJS, jsArray);

      expect(sut.sodium, mockSodiumJS);

      verify(() => mockSodiumFinalizer.attach(sut, jsArray)).called(1);
    });

    test('alloc allocates new memory', () {
      const length = 42;
      final sut = SecureKeyJS.alloc(mockSodiumJS, length);

      expect(sut.extractBytes().length, length);
    });

    group('random', () {
      test('fills buffer with random data', () {
        const length = 10;

        when(
          () => mockSodium.randombytes_buf(any()),
        ).thenReturn(Uint8List(length).toJS);

        SecureKeyJS.random(mockSodiumJS, length);

        verify(() => mockSodium.randombytes_buf(length));
      });

      test('throws SodiumException on JSError', () {
        when(() => mockSodium.randombytes_buf(any())).thenThrow(JSError());

        expect(
          () => SecureKeyJS.random(mockSodiumJS, 10),
          throwsA(isA<SodiumException>()),
        );
      });
    });
  });

  group('members', () {
    const testList = [0, 1, 2, 3, 4];

    late SecureKeyJS sut;

    setUp(() {
      sut = SecureKeyJS(mockSodiumJS, Uint8List.fromList(testList).toJS);
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
      test('detaches from finalizer and clears the memory', () {
        sut.dispose();

        verifyInOrder([
          () => mockSodiumFinalizer.detach(sut),
          () => mockSodium.memzero(Uint8List.fromList(testList).toJS),
        ]);
      });

      test('throws SodiumException on JSError', () {
        when(() => mockSodium.memzero(any())).thenThrow(JSError());

        expect(() => sut.dispose(), throwsA(isA<SodiumException>()));
      });
    });
  });
}
