import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/secure_key.dart';
import 'package:sodium/src/api/sodium.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../secure_key_fake.dart';
import '../../test_data.dart';

class MockSodium extends Mock implements Sodium {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uint8List(0));
  });

  group('SecureKey', () {
    final mockSodium = MockSodium();

    setUp(() {
      reset(mockSodium);
    });

    group('factory constructors', () {
      test('default calls secureAlloc', () {
        final fake = SecureKeyFake(const [5, 10, 15]);
        when(() => mockSodium.secureAlloc(any())).thenReturn(fake);

        final sut = SecureKey(mockSodium, 10);

        expect(sut, same(fake));
        verify(() => mockSodium.secureAlloc(10));
      });

      test('fromList calls secureCopy', () {
        final fake = SecureKeyFake(const [5, 10, 15]);
        when(() => mockSodium.secureCopy(any())).thenReturn(fake);

        final data = Uint8List.fromList(const [1, 2, 3, 4]);
        final sut = SecureKey.fromList(mockSodium, data);

        expect(sut, same(fake));
        verify(() => mockSodium.secureCopy(data));
      });

      test('random calls secureRandom', () {
        final fake = SecureKeyFake(const [5, 10, 15]);
        when(() => mockSodium.secureRandom(any())).thenReturn(fake);

        final sut = SecureKey.random(mockSodium, 10);

        expect(sut, same(fake));
        verify(() => mockSodium.secureRandom(10));
      });

      test('fromNativeHandle calls secureHandle', () {
        const nativeHandle = 'test_native_handle';
        final fake = SecureKeyFake(const [5, 10, 15]);
        when(() => mockSodium.secureHandle(any<dynamic>())).thenReturn(fake);

        final sut = SecureKey.fromNativeHandle(mockSodium, nativeHandle);

        expect(sut, same(fake));
        verify(() => mockSodium.secureHandle(nativeHandle));
      });
    });
  });

  group('SecureKeyEquality', () {
    test('operator== returns true if identical', () {
      final sut = SecureKeyFake(const [1, 2, 3, 4]);
      expect(sut, equals(sut));
    });

    test('operator== returns false if different type', () {
      final sut = SecureKeyFake(const [1, 2, 3, 4]);
      expect(sut, isNot(equals(Uint8List.fromList(const [1, 2, 3, 4]))));
    });

    testData<Tuple3<List<int>, List<int>, bool>>(
      'operator== returns correct result for data',
      const [
        Tuple3([], [], true),
        Tuple3([1, 2, 3], [1, 2, 3], true),
        Tuple3([1, 2, 3], [1, 4, 3], false),
        Tuple3([1, 2], [1, 2, 3], false),
        Tuple3([1, 2, 3], [1, 2], false),
      ],
      (fixture) {
        final sut1 = SecureKeyFake(fixture.item1);
        final sut2 = SecureKeyFake(fixture.item2);
        expect(sut1, fixture.item3 ? equals(sut2) : isNot(equals(sut2)));
      },
    );
  });
}
