// ignore_for_file: unnecessary_lambdas

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/helpers/validations.dart';
import '../../api/randombytes.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart';

/// @nodoc
@internal
class RandombytesJS implements Randombytes {
  /// @nodoc
  final LibSodiumJS sodium;

  /// @nodoc
  RandombytesJS(this.sodium);

  // Not exported in JS library
  @override
  int get seedBytes => 32;

  @override
  int random() => jsErrorWrap(
        () => sodium.randombytes_random(),
      );

  @override
  int uniform(int upperBound) => jsErrorWrap(
        () => sodium.randombytes_uniform(upperBound),
      );

  @override
  Uint8List buf(int length) => jsErrorWrap(
        () => sodium.randombytes_buf(length).toDart,
      );

  @override
  Uint8List bufDeterministic(int length, Uint8List seed) {
    Validations.checkIsSame(seed.length, seedBytes, 'seed');

    return jsErrorWrap(
      () => sodium.randombytes_buf_deterministic(length, seed.toJS).toDart,
    );
  }

  @override
  void close() => jsErrorWrap(
        () => sodium.randombytes_close(),
      );

  @override
  void stir() => jsErrorWrap(
        () => sodium.randombytes_stir(),
      );
}
