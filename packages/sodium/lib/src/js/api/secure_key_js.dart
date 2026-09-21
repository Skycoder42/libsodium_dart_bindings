import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/secure_key.dart';
import '../bindings/js_error.dart';
import '../bindings/sodium.js.dart';
import '../bindings/sodium_finalizer.dart';

@internal
class SecureKeyJS(final LibSodiumJS sodium, final JSUint8Array _raw)
    with SecureKeyEquality
    implements SecureKey {
  static final _sodiumFinalizerCache = Expando<SodiumFinalizer>();

  static SodiumFinalizer _getFinalizer(LibSodiumJS sodium) =>
      _sodiumFinalizerCache[sodium] ??= SodiumFinalizer(sodium);

  @visibleForTesting
  static void debugOverwriteFinalizer(
    LibSodiumJS sodium,
    SodiumFinalizer finalizer,
  ) => _sodiumFinalizerCache[sodium] = finalizer;

  this {
    _getFinalizer(sodium).attach(this, _raw);
  }

  factory alloc(LibSodiumJS sodium, int length) =>
      SecureKeyJS(sodium, Uint8List(length).toJS);

  factory random(LibSodiumJS sodium, int length) =>
      SecureKeyJS(sodium, jsErrorWrap(() => sodium.randombytes_buf(length)));

  @override
  int get length => _raw.toDart.length;

  @override
  T runUnlockedSync<T>(SecureCallbackFn<T> callback, {bool writable = false}) =>
      callback(_raw.toDart);

  @override
  FutureOr<T> runUnlockedAsync<T>(
    SecureCallbackFn<FutureOr<T>> callback, {
    bool writable = false,
  }) => callback(_raw.toDart);

  @override
  Uint8List extractBytes() => Uint8List.fromList(_raw.toDart);

  @override
  SecureKey copy() => SecureKeyJS(sodium, extractBytes().toJS);

  @override
  void dispose() {
    _getFinalizer(sodium).detach(this);
    jsErrorWrap(() => sodium.memzero(_raw));
  }
}
