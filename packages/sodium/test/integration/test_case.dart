import 'package:meta/meta.dart';
// ignore: test_library_import
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
  // ignore: invalid_use_of_visible_for_overriding_member
  TestFn get test => _runner.test;

  @isTestGroup
  @protected
  // ignore: invalid_use_of_visible_for_overriding_member
  GroupFn get group => _runner.group;

  String get name;

  void setupTests();
}
