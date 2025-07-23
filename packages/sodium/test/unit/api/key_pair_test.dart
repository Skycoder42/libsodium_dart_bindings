import 'dart:typed_data';

import 'package:sodium/src/api/key_pair.dart';
import 'package:test/test.dart';

import '../../secure_key_fake.dart';

void main() {
  group('$KeyPair', () {
    late KeyPair sut;

    setUp(() {
      sut = KeyPair(
        publicKey: Uint8List.fromList(List.generate(20, (index) => index)),
        secretKey: SecureKeyFake(List.filled(10, 10)),
      );
    });

    test('copy creates copy of secret key', () {
      final copy = sut.copy();

      expect(copy.publicKey, sut.publicKey);
      expect(copy.secretKey, sut.secretKey);
      expect(copy.publicKey, isNot(same(sut.publicKey)));
      expect(copy.secretKey, isNot(same(sut.secretKey)));
    });

    test('dispose disposes the secret key', () {
      sut.dispose();
      expect((sut.secretKey as SecureKeyFake).disposed, isTrue);
    });
  });
}
