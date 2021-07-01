import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sodium_libs/sodium_libs.dart';

import 'package:sodium_libs_example/main.dart' show MyApp;

import '../../../sodium/test/integration/test_runner.dart';

class FlutterTestRunner extends TestRunner {
  @override
  Future<Sodium> loadSodium() => SodiumInit.init();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  final integrationTestRunner = FlutterTestRunner();

  testWidgets('reports correct libsodium version', (tester) async {
    runApp(MyApp(preInitSodium: integrationTestRunner.sodium));
    await tester.pumpAndSettle();

    expect(
      find.text('Loaded libsodium with version 1.0.18'),
      findsOneWidget,
    );
  });

  integrationTestRunner.setupTests();
}
