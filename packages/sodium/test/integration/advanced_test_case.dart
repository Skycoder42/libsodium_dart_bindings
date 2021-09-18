import 'package:meta/meta.dart';
// dart_pre_commit:ignore-library-import
import 'package:sodium/sodium.sumo.dart';

import 'test_runner.dart';

export 'package:test/test.dart' hide test, group;

abstract class AdvancedTestCase {
  final TestRunner _runner;

  AdvancedTestCase(this._runner);

  @protected
  AdvancedSodium get sodium => _runner.sodium as AdvancedSodium;

  @isTest
  @protected
  TestFn get test => _runner.test;

  @isTestGroup
  @protected
  GroupFn get group => _runner.group;

  String get name;

  void setupTests();
}
