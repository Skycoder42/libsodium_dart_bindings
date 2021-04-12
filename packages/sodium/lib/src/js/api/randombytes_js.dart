import 'dart:typed_data';

import '../../api/randombytes.dart';
import '../bindings/sodium.js.dart';

class RandombytesJS implements Randombytes {
  final LibSodiumJS sodium;

  RandombytesJS(this.sodium);

  @override
  int get seedBytes => sodium.randombytes_seedbytes();

  @override
  int random() => sodium.randombytes_random();

  @override
  int uniform(int upperBound) => sodium.randombytes_uniform(upperBound);

  @override
  Uint8List buf(int length) => sodium.randombytes_buf(length);

  @override
  Uint8List bufDeterministic(int length, Uint8List seed) {
    RangeError.checkValueInInterval(seed.length, seedBytes, seedBytes, 'seed');
    return sodium.randombytes_buf_deterministic(length, seed);
  }

  @override
  void close() => sodium.randombytes_close();

  @override
  void stir() => sodium.randombytes_stir();
}
