import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/secure_key_extensions.dart';
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

  group('SecureKeyExtensions', () {
    final mockSodium = MockSodium();

    setUp(() {
      reset(mockSodium);
    });

    group('SecureKeySplit', () {
      test('throws ArgumentError on empty lengths argument', () {
        final sut = SecureKeyFake(const [1, 2, 3, 4]);
        expect(() => sut.split(mockSodium, []), throwsA(isA<ArgumentError>()));
      });

      test('throws RangeError when any length < 1', () {
        final sut = SecureKeyFake(const [1, 2, 3, 4]);
        expect(
          () => sut.split(mockSodium, [4, 0]),
          throwsA(isA<RangeError>()),
        );
      });

      test('throws RangeError when sum of lengths exceed key length', () {
        final sut = SecureKeyFake(const [1, 2, 3, 4]);
        expect(
          () => sut.split(mockSodium, [4, 1]),
          throwsA(isA<RangeError>()),
        );
      });

      testData<Tuple4<List<int>, List<int>, List<int>, List<int>?>>(
        'returns correct keys for data',
        const [
          Tuple4([1, 2, 3, 4], [1, 3], [1], [2, 3, 4]),
          Tuple4([1, 2, 3, 4], [2, 2], [1, 2], [3, 4]),
          Tuple4([1, 2, 3, 4], [3, 1], [1, 2, 3], [4]),
          Tuple4([1, 2, 3, 4], [3], [1, 2, 3], null),
          Tuple4([1, 2, 3, 4], [4], [1, 2, 3, 4], null),
          Tuple4([1, 2, 3, 4, 5], [2, 2], [1, 2], [3, 4]),
        ],
        (fixture) {
          _mockSodiumAllocations(mockSodium);
          final sut = SecureKeyFake(fixture.item1);
          final first = SecureKeyFake(fixture.item3);
          final keys = sut.split(mockSodium, fixture.item2);
          expect(keys[0], equals(first));

          final secondList = fixture.item4;
          if (secondList != null) {
            final second = SecureKeyFake(secondList);
            expect(keys[1], equals(second));
          }
        },
      );
    });
  });
}

void _mockSodiumAllocations(MockSodium mockSodium) {
  when(() => mockSodium.secureAlloc(any())).thenAnswer(
    (invocation) {
      expect(invocation.positionalArguments.first, isA<int>());
      final length = invocation.positionalArguments.first as int;
      return SecureKeyFake.empty(length);
    },
  );
}
