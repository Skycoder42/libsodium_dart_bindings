import 'dart:html';

import 'package:libsodium_dart_bindings/libsodium_dart_bindings.dart';
import 'package:libsodium_dart_bindings_example/libsodium_dart_bindings_example.dart';

Future<void> main() async {
  final Crypto crypto = await SodiumJSInit.init();

  final res = runSample(crypto);

  querySelector('#output')!.innerHtml =
      'Sodium Version: ${crypto.version}<br/>Hash-Result: $res';
}
