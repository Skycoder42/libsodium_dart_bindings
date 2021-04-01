// ignore_for_file: avoid_print
import 'dart:typed_data';

import 'package:libsodium_dart_bindings/libsodium_dart_bindings.dart';

Uint8List runSample(Sodium sodium) {
  print('libsodium version: ${sodium.version}');

  const password = 'testtesttesttesttesttesttest';
  final salt = sodium.randombytes.buf(sodium.crypto.pwhash.saltBytes);
  final pwChars = password.toCharArray();

  print('hashing...');
  final timer = Stopwatch()..start();
  final hashedPw = sodium.crypto.pwhash(
    64,
    pwChars,
    salt,
    sodium.crypto.pwhash.opsLimitInteractive,
    sodium.crypto.pwhash.memLimitInteractive,
    CrypoPwhashAlgorithm.defaultAlg,
  );
  timer.stop();
  print('Done after ${timer.elapsed}');

  final extracted = hashedPw.extractBytes();
  hashedPw.dispose();
  return extracted;
}
