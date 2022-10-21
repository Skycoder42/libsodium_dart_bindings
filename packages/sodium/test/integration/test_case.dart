import 'package:meta/meta.dart';
// ignore: test_library_import

import 'test_runner.dart';

export 'package:test/test.dart' hide test, group, setUp;

abstract class TestCase {
  final TestRunner _runner;

  TestCase(this._runner);

  @protected
  // ignore: invalid_use_of_visible_for_overriding_member
  SetupFn get setUp => _runner.setUp;

  @isTest
  @protected
  // ignore: invalid_use_of_visible_for_overriding_member
  TestFn get test => _runner.test;

  @isTest
  @protected
  // ignore: invalid_use_of_visible_for_overriding_member
  TestSumoFn get testSumo => _runner.testSumo;

  @isTestGroup
  @protected
  // ignore: invalid_use_of_visible_for_overriding_member
  GroupFn get group => _runner.group;

  String get name;

  void setupTests();
}
