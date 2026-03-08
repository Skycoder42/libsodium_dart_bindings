import 'dart:io';
import 'dart:typed_data';

import 'package:sodium/sodium_sumo.dart';

class CryptoService {
  final Sodium _sodium;

  SecureKey _secretKey;

  CryptoService(this._sodium) : _secretKey = _sodium.crypto.secretBox.keygen();

  SodiumVersion get version => _sodium.version;

  SecureKey get secretKey => _secretKey;

  void dispose() {
    _secretKey.dispose();
  }

  Uint8List encryptSample(String message) {
    final plainTextBytes = message.toCharArray().unsignedView();
    final nonce = _sodium.randombytes.buf(_sodium.crypto.secretBox.nonceBytes);
    final cipherText = _sodium.crypto.secretBox.easy(
      message: plainTextBytes,
      nonce: nonce,
      key: _secretKey,
    );
    var buffer = BytesBuilder(copy: false)
      ..add(nonce)
      ..add(cipherText);
    return buffer.takeBytes();
  }

  String decryptSample(Uint8List nonceWithCipher) {
    var nonce = Uint8List.sublistView(
      nonceWithCipher,
      0,
      _sodium.crypto.secretBox.nonceBytes,
    );
    var cipher = Uint8List.sublistView(
      nonceWithCipher,
      _sodium.crypto.secretBox.nonceBytes,
    );

    final plainText = _sodium.crypto.secretBox.openEasy(
      cipherText: cipher,
      nonce: nonce,
      key: _secretKey,
    );
    return plainText.signedView().toDartString();
  }

  Future<String> encryptFileInChunks(
    String filePath, [
    int chunkSize = 4096,
  ]) async {
    final plainFile = File(filePath);
    final cipherFile = File("$filePath.cipher");
    await _sodium.crypto.secretStream
        .pushChunked(
          messageStream: plainFile.openRead(),
          key: _secretKey,
          chunkSize: chunkSize,
        )
        .pipe(cipherFile.openWrite());
    return cipherFile.path;
  }

  Future<String> decryptFileInChunks(
    String filePath, [
    int chunkSize = 4096,
  ]) async {
    final cipherFile = File(filePath);
    final plainFile = File("$filePath.plain");
    await _sodium.crypto.secretStream
        .pullChunked(
          cipherStream: cipherFile.openRead(),
          key: _secretKey,
          chunkSize: chunkSize,
        )
        .pipe(plainFile.openWrite());
    return plainFile.path;
  }

  Uint8List generateSalt() {
    if (_sodium is! SodiumSumo) {
      throw UnsupportedError(
        "Password hashing is only supported with the sumo variant of libsodium!",
      );
    }

    return _sodium.randombytes.buf(_sodium.crypto.pwhash.saltBytes);
  }

  Future<void> deriveNewKey(String password, Uint8List salt) async {
    // copy to variable to ensure this is not sent to isolate
    final sodium = _sodium;
    if (sodium is! SodiumSumo) {
      throw UnsupportedError(
        "Password hashing is only supported with the sumo variant of libsodium!",
      );
    }

    final newKey = await _sodium.runIsolated(
      (_, _) => sodium.crypto.pwhash(
        outLen: sodium.crypto.secretBox.keyBytes,
        password: password.toCharArray(),
        salt: salt,
        opsLimit: sodium.crypto.pwhash.opsLimitSensitive,
        memLimit: sodium.crypto.pwhash.memLimitSensitive,
      ),
    );

    _secretKey.dispose();
    _secretKey = newKey;
  }
}
