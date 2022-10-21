import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' as ft;
import 'package:integration_test/integration_test.dart';
import 'package:sodium_libs/sodium_libs_sumo.dart';

import 'package:sodium_libs_example/main.dart' show MyApp;

import '../../../sodium/test/integration/test_runner.dart';

import 'arch_detection_fallback.dart'
    if (dart.library.ffi) 'arch_detection_ffi.dart' as arch;

class FlutterTestRunner extends SumoTestRunner {
  @override
  bool get is32Bit => arch.is32Bit;

  @override
  Future<SodiumSumo> loadSodium() => SodiumInit.initSumo();

  @override
  SetupAllFn get setUpAll => ft.setUpAll;

  @override
  GroupFn get group => ft.group;

  @override
  void test(String description, dynamic Function(Sodium sodium) body) =>
      ft.testWidgets(
        description,
        (tester) async => body(sodium),
      );

  @override
  void testSumo(String description, dynamic Function(SodiumSumo sodium) body) =>
      ft.testWidgets(
        description,
        (tester) async => body(sodium),
      );
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final integrationTestRunner = FlutterTestRunner();

  ft.testWidgets('reports correct libsodium version', (tester) async {
    runApp(MyApp(preInitSodium: integrationTestRunner.sodium));
    await tester.pumpAndSettle();

    ft.expect(
      ft.find.text('Loaded libsodium with version 1.0.18'),
      ft.findsOneWidget,
    );
  });

  integrationTestRunner.setupTests();
}
