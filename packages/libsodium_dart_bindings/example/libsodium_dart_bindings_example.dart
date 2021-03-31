// ignore_for_file: avoid_print
import 'dart:ffi';
import 'dart:typed_data';

import 'package:libsodium_dart_bindings/libsodium_dart_bindings.dart';

void main() {
  final libsodium = DynamicLibrary.open('/usr/lib/libsodium.so');

  final crypto = SodiumFFIInit.init(libsodium);

  const password = 'testtesttesttesttesttesttest';

  final hashedPw = crypto.pwhash(
    16,
    password.toCharArray(),
    Uint8List(16),
    3,
    8192,
    CrypoPwhashAlgorithm.defaultAlg,
  );

  print(hashedPw.extractBytes());
}
