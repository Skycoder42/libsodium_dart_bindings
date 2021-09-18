import 'dart:async';

import 'package:meta/meta.dart';
// dart_pre_commit:ignore-library-import
import 'package:sodium/sodium.dart';
import 'package:test/test.dart' as t;

import 'cases/advanced/advanced_scalarmult_case.dart';
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
import 'cases/sodium_init_test_case.dart';
import 'cases/sodium_test_case.dart';
import 'test_case.dart';

typedef SetupFn = void Function(dynamic Function() body);
typedef GroupFn = void Function(String description, dynamic Function() body);
typedef TestFn = void Function(
  String description,
  dynamic Function() body, {
  bool isSumo,
});

abstract class TestRunner {
  late final Sodium _sodium;

  final bool isSumoTest;

  TestRunner({
    required this.isSumoTest,
  });

  @protected
  Iterable<TestCase> createTestCases() => isSumoTest
      ? [
          AdvancedScalarMultTestCase(this),
        ]
      : [
          SodiumTestCase(this),
          SodiumInitTestCase(this),
          RandombytesTestCase(this),
          SecretBoxTestCase(this),
          SecretStreamTestCase(this),
          AeadTestCase(this),
          AuthTestCase(this),
          BoxTestCase(this),
          SignTestCase(this),
          GenericHashTestCase(this),
          ShortHashTestCase(this),
          PwhashTestCase(this),
          KdfTestCase(this),
          KxTestCase(this),
        ];

  @protected
  @visibleForTesting
  Future<Sodium> loadSodium();

  Sodium get sodium => _sodium;

  @visibleForOverriding
  late SetupFn setUpAll = t.setUpAll;

  @visibleForOverriding
  void test(
    String description,
    dynamic Function() body, {
    bool isSumo = false,
  }) =>
      t.test(
        description,
        body,
        skip: !isSumoTest && isSumo
            ? 'This test only works with the sodium.js sumo variant'
            : null,
      );

  @visibleForOverriding
  late GroupFn group = t.group;

  void setupTests() {
    final testCases = createTestCases().toList();

    setUpAll(() async {
      _sodium = await loadSodium();

      // ignore: avoid_print
      print(
        'Running integration tests with libsodium version: ${_sodium.version}',
      );
    });

    for (final testCase in testCases) {
      group(testCase.name, () {
        testCase.setupTests();
      });
    }
  }
}
