import 'dart:async';

import 'package:meta/meta.dart';
// dart_pre_commit:ignore-library-import
import 'package:sodium/sodium.dart';
import 'package:test/test.dart' as t;

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
  Iterable<TestCase> createTestCases();

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
