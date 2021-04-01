import 'dart:html';

import 'package:libsodium_dart_bindings/libsodium_dart_bindings.dart';
import 'package:libsodium_dart_bindings_example/libsodium_dart_bindings_example.dart';

Future<void> main() async {
  print('init...');
  final Sodium sodium = await SodiumJSInit.init();

  final res = runSample(sodium);

  querySelector('#output')!.innerHtml =
      'Sodium Version: ${sodium.version}<br/>Hash-Result: $res';
}
