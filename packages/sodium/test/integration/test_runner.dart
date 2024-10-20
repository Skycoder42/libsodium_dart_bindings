// ignore_for_file: unnecessary_lambdas

import 'dart:async';
import 'dart:isolate';

import 'package:meta/meta.dart';
// ignore: no_self_package_imports
import 'package:sodium/sodium_sumo.dart';
import 'package:test/test.dart' as t;

import 'cases/aead_chacha20poly1305_test_case.dart';
import 'cases/aead_xchacha20poly1305ietf_test_case.dart';
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
  String description,
  dynamic Function(Sodium sodium) body, {
  bool? skip,
});
typedef TestSumoFn = void Function(
  String description,
  dynamic Function(SodiumSumo sodium) body,
);

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
        AeadChaCha20Poly1305TestCase(this),
        AeadXChaCha20Poly1305IETFTestCase(this),
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
  void test(
    String description,
    dynamic Function(Sodium sodium) body, {
    bool? skip,
  }) =>
      t.test(
        description,
        skip: skip,
        () => body(_sodium),
      );

  @visibleForOverriding
  void testSumo(String description, dynamic Function(SodiumSumo sodium) body) =>
      t.test(
        '[sumo] $description',
        () => t.fail('This test only works with the sodium.js sumo variant'),
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

  Future<T> ioCompute<T, M>(
    FutureOr<T> Function(M message) callback,
    M message,
  ) =>
      Isolate.run(() => callback(message));
}

abstract class SumoTestRunner extends TestRunner {
  @override
  bool get isSumoTest => true;

  @override
  SodiumSumo get sodium => _sodium as SodiumSumo;

  @protected
  @visibleForTesting
  @override
  Future<SodiumSumo> loadSodium();

  @override
  @visibleForOverriding
  void testSumo(String description, dynamic Function(SodiumSumo sodium) body) =>
      t.test(
        '[sumo] $description',
        () => body(sodium),
      );
}
