import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:libsodium_flutter_bindings/libsodium_flutter_bindings.dart';

void main() {
  const MethodChannel channel = MethodChannel('libsodium_flutter_bindings');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await LibsodiumFlutterBindings.platformVersion, '42');
  });
}
