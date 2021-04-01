import 'dart:ffi';

import 'package:libsodium_dart_bindings/libsodium_dart_bindings.dart';
import 'package:libsodium_dart_bindings_example/libsodium_dart_bindings_example.dart';

Future<void> main() async {
  final libsodium = DynamicLibrary.open('/usr/lib/libsodium.so');

  final sodium = await SodiumFFIInit.init(libsodium);

  final res = runSample(sodium);

  print('Hash-Result: $res');
}
