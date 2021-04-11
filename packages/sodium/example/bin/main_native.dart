// ignore_for_file: avoid_print
import 'dart:ffi';

import 'package:sodium/sodium.dart';
// ignore: avoid_relative_lib_imports
import '../lib/sodium_example.dart';

Future<void> main() async {
  final libsodium = DynamicLibrary.open('/usr/local/Cellar/libsodium/1.0.18_1/lib/libsodium.dylib');

  final sodium = await SodiumFFIInit.init(libsodium);

  final res = runSample(sodium);

  print('Hash-Result: $res');
}
