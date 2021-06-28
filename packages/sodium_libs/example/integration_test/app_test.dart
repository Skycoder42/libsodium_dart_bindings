import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:sodium_libs_example/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('reports correct libsodium version', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(
      find.text('Loaded libsodium with version 1.0.18'),
      findsOneWidget,
    );
  });
}
