// ignore_for_file: avoid_print for example
import 'dart:ffi';
import 'dart:io';

import 'package:sodium/sodium.dart';

import 'package:sodium_example/sodium_example.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty) {
    stderr.writeln('Usage: main_native.dart <path_to_libsodium.[dll|so|dylib]');
    exit(1);
  }

  final sodium = await SodiumInit.init(
    () => DynamicLibrary.open(arguments.first),
  );

  const message = 'Hello, World!';
  final cipher = runSample(sodium, message);

  print('Plain text: $message');
  print('Secret box result: $cipher');
}
