import 'dart:async';

import 'package:meta/meta.dart';
// ignore: test_library_import
import 'package:sodium/sodium_sumo.dart';
import 'package:test/test.dart' as t;

import 'cases/aead_test_case.dart';
import 'cases/auth_test_case.dart';
import 'cases/box_test_case.dart';
import 'cases/generic_hash_test_case.dart';
import 'cases/kdf_test_case.dart';
import 'cases/kx_test_case.dart';
import 'cases/pwhash_test_case.dart';
import 'cases/randombytes_test_case.dart';
import 'cases/scalarmult_test_case.dart';
import 'cases/secret_box_test_case.dart';
import 'cases/secret_stream_test_case.dart';
import 'cases/short_hash_test_case.dart';
import 'cases/sign_test_case.dart';
import 'cases/sodium_init_test_case.dart';
import 'cases/sodium_test_case.dart';
import 'test_case.dart';

typedef SetupAllFn = void Function(dynamic Function() body);
typedef SetupFn = void Function(dynamic Function(Sodium sodium) body);
typedef GroupFn = void Function(String description, dynamic Function() body);
typedef TestFn = void Function(
    String description, dynamic Function(Sodium sodium) body);
typedef TestSumoFn = void Function(
    String description, dynamic Function(SodiumSumo sodium) body);

abstract class TestRunner {
  late final Sodium _sodium;

  bool get isSumoTest => false;

  bool get is32Bit => false;

  Sodium get sodium => _sodium;

  TestRunner();

  Iterable<TestCase> createTestCases() => [
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
        PwhashTestCase(this, is32Bit: is32Bit),
        KdfTestCase(this),
        KxTestCase(this),
        ScalarMultTestCase(this),
      ];

  @protected
  @visibleForTesting
  Future<Sodium> loadSodium();

  @visibleForOverriding
  late SetupAllFn setUpAll = t.setUpAll;

  @visibleForOverriding
  void setUp(dynamic Function(Sodium sodium) body) =>
      t.setUp(() => body(_sodium));

  @visibleForOverriding
  void test(String description, dynamic Function(Sodium sodium) body) => t.test(
        description,
        () => body(_sodium),
      );

  @visibleForOverriding
  void testSumo(String description, dynamic Function(SodiumSumo sodium) body) =>
      t.test(
        description,
        () {},
        skip: 'This test only works with the sodium.js sumo variant',
      );

  @visibleForOverriding
  late GroupFn group = t.group;

  void setupTests() {
    final testCases = createTestCases().toList();

    setUpAll(() async {
      _sodium = await loadSodium();

      // ignore: avoid_print
      print(
        'Running integration tests with libsodium version: ${_sodium.version} '
        '(${is32Bit ? '32 bit' : '64 bit'})',
      );
    });

    for (final testCase in testCases) {
      group(testCase.name, () {
        testCase.setupTests();
      });
    }
  }
}

abstract class SumoTestRunner extends TestRunner {
  @override
  bool get isSumoTest => true;

  SodiumSumo get sodium => _sodium as SodiumSumo;

  @protected
  @visibleForTesting
  @override
  Future<SodiumSumo> loadSodium();

  @visibleForOverriding
  void testSumo(String description, dynamic Function(SodiumSumo sodium) body) =>
      t.test(
        description,
        () => body(sodium),
      );
}
