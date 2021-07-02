import 'package:meta/meta.dart';
// dart_pre_commit:ignore-library-import
import 'package:sodium/sodium.dart';

import 'test_runner.dart';

export 'package:test/test.dart' hide test, group;

abstract class TestCase {
  final TestRunner _runner;

  TestCase(this._runner);

  @protected
  Sodium get sodium => _runner.sodium;

  @isTest
  @protected
  TestFn get test => _runner.test;

  @isTestGroup
  @protected
  TestFn get group => _runner.group;

  String get name;

  void setupTests();
}
