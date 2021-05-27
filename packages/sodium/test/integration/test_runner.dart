// dart_pre_commit:ignore-library-import
import 'package:sodium/sodium.dart';
import 'package:test/test.dart';

import 'cases/auth_test_case.dart';
import 'cases/box_test_case.dart';
import 'cases/generic_hash_test_case.dart';
import 'cases/pwhash_test_case.dart';
import 'cases/randombytes_test_case.dart';
import 'cases/secret_box_test_case.dart';
import 'cases/secret_stream_test_case.dart';
import 'cases/sign_test_case.dart';
import 'cases/sodium_test_case.dart';
import 'test_case.dart';

abstract class TestRunner {
  Iterable<TestCase> createTestCases() => [
        SodiumTestCase(),
        RandombytesTestCase(),
        SecretBoxTestCase(),
        SecretStreamTestCase(),
        AuthTestCase(),
        BoxTestCase(),
        SignTestCase(),
        GenericHashTestCase(),
        PwhashTestCase(),
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
