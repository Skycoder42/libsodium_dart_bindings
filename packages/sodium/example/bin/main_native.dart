// ignore_for_file: avoid_print
import 'dart:ffi';
import 'dart:io';

import 'package:sodium/sodium.dart';

// ignore: avoid_relative_lib_imports
import '../lib/sodium_example.dart';

Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty) {
    stderr.writeln(
      'Usage: main_native.dart <path_to_libsodium.[dll|so|dylib]',
    );
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
