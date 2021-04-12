import 'package:sodium/src/api/sodium_version.dart';
import 'package:test/test.dart';
import 'package:tuple/tuple.dart';

import '../../test_data.dart';

void main() {
  test('correctly uses initialized values', () {
    const major = 4;
    const minor = 2;
    const str = 'vStr';

    const version = SodiumVersion(major, minor, str);

    expect(version.major, major);
    expect(version.minor, minor);
    expect(version.toString(), str);
  });

  testData<Tuple3<SodiumVersion, Object?, bool>>(
    'equals and hashcode work correctly',
    const [
      Tuple3(SodiumVersion(1, 2, '1.2'), SodiumVersion(1, 2, '1.2'), true),
      Tuple3(SodiumVersion(1, 2, '1.2'), SodiumVersion(1, 2, '1.2-fake'), true),
      Tuple3(SodiumVersion(1, 2, '1.2'), SodiumVersion(1, 3, '1.3'), false),
      Tuple3(SodiumVersion(1, 2, '1.2'), SodiumVersion(2, 2, '2.2'), false),
      Tuple3(SodiumVersion(1, 2, '1.2'), SodiumVersion(2, 3, '2.3'), false),
      Tuple3(SodiumVersion(1, 2, '1.2'), '1.2', false),
      Tuple3(SodiumVersion(1, 2, '1.2'), null, true),
    ],
    (fixture) {
      expect(fixture.item1 == (fixture.item2 ?? fixture.item1), fixture.item3);
      expect(
        fixture.item1.hashCode == (fixture.item2 ?? fixture.item1).hashCode,
        fixture.item3,
      );
    },
    fixtureToString: (fixture) =>
        '[${fixture.item1} == ${fixture.item2} -> ${fixture.item3}]',
  );

  testData<Tuple3<SodiumVersion, SodiumVersion, bool>>(
    'operator< works correctly',
    const [
      Tuple3(SodiumVersion(1, 2, '1.2'), SodiumVersion(1, 2, '1.2'), false),
      Tuple3(SodiumVersion(1, 2, '1.2'), SodiumVersion(1, 3, '1.3'), true),
      Tuple3(SodiumVersion(1, 2, '1.2'), SodiumVersion(2, 2, '2.2'), true),
      Tuple3(SodiumVersion(1, 2, '1.2'), SodiumVersion(2, 3, '2.3'), true),
      Tuple3(SodiumVersion(1, 3, '1.3'), SodiumVersion(1, 2, '1.2'), false),
      Tuple3(SodiumVersion(2, 2, '2.2'), SodiumVersion(1, 2, '1.2'), false),
      Tuple3(SodiumVersion(2, 3, '2.3'), SodiumVersion(1, 2, '1.2'), false),
    ],
    (fixture) {
      expect(fixture.item1 < fixture.item2, fixture.item3);
    },
    fixtureToString: (fixture) =>
        '[${fixture.item1} < ${fixture.item2} -> ${fixture.item3}]',
  );

  testData<Tuple3<SodiumVersion, SodiumVersion, bool>>(
    'operator<= works correctly',
    const [
      Tuple3(SodiumVersion(1, 2, '1.2'), SodiumVersion(1, 2, '1.2'), true),
      Tuple3(SodiumVersion(1, 2, '1.2'), SodiumVersion(1, 3, '1.3'), true),
      Tuple3(SodiumVersion(1, 2, '1.2'), SodiumVersion(2, 2, '2.2'), true),
      Tuple3(SodiumVersion(1, 2, '1.2'), SodiumVersion(2, 3, '2.3'), true),
      Tuple3(SodiumVersion(1, 3, '1.3'), SodiumVersion(1, 2, '1.2'), false),
      Tuple3(SodiumVersion(2, 2, '2.2'), SodiumVersion(1, 2, '1.2'), false),
      Tuple3(SodiumVersion(2, 3, '2.3'), SodiumVersion(1, 2, '1.2'), false),
    ],
    (fixture) {
      expect(fixture.item1 <= fixture.item2, fixture.item3);
    },
    fixtureToString: (fixture) =>
        '[${fixture.item1} <= ${fixture.item2} -> ${fixture.item3}]',
  );

  testData<Tuple3<SodiumVersion, SodiumVersion, bool>>(
    'operator> works correctly',
    const [
      Tuple3(SodiumVersion(1, 2, '1.2'), SodiumVersion(1, 2, '1.2'), false),
      Tuple3(SodiumVersion(1, 2, '1.2'), SodiumVersion(1, 3, '1.3'), false),
      Tuple3(SodiumVersion(1, 2, '1.2'), SodiumVersion(2, 2, '2.2'), false),
      Tuple3(SodiumVersion(1, 2, '1.2'), SodiumVersion(2, 3, '2.3'), false),
      Tuple3(SodiumVersion(1, 3, '1.3'), SodiumVersion(1, 2, '1.2'), true),
      Tuple3(SodiumVersion(2, 2, '2.2'), SodiumVersion(1, 2, '1.2'), true),
      Tuple3(SodiumVersion(2, 3, '2.3'), SodiumVersion(1, 2, '1.2'), true),
    ],
    (fixture) {
      expect(fixture.item1 > fixture.item2, fixture.item3);
    },
    fixtureToString: (fixture) =>
        '[${fixture.item1} > ${fixture.item2} -> ${fixture.item3}]',
  );

  testData<Tuple3<SodiumVersion, SodiumVersion, bool>>(
    'operator>= works correctly',
    const [
      Tuple3(SodiumVersion(1, 2, '1.2'), SodiumVersion(1, 2, '1.2'), true),
      Tuple3(SodiumVersion(1, 2, '1.2'), SodiumVersion(1, 3, '1.3'), false),
      Tuple3(SodiumVersion(1, 2, '1.2'), SodiumVersion(2, 2, '2.2'), false),
      Tuple3(SodiumVersion(1, 2, '1.2'), SodiumVersion(2, 3, '2.3'), false),
      Tuple3(SodiumVersion(1, 3, '1.3'), SodiumVersion(1, 2, '1.2'), true),
      Tuple3(SodiumVersion(2, 2, '2.2'), SodiumVersion(1, 2, '1.2'), true),
      Tuple3(SodiumVersion(2, 3, '2.3'), SodiumVersion(1, 2, '1.2'), true),
    ],
    (fixture) {
      expect(fixture.item1 >= fixture.item2, fixture.item3);
    },
    fixtureToString: (fixture) =>
        '[${fixture.item1} >= ${fixture.item2} -> ${fixture.item3}]',
  );
}
