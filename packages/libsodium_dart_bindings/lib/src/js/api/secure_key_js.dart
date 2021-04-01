import 'dart:async';
import 'dart:js';
import 'dart:typed_data';

import 'package:libsodium_dart_bindings/src/api/secure_key.dart';

class SecureKeyJs implements SecureKey {
  final JsObject sodium;
  final Uint8List _raw;

  SecureKeyJs(this.sodium, this._raw);

  factory SecureKeyJs.alloc(JsObject sodium, int length) =>
      SecureKeyJs(sodium, Uint8List(length));

  factory SecureKeyJs.random(JsObject sodium, int length) => SecureKeyJs(
        sodium,
        sodium.callMethod('randombytes_buf', <dynamic>[
          length,
          'uint8array',
        ]) as Uint8List,
      );

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
    sodium.callMethod('memzero', <dynamic>[_raw]);
  }
}
