import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'test_data.dart';

@isTestGroup
void testCheckIsSame(
  String name, {
  required int Function() source,
  required void Function(int value) sut,
}) =>
    testData<(int, bool)>(
      '$name asserts if value is not as expected',
      const [
        (5, false),
        (4, true),
        (6, true),
      ],
      (fixture) {
        when(source).thenReturn(5);

        final exceptionMatcher = throwsA(isA<RangeError>());
        expect(
          () => sut(fixture.$1),
          fixture.$2 ? exceptionMatcher : isNot(exceptionMatcher),
        );

        verify(source);
      },
    );

@isTestGroup
void testCheckAtLeast(
  String name, {
  required int Function() source,
  required void Function(int value) sut,
}) =>
    testData<(int, bool)>(
      '$name asserts if value is not as expected',
      const [
        (5, false),
        (6, false),
        (100000, false),
        (4, true),
      ],
      (fixture) {
        when(source).thenReturn(5);

        final exceptionMatcher = throwsA(isA<RangeError>());
        expect(
          () => sut(fixture.$1),
          fixture.$2 ? exceptionMatcher : isNot(exceptionMatcher),
        );

        verify(source);
      },
    );

@isTestGroup
void testCheckAtMost(
  String name, {
  required int Function() source,
  required void Function(int value) sut,
}) =>
    testData<(int, bool)>(
      '$name asserts if value is not as expected',
      const [
        (5, false),
        (4, false),
        (0, false),
        (6, true),
      ],
      (fixture) {
        when(source).thenReturn(5);

        final exceptionMatcher = throwsA(isA<RangeError>());
        expect(
          () => sut(fixture.$1),
          fixture.$2 ? exceptionMatcher : isNot(exceptionMatcher),
        );

        verify(source);
      },
    );

@isTestGroup
void testCheckInRange(
  String name, {
  required int Function() minSource,
  required int Function() maxSource,
  required void Function(int value) sut,
}) =>
    testData<(int, bool)>(
      '$name asserts if value is not as expected',
      const [
        (5, false),
        (10, false),
        (15, false),
        (4, true),
        (16, true),
      ],
      (fixture) {
        when(minSource).thenReturn(5);
        when(maxSource).thenReturn(15);

        final exceptionMatcher = throwsA(isA<RangeError>());
        expect(
          () => sut(fixture.$1),
          fixture.$2 ? exceptionMatcher : isNot(exceptionMatcher),
        );

        verify(minSource);
        verify(maxSource);
      },
    );
