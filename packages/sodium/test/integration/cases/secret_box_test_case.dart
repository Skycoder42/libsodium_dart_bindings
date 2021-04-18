import 'dart:typed_data';

import 'package:sodium/sodium.dart';
import 'package:test/test.dart';

import '../test_case.dart';

class SecretBoxTestCase extends TestCase {
  @override
  String get name => 'secretbox';

  SecretBox get sut => sodium.crypto.secretBox;

  @override
  void setupTests() {
    test('easy quick test', () {
      final key = sut.keygen();
      final message =
          Uint8List.fromList(List.generate(32, (index) => index * 2));
      final nonce = sodium.randombytes.buf(sut.nonceBytes);

      // ignore: avoid_print
      print(message);
      final ciphertext = sut.easy(
        message: message,
        nonce: nonce,
        key: key,
      );
      // ignore: avoid_print
      print(ciphertext);
      final restored = sut.openEasy(
        ciphertext: ciphertext,
        nonce: nonce,
        key: key,
      );
      // ignore: avoid_print
      print(restored);
    });
  }
}
