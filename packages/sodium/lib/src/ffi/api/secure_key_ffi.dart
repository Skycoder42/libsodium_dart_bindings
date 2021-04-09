import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import '../../api/secure_key.dart';

import '../bindings/libsodium.ffi.dart';
import '../bindings/sodium_pointer.dart';

typedef SecureFFICallbackFn<T> = T Function(SodiumPointer<Uint8> pointer);

class SecureKeyFFI implements SecureKey {
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

  T runUnlockedRaw<T>(
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
      runUnlockedRaw(
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
  Uint8List extractBytes() => runUnlockedRaw((pointer) => pointer.copyAsList());

  @override
  void dispose() {
    _raw.dispose();
  }
}
