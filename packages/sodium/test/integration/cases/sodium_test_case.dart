import 'package:test/test.dart';

import '../test_case.dart';

class SodiumTestCase extends TestCase {
  @override
  String get name => 'sodium';

  @override
  void setupTests() {
    test('reports correct version', () {
      final version = sodium.version;

      expect(version.major, 10);
      expect(version.minor, greaterThanOrEqualTo(3));
    });
  }
}
