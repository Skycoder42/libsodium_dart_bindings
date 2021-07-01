// dart_pre_commit:ignore-library-import
import 'package:meta/meta.dart';
import 'package:sodium/sodium.dart';
import 'package:test/test.dart';

import 'cases/aead_test_case.dart';
import 'cases/auth_test_case.dart';
import 'cases/box_test_case.dart';
import 'cases/generic_hash_test_case.dart';
import 'cases/kdf_test_case.dart';
import 'cases/kx_test_case.dart';
import 'cases/pwhash_test_case.dart';
import 'cases/randombytes_test_case.dart';
import 'cases/secret_box_test_case.dart';
import 'cases/secret_stream_test_case.dart';
import 'cases/short_hash_test_case.dart';
import 'cases/sign_test_case.dart';
import 'cases/sodium_test_case.dart';
import 'test_case.dart';

abstract class TestRunner {
  late final Sodium _sodium;

  Iterable<TestCase> createTestCases() => [
        SodiumTestCase(),
        RandombytesTestCase(),
        SecretBoxTestCase(),
        SecretStreamTestCase(),
        AeadTestCase(),
        AuthTestCase(),
        BoxTestCase(),
        SignTestCase(),
        GenericHashTestCase(),
        ShortHashTestCase(),
        PwhashTestCase(),
        KdfTestCase(),
        KxTestCase(),
      ];

  @protected
  Future<Sodium> loadSodium();

  Sodium get sodium => _sodium;

  void setupTests() {
    final testCases = createTestCases().toList();

    setUpAll(() async {
      _sodium = await loadSodium();

      // ignore: avoid_print
      print(
        'Running integration tests with libsodium version: ${_sodium.version}',
      );

      for (final testCase in testCases) {
        testCase.sodium = _sodium;
      }
    });

    for (final testCase in testCases) {
      group(testCase.name, () {
        testCase.setupTests();
      });
    }
  }
}
