import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/secure_key.dart';
import '../bindings/libsodium.ffi.dart';
import '../bindings/secure_key_native.dart';
import '../bindings/sodium_pointer.dart';

@internal
typedef SecureFFICallbackFn<T> = T Function(SodiumPointer<Uint8> pointer);

@internal
class SecureKeyFFI with SecureKeyEquality implements SecureKeyNative {
  final SodiumPointer<Uint8> _raw;

  SecureKeyFFI(this._raw) {
    _raw
      ..locked = true
      ..memoryProtection = MemoryProtection.noAccess;
  }

  factory SecureKeyFFI.alloc(LibSodiumFFI sodium, int length) =>
      SecureKeyFFI(SodiumPointer<Uint8>.alloc(
        sodium,
        count: length,
      ));

  factory SecureKeyFFI.random(LibSodiumFFI sodium, int length) {
    final raw = SodiumPointer<Uint8>.alloc(sodium, count: length);
    try {
      sodium.randombytes_buf(raw.ptr.cast(), raw.byteLength);
      return SecureKeyFFI(raw);
    } catch (e) {
      raw.dispose();
      rethrow;
    }
  }

  @override
  int get length => _raw.count;

  @override
  T runUnlockedNative<T>(
    SecureFFICallbackFn<T> callback, {
    bool writable = false,
  }) {
    try {
      _raw.memoryProtection =
          writable ? MemoryProtection.readWrite : MemoryProtection.readOnly;
      return callback(_raw);
    } finally {
      _raw.memoryProtection = MemoryProtection.noAccess;
    }
  }

  @override
  T runUnlockedSync<T>(
    SecureCallbackFn<T> callback, {
    bool writable = false,
  }) =>
      runUnlockedNative(
        (pointer) => callback(pointer.asList()),
        writable: writable,
      );

  @override
  FutureOr<T> runUnlockedAsync<T>(
    SecureCallbackFn<FutureOr<T>> callback, {
    bool writable = false,
  }) async {
    try {
      _raw.memoryProtection =
          writable ? MemoryProtection.readWrite : MemoryProtection.readOnly;
      return await callback(_raw.asList());
    } finally {
      _raw.memoryProtection = MemoryProtection.noAccess;
    }
  }

  @override
  Uint8List extractBytes() =>
      runUnlockedNative((pointer) => pointer.copyAsList());

  @override
  SecureKey copy() {
    final keyCopy = SecureKeyFFI.alloc(_raw.sodium, length);
    try {
      runUnlockedNative(
        (originalPointer) => keyCopy.runUnlockedNative(
          (copyPointer) => copyPointer.fill(originalPointer.asList()),
          writable: true,
        ),
      );
      return keyCopy;
    } catch (e) {
      keyCopy.dispose();
      rethrow;
    }
  }

  @override
  void dispose() {
    _raw.dispose();
  }
}
