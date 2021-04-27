import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/helpers/validations.dart';
import '../../api/randombytes.dart';
import '../bindings/js_error.dart';
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
  int random() => JsError.wrap(
        () => sodium.randombytes_random().toSafeUInt32(),
      );

  @override
  int uniform(int upperBound) => JsError.wrap(
        () => sodium.randombytes_uniform(upperBound).toSafeUInt32(),
      );

  @override
  Uint8List buf(int length) => JsError.wrap(
        () => sodium.randombytes_buf(length),
      );

  @override
  Uint8List bufDeterministic(int length, Uint8List seed) {
    Validations.checkIsSame(seed.length, seedBytes, 'seed');

    return JsError.wrap(
      () => sodium.randombytes_buf_deterministic(length, seed),
    );
  }

  @override
  void close() => JsError.wrap(
        () => sodium.randombytes_close(),
      );

  @override
  void stir() => JsError.wrap(
        () => sodium.randombytes_stir(),
      );
}
