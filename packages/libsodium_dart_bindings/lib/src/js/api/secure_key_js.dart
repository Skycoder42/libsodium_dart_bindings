import 'dart:async';
import 'dart:typed_data';

import 'package:libsodium_dart_bindings/src/api/secure_key.dart';
import 'package:libsodium_dart_bindings/src/js/node_modules/@types/libsodium-wrappers.dart';

class SecureKeyJs implements SecureKey {
  final Uint8List _raw;

  SecureKeyJs(this._raw);

  factory SecureKeyJs.alloc(int length) => SecureKeyJs(Uint8List(length));

  factory SecureKeyJs.random(int length) =>
      SecureKeyJs(randombytes_buf(length, 'Uint8Array') as Uint8List);

  @override
  T runUnlockedSync<T>(SecureCallbackFn<T> callback) => callback(_raw);

  @override
  FutureOr<T> runUnlockedAsync<T>(SecureCallbackFn<FutureOr<T>> callback) =>
      callback(_raw);

  @override
  Uint8List extractBytes() => _raw;

  @override
  void dispose() {
    memzero(_raw);
  }
}
