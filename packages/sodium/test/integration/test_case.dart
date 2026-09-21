import 'dart:async';

import 'package:meta/meta.dart';

import 'test_runner.dart';

export 'package:test/test.dart' hide group, setUp, test;

abstract class TestCase(final TestRunner runner) {
  @protected
  SetupFn get setUp => runner.setUp;

  @isTest
  @protected
  TestFn get test => runner.test;

  @isTest
  @protected
  TestSumoFn get testSumo => runner.testSumo;

  @isTestGroup
  @protected
  GroupFn get group => runner.group;

  String get name;

  void setupTests();

  Future<T> ioCompute<T, M>(
    FutureOr<T> Function(M message) callback,
    M message,
  ) => runner.ioCompute(callback, message);
}
