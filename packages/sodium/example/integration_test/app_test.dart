// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart' as ft;
import 'package:integration_test/integration_test.dart';
import 'package:sodium/sodium_sumo.dart';

import '../../test/integration/test_runner.dart';

import 'arch_detection_fallback.dart'
    if (dart.library.ffi) 'arch_detection_ffi.dart'
    as arch;

class FlutterTestRunner extends SumoTestRunner {
  @override
  bool get is32Bit => arch.is32Bit;

  @override
  Future<SodiumSumo> loadSodium() async => await SodiumSumoInit.init();

  @override
  SetupAllFn get setUpAll => ft.setUpAll;

  @override
  GroupFn get group => ft.group;

  @override
  void test(
    String description,
    dynamic Function(Sodium sodium) body, {
    bool? skip,
  }) => ft.testWidgets(description, skip: skip, (tester) async => body(sodium));

  @override
  void testSumo(String description, dynamic Function(SodiumSumo sodium) body) =>
      ft.testWidgets(description, (tester) async => body(sodium));

  @override
  Future<T> ioCompute<T, M>(
    FutureOr<T> Function(M message) callback,
    M message,
  ) => compute(callback, message);
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final integrationTestRunner = FlutterTestRunner();
  integrationTestRunner.setupTests();
}
