import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import 'test_data.dart';

@isTestGroup
void testCheckIsSame(
  String name, {
  required int Function() source,
  required void Function(int value) sut,
}) =>
    testData<Tuple2<int, bool>>(
      '$name asserts if value is not as expected',
      const [
        Tuple2(5, false),
        Tuple2(4, true),
        Tuple2(6, true),
      ],
      (fixture) {
        when(source).thenReturn(5);

        final exceptionMatcher = throwsA(isA<RangeError>());
        expect(
          () => sut(fixture.item1),
          fixture.item2 ? exceptionMatcher : isNot(exceptionMatcher),
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
    testData<Tuple2<int, bool>>(
      '$name asserts if value is not as expected',
      const [
        Tuple2(5, false),
        Tuple2(6, false),
        Tuple2(100000, false),
        Tuple2(4, true),
      ],
      (fixture) {
        when(source).thenReturn(5);

        final exceptionMatcher = throwsA(isA<RangeError>());
        expect(
          () => sut(fixture.item1),
          fixture.item2 ? exceptionMatcher : isNot(exceptionMatcher),
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
    testData<Tuple2<int, bool>>(
      '$name asserts if value is not as expected',
      const [
        Tuple2(5, false),
        Tuple2(4, false),
        Tuple2(0, false),
        Tuple2(6, true),
      ],
      (fixture) {
        when(source).thenReturn(5);

        final exceptionMatcher = throwsA(isA<RangeError>());
        expect(
          () => sut(fixture.item1),
          fixture.item2 ? exceptionMatcher : isNot(exceptionMatcher),
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
    testData<Tuple2<int, bool>>(
      '$name asserts if value is not as expected',
      const [
        Tuple2(5, false),
        Tuple2(10, false),
        Tuple2(15, false),
        Tuple2(4, true),
        Tuple2(16, true),
      ],
      (fixture) {
        when(minSource).thenReturn(5);
        when(maxSource).thenReturn(15);

        final exceptionMatcher = throwsA(isA<RangeError>());
        expect(
          () => sut(fixture.item1),
          fixture.item2 ? exceptionMatcher : isNot(exceptionMatcher),
        );

        verify(minSource);
        verify(maxSource);
      },
    );
