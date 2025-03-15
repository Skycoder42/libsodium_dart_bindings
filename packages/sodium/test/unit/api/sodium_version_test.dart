import 'package:sodium/src/api/sodium_version.dart';
import 'package:test/test.dart';

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

  testData<(SodiumVersion, Object?, bool)>(
    'equals and hashcode work correctly',
    const [
      (SodiumVersion(1, 2, '1.2'), SodiumVersion(1, 2, '1.2'), true),
      (SodiumVersion(1, 2, '1.2'), SodiumVersion(1, 2, '1.2-fake'), true),
      (SodiumVersion(1, 2, '1.2'), SodiumVersion(1, 3, '1.3'), false),
      (SodiumVersion(1, 2, '1.2'), SodiumVersion(2, 2, '2.2'), false),
      (SodiumVersion(1, 2, '1.2'), SodiumVersion(2, 3, '2.3'), false),
      (SodiumVersion(1, 2, '1.2'), '1.2', false),
      (SodiumVersion(1, 2, '1.2'), null, true),
    ],
    (fixture) {
      expect(fixture.$1 == (fixture.$2 ?? fixture.$1), fixture.$3);
      expect(
        fixture.$1.hashCode == (fixture.$2 ?? fixture.$1).hashCode,
        fixture.$3,
      );
    },
    fixtureToString:
        (fixture) => '[${fixture.$1} == ${fixture.$2} -> ${fixture.$3}]',
  );

  testData<(SodiumVersion, SodiumVersion, bool)>(
    'operator< works correctly',
    const [
      (SodiumVersion(1, 2, '1.2'), SodiumVersion(1, 2, '1.2'), false),
      (SodiumVersion(1, 2, '1.2'), SodiumVersion(1, 3, '1.3'), true),
      (SodiumVersion(1, 2, '1.2'), SodiumVersion(2, 2, '2.2'), true),
      (SodiumVersion(1, 2, '1.2'), SodiumVersion(2, 3, '2.3'), true),
      (SodiumVersion(1, 3, '1.3'), SodiumVersion(1, 2, '1.2'), false),
      (SodiumVersion(2, 2, '2.2'), SodiumVersion(1, 2, '1.2'), false),
      (SodiumVersion(2, 3, '2.3'), SodiumVersion(1, 2, '1.2'), false),
    ],
    (fixture) {
      expect(fixture.$1 < fixture.$2, fixture.$3);
    },
    fixtureToString:
        (fixture) => '[${fixture.$1} < ${fixture.$2} -> ${fixture.$3}]',
  );

  testData<(SodiumVersion, SodiumVersion, bool)>(
    'operator<= works correctly',
    const [
      (SodiumVersion(1, 2, '1.2'), SodiumVersion(1, 2, '1.2'), true),
      (SodiumVersion(1, 2, '1.2'), SodiumVersion(1, 3, '1.3'), true),
      (SodiumVersion(1, 2, '1.2'), SodiumVersion(2, 2, '2.2'), true),
      (SodiumVersion(1, 2, '1.2'), SodiumVersion(2, 3, '2.3'), true),
      (SodiumVersion(1, 3, '1.3'), SodiumVersion(1, 2, '1.2'), false),
      (SodiumVersion(2, 2, '2.2'), SodiumVersion(1, 2, '1.2'), false),
      (SodiumVersion(2, 3, '2.3'), SodiumVersion(1, 2, '1.2'), false),
    ],
    (fixture) {
      expect(fixture.$1 <= fixture.$2, fixture.$3);
    },
    fixtureToString:
        (fixture) => '[${fixture.$1} <= ${fixture.$2} -> ${fixture.$3}]',
  );

  testData<(SodiumVersion, SodiumVersion, bool)>(
    'operator> works correctly',
    const [
      (SodiumVersion(1, 2, '1.2'), SodiumVersion(1, 2, '1.2'), false),
      (SodiumVersion(1, 2, '1.2'), SodiumVersion(1, 3, '1.3'), false),
      (SodiumVersion(1, 2, '1.2'), SodiumVersion(2, 2, '2.2'), false),
      (SodiumVersion(1, 2, '1.2'), SodiumVersion(2, 3, '2.3'), false),
      (SodiumVersion(1, 3, '1.3'), SodiumVersion(1, 2, '1.2'), true),
      (SodiumVersion(2, 2, '2.2'), SodiumVersion(1, 2, '1.2'), true),
      (SodiumVersion(2, 3, '2.3'), SodiumVersion(1, 2, '1.2'), true),
    ],
    (fixture) {
      expect(fixture.$1 > fixture.$2, fixture.$3);
    },
    fixtureToString:
        (fixture) => '[${fixture.$1} > ${fixture.$2} -> ${fixture.$3}]',
  );

  testData<(SodiumVersion, SodiumVersion, bool)>(
    'operator>= works correctly',
    const [
      (SodiumVersion(1, 2, '1.2'), SodiumVersion(1, 2, '1.2'), true),
      (SodiumVersion(1, 2, '1.2'), SodiumVersion(1, 3, '1.3'), false),
      (SodiumVersion(1, 2, '1.2'), SodiumVersion(2, 2, '2.2'), false),
      (SodiumVersion(1, 2, '1.2'), SodiumVersion(2, 3, '2.3'), false),
      (SodiumVersion(1, 3, '1.3'), SodiumVersion(1, 2, '1.2'), true),
      (SodiumVersion(2, 2, '2.2'), SodiumVersion(1, 2, '1.2'), true),
      (SodiumVersion(2, 3, '2.3'), SodiumVersion(1, 2, '1.2'), true),
    ],
    (fixture) {
      expect(fixture.$1 >= fixture.$2, fixture.$3);
    },
    fixtureToString:
        (fixture) => '[${fixture.$1} >= ${fixture.$2} -> ${fixture.$3}]',
  );
}
