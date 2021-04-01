import 'dart:typed_data';

import 'package:libsodium_dart_bindings/src/api/randombytes.dart';
import 'package:libsodium_dart_bindings/src/js/bindings/num_x.dart';
import 'package:libsodium_dart_bindings/src/js/bindings/node_modules/@types/libsodium-wrappers.dart';

class RandombytesJS implements Randombytes {
  @override
  int get seedBytes => 32; // not exported from libsodium-wrappers

  @override
  int random() => randombytes_random().toSafeInt();

  @override
  int uniform(int upperBound) => randombytes_uniform(upperBound).toSafeInt();

  @override
  Uint8List buf(int size) => randombytes_buf(size, 'uint8array') as Uint8List;

  @override
  Uint8List bufDeterministic(int size, Uint8List seed) =>
      randombytes_buf_deterministic(size, seed, 'uint8array') as Uint8List;

  @override
  void close() => randombytes_close();

  @override
  void stir() => randombytes_stir();
}
