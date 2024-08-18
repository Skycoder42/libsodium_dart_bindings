// ignore_for_file: avoid_print, public_member_api_docs
import 'dart:io';
import 'dart:typed_data';

import 'package:sodium/sodium.dart';

Uint8List runSample(Sodium sodium, String message) {
  print('libsodium version: ${sodium.version}');

  final plainTextBytes = message.toCharArray().unsignedView();
  final nonce = sodium.randombytes.buf(sodium.crypto.secretBox.nonceBytes);

  final secretKey = sodium.crypto.secretBox.keygen();
  try {
    print('encrypting...');
    final timer = Stopwatch()..start();
    final cipherText = sodium.crypto.secretBox.easy(
      message: plainTextBytes,
      nonce: nonce,
      key: secretKey,
    );
    timer.stop();
    print('Done after ${timer.elapsed}');

    return cipherText;
  } finally {
    secretKey.dispose();
  }
}

Future<void> simpleFileEncryption(
  Sodium sodium,
  String plain,
  String cipher,
) async {
  const chunkSize = 4096;
  final secretKey = sodium.crypto.secretStream.keygen();

  // encryption
  await sodium.crypto.secretStream
      .pushChunked(
        messageStream: File(plain).openRead(),
        key: secretKey,
        chunkSize: chunkSize,
      )
      .pipe(
        File(cipher).openWrite(),
      );

  // decryption
  await sodium.crypto.secretStream
      .pullChunked(
        cipherStream: File(cipher).openRead(),
        key: secretKey,
        chunkSize: chunkSize,
      )
      .pipe(
        File(plain).openWrite(),
      );
}
