import 'package:sodium/src/api/sodium.dart';
import 'package:test/test.dart';

import 'cases/sodium_test_case.dart';
import 'test_case.dart';

abstract class TestRunner {
  Iterable<TestCase> createTestCases() => [
        SodiumTestCase(),
      ];

  Future<Sodium> loadSodium();

  void setupTests() {
    final testCases = createTestCases().toList();

    setUpAll(() async {
      final sodium = await loadSodium();

      for (final testCase in testCases) {
        testCase.sodium = sodium;
      }
    });

    for (final testCase in testCases) {
      group(testCase.name, () {
        testCase.setupTests();
      });
    }
  }
}
