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

      // ignore: avoid_print
      print(
        'Running integration tests with libsodium version: ${sodium.version}',
      );

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
