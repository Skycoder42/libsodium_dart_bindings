import 'dart:js';
import 'dart:typed_data';

import 'package:libsodium_dart_bindings/src/api/randombytes.dart';
import 'package:libsodium_dart_bindings/src/js/bindings/num_x.dart';

class RandombytesJS implements Randombytes {
  final JsObject sodium;

  RandombytesJS(this.sodium);

  @override
  int get seedBytes => 32; // not exported from libsodium-wrappers

  @override
  int random() => (sodium.callMethod('randombytes_random') as num).toSafeInt();

  @override
  int uniform(int upperBound) => (sodium.callMethod(
        'randombytes_random',
        <dynamic>[upperBound],
      ) as num)
          .toSafeInt();

  @override
  Uint8List buf(int size) => sodium.callMethod(
        'randombytes_buf',
        <dynamic>[size, 'uint8array'],
      ) as Uint8List;

  @override
  Uint8List bufDeterministic(int size, Uint8List seed) => sodium.callMethod(
        'randombytes_buf_deterministic',
        <dynamic>[size, seed, 'uint8array'],
      ) as Uint8List;

  @override
  void close() => sodium.callMethod('randombytes_close');

  @override
  void stir() => sodium.callMethod('randombytes_stir');
}
