import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart';

/// @nodoc
@internal
class SecureKeyJS with SecureKeyEquality implements SecureKey {
  /// @nodoc
  final LibSodiumJS sodium;
  final JSUint8Array _raw;

  /// @nodoc
  SecureKeyJS(this.sodium, this._raw);

  /// @nodoc
  factory SecureKeyJS.alloc(LibSodiumJS sodium, int length) =>
      SecureKeyJS(sodium, Uint8List(length).toJS);

  /// @nodoc
  factory SecureKeyJS.random(LibSodiumJS sodium, int length) => SecureKeyJS(
        sodium,
        jsErrorWrap(() => sodium.randombytes_buf(length)),
      );

  @override
  int get length => _raw.toDart.length;

  @override
  T runUnlockedSync<T>(
    SecureCallbackFn<T> callback, {
    bool writable = false,
  }) =>
      callback(_raw.toDart);

  @override
  FutureOr<T> runUnlockedAsync<T>(
    SecureCallbackFn<FutureOr<T>> callback, {
    bool writable = false,
  }) =>
      callback(_raw.toDart);

  @override
  Uint8List extractBytes() => Uint8List.fromList(_raw.toDart);

  @override
  SecureKey copy() => SecureKeyJS(sodium, extractBytes().toJS);

  @override
  void dispose() {
    jsErrorWrap(() => sodium.memzero(_raw));
  }
}
