// coverage:ignore-file

import 'dart:js_interop';

import 'package:meta/meta.dart';

import 'js_error.dart';
import 'sodium.js.dart';

@internal
// ignore: public_member_api_docs false positive
class SodiumFinalizer(LibSodiumJS sodium) {
  final _finalizer = Finalizer<JSUint8Array>(
    (v) => jsErrorWrap(() => sodium.memzero(v)),
  );

  void attach(Object value, JSUint8Array token) =>
      _finalizer.attach(value, token, detach: value);

  void detach(Object detach) => _finalizer.detach(detach);
}
