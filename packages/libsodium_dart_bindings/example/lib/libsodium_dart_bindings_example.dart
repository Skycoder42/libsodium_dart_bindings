import 'dart:typed_data';

import 'package:libsodium_dart_bindings/libsodium_dart_bindings.dart';

Uint8List runSample(Crypto crypto) {
  print('libsodium version: ${crypto.version}');

  const password = 'testtesttesttesttesttesttest';
  final salt = crypto.randombytes.buf(crypto.pwhash.saltBytes);
  final pwChars = password.toCharArray();

  print('hashing...');
  final timer = Stopwatch()..start();
  final hashedPw = crypto.pwhash(
    64,
    pwChars,
    salt,
    crypto.pwhash.opsLimitInteractive,
    crypto.pwhash.memLimitInteractive,
    CrypoPwhashAlgorithm.defaultAlg,
  );
  timer.stop();
  print('Done after ${timer.elapsed}');

  final extracted = hashedPw.extractBytes();
  hashedPw.dispose();
  return extracted;
}
