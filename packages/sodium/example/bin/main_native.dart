// ignore_for_file: avoid_print for example

import 'package:sodium/sodium.dart';

import 'package:sodium_example/sodium_example.dart';

Future<void> main(List<String> arguments) async {
  final sodium = await SodiumInit.init();

  const message = 'Hello, World!';
  final cipher = runSample(sodium, message);

  print('Plain text: $message');
  print('Secret box result: $cipher');
}
