import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/randombytes.dart';
import '../bindings/sodium.js.dart';
import '../bindings/to_safe_int.dart';

@internal
class RandombytesJS implements Randombytes {
  final LibSodiumJS sodium;

  RandombytesJS(this.sodium);

  // Not exported in JS library
  @override
  int get seedBytes => 32;

  @override
  int random() => sodium.randombytes_random().toSafeUInt32();

  @override
  int uniform(int upperBound) =>
      sodium.randombytes_uniform(upperBound).toSafeUInt32();

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
