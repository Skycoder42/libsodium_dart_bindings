import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/api/sodium.dart';
import 'package:test/test.dart';

import '../../test_data.dart';

class MockSodium extends Mock with SodiumValidations implements Sodium;

void main() {
  group('SodiumValidations', () {
    late MockSodium sutMock;

    setUp(() {
      sutMock = MockSodium();
    });

    testData<(int, int, bool)>(
      'validateSameLength asserts if the lengths do not match',
      const [(0, 0, false), (5, 5, false), (5, 4, true), (5, 6, true)],
      (fixture) {
        final exceptionMatcher = throwsA(
          isA<RangeError>()
              .having((e) => e.name, 'name', 'b')
              .having((e) => e.invalidValue, 'invalidValue', fixture.$2),
        );
        expect(
          () => sutMock.validateSameLength(
            Uint8List(fixture.$1),
            Uint8List(fixture.$2),
            'b',
          ),
          fixture.$3 ? exceptionMatcher : isNot(exceptionMatcher),
        );
      },
    );

    testData<(String, bool)>(
      'validateHex asserts if value is not ascii encoded',
      const [
        ('', false),
        ('4142ab', false),
        ('4142AB', false),
        ('41:42', false),
        ('\x7F', false),
        ('41ä2', true),
        ('41€2', true),
      ],
      (fixture) {
        final exceptionMatcher = throwsA(
          isA<ArgumentError>().having((e) => e.name, 'name', 'hex'),
        );
        expect(
          () => sutMock.validateHex(fixture.$1),
          fixture.$2 ? exceptionMatcher : isNot(exceptionMatcher),
        );
      },
    );
  });
}
