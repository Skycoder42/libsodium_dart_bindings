import 'package:meta/meta.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

import 'test_data.dart';

@isTestGroup
void testConstantsMapping(
  List<(num Function(), int Function(), String)> data,
) => testData<(num Function(), int Function(), String)>(
  'maps integer constant correctly:',
  data,
  (fixture) {
    const value = 10;
    when(fixture.$1).thenReturn(value);

    final res = fixture.$2();

    expect(res, value);
    verify(fixture.$1);
  },
  fixtureToString: (fixture) => fixture.$3,
);
