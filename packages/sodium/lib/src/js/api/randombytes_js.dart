import 'dart:typed_data';

import '../../api/randombytes.dart';
import '../bindings/sodium.js.dart';
import '../bindings/to_safe_int.dart';

class RandombytesJS implements Randombytes {
  final LibSodiumJS sodium;

  RandombytesJS(this.sodium);

  @override
  int get seedBytes {
    // TODO WORKAROUND for missing definitions
    final result = (sodium as dynamic).randombytes_seedbytes() as num;
    return result.toSafeInt();
  }

  @override
  int random() => sodium.randombytes_random().toSafeInt();

  @override
  int uniform(int upperBound) =>
      sodium.randombytes_uniform(upperBound).toSafeInt();

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
