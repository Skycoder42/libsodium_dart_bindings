// coverage:ignore-file

import 'dart:js_interop';

import 'package:meta/meta.dart';

import 'js_error.dart';
import 'sodium.js.dart';

/// @nodoc
@internal
class SodiumFinalizer {
  final Finalizer<JSUint8Array> _finalizer;

  /// @nodoc
  SodiumFinalizer(LibSodiumJS sodium)
    : _finalizer = Finalizer((v) => jsErrorWrap(() => sodium.memzero(v)));

  /// @nodoc
  void attach(Object value, JSUint8Array token) =>
      _finalizer.attach(value, token, detach: value);

  /// @nodoc
  void detach(Object detach) => _finalizer.detach(detach);
}
