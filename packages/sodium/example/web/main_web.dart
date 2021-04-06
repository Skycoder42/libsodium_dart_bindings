import 'dart:html';

import 'package:sodium/sodium.dart';
import 'package:sodium_example/sodium_example.dart';

Future<void> main() async {
  print('init...');
  final Sodium sodium = await SodiumJSInit.init();

  final res = runSample(sodium);

  querySelector('#output')!.innerHtml =
      'Sodium Version: ${sodium.version}<br/>Hash-Result: $res';
}
