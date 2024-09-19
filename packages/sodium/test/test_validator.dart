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

@isTestGroup
void testCheckIsAny2(
  String name, {
  required int Function() source1,
  required int Function() source2,
  required void Function(int value) sut,
}) =>
    testData<(int, int, bool)>(
      '$name asserts if value is none of the expected',
      const [
        (5, 5, false),
        (4, 5, false),
        (5, 4, false),
        (6, 5, false),
        (5, 6, false),
        (4, 4, true),
        (6, 6, true),
        (4, 6, true),
        (6, 4, true),
      ],
      (fixture) {
        when(source1).thenReturn(fixture.$1);
        when(source2).thenReturn(fixture.$2);

        final exceptionMatcher = throwsA(isA<RangeError>());
        expect(
          () => sut(5),
          fixture.$3 ? exceptionMatcher : isNot(exceptionMatcher),
        );

        verify(source1);
        verify(source2);
      },
    );
