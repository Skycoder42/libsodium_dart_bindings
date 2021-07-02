import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart' as ft;
import 'package:integration_test/integration_test.dart';
import 'package:sodium_libs/sodium_libs.dart';

import 'package:sodium_libs_example/main.dart' show MyApp;

import '../../../sodium/test/integration/test_runner.dart';

class FlutterTestRunner extends TestRunner {
  @override
  Future<Sodium> loadSodium() => SodiumInit.init();

  @override
  SetupFn get setUpAll => ft.setUpAll;

  @override
  TestFn get group => ft.group;

  @override
  TestFn get test => (description, body) => ft.testWidgets(
        description,
        (tester) async => body(),
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
