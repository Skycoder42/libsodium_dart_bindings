import 'dart:async';
import 'dart:typed_data';

import '../../api/secure_key.dart';
import '../bindings/sodium.js.dart';

class SecureKeyJs implements SecureKey {
  final LibSodiumJS sodium;
  final Uint8List _raw;

  SecureKeyJs(this.sodium, this._raw);

  factory SecureKeyJs.alloc(LibSodiumJS sodium, int length) =>
      SecureKeyJs(sodium, Uint8List(length));

  factory SecureKeyJs.random(LibSodiumJS sodium, int length) => SecureKeyJs(
        sodium,
        sodium.randombytes_buf(length),
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
    sodium.memzero(_raw);
  }
}
