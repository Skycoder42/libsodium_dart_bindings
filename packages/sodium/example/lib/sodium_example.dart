// ignore_for_file: avoid_print
import 'dart:typed_data';

import 'package:sodium/sodium.dart';

Uint8List runSample(Sodium sodium) {
  print('libsodium version: ${sodium.version}');

  const password = 'testtesttesttesttesttesttest';
  final salt = sodium.randombytes.buf(sodium.crypto.pwhash.saltBytes);
  final pwChars = password.toCharArray();

  print('hashing...');
  final timer = Stopwatch()..start();
  final hashedPw = sodium.crypto.pwhash(
    outLen: 64,
    password: pwChars,
    salt: salt,
    opsLimit: sodium.crypto.pwhash.opsLimitInteractive,
    memLimit: sodium.crypto.pwhash.memLimitInteractive,
  );
  timer.stop();
  print('Done after ${timer.elapsed}');

  final extracted = hashedPw.extractBytes();
  hashedPw.dispose();
  return extracted;
}
