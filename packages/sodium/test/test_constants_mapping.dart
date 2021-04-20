import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import 'test_data.dart';

@isTestGroup
void testConstantsMapping(
  List<Tuple3<num Function(), int Function(), String>> data,
) =>
    testData<Tuple3<num Function(), int Function(), String>>(
      'maps integer constants correctly',
      data,
      (fixture) {
        const value = 10;
        when(fixture.item1).thenReturn(value);

        final res = fixture.item2();

        expect(res, value);
        verify(fixture.item1);
      },
      fixtureToString: (fixture) => fixture.item3,
    );
