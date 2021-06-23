import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  late FlutterDriver driver;

  setUpAll(() async {
    driver = await FlutterDriver.connect();
  });

  tearDownAll(() async {
    await driver.close();
  });

  test('reports correct libsodium version', () async {
    await driver.waitFor(find.byValueKey('resultText'));
    expect(
      await driver.getText(find.byValueKey('resultText')),
      'Loaded libsodium with version 1.0.18',
    );
  });
}
