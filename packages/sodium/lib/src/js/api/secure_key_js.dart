import 'dart:async';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart';

@internal
class SecureKeyJS with SecureKeyEquality implements SecureKey {
  final LibSodiumJS sodium;
  final Uint8List _raw;

  SecureKeyJS(this.sodium, this._raw);

  factory SecureKeyJS.alloc(LibSodiumJS sodium, int length) =>
      SecureKeyJS(sodium, Uint8List(length));

  factory SecureKeyJS.random(LibSodiumJS sodium, int length) => SecureKeyJS(
        sodium,
        JsError.wrap(() => sodium.randombytes_buf(length)),
      );

  @override
  int get length => _raw.length;

  @override
  T runUnlockedSync<T>(
    SecureCallbackFn<T> callback, {
    bool writable = false,
  }) =>
      callback(_raw);

  @override
  FutureOr<T> runUnlockedAsync<T>(
    SecureCallbackFn<FutureOr<T>> callback, {
    bool writable = false,
  }) =>
      callback(_raw);

  @override
  Uint8List extractBytes() => Uint8List.fromList(_raw);

  @override
  void dispose() {
    JsError.wrap(() => sodium.memzero(_raw));
  }
}
