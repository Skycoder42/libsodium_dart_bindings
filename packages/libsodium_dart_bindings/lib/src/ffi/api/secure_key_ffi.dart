import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import '../../api/secure_key.dart';

import '../bindings/sodium.ffi.dart';
import '../bindings/sodium_pointer.dart';

typedef SecureFFICallbackFn<T> = T Function(SodiumPointer<Uint8> pointer);

class SecureKeyFFI implements SecureKey {
  final SodiumPointer<Uint8> _raw;

  SecureKeyFFI(this._raw) {
    _raw
      ..locked = true
      ..memoryProtection = MemoryProtection.noAccess;
  }

  factory SecureKeyFFI.alloc(SodiumFFI sodium, int length) =>
      SecureKeyFFI(SodiumPointer<Uint8>.alloc(sodium, length));

  factory SecureKeyFFI.random(SodiumFFI sodium, int length) =>
      SecureKeyFFI(SodiumPointer<Uint8>.random(sodium, length));

  T runUnlockedRaw<T>(SecureFFICallbackFn<T> callback) {
    try {
      _raw.memoryProtection = MemoryProtection.readOnly;
      return callback(_raw);
    } finally {
      _raw.memoryProtection = MemoryProtection.noAccess;
    }
  }

  @override
  T runUnlockedSync<T>(SecureCallbackFn<T> callback) =>
      runUnlockedRaw((pointer) => callback(pointer.asList()));

  @override
  FutureOr<T> runUnlockedAsync<T>(
    SecureCallbackFn<FutureOr<T>> callback,
  ) async {
    try {
      _raw.memoryProtection = MemoryProtection.readOnly;
      return await callback(_raw.asList());
    } finally {
      _raw.memoryProtection = MemoryProtection.noAccess;
    }
  }

  @override
  Uint8List extractBytes() {
    try {
      _raw.memoryProtection = MemoryProtection.readOnly;
      return _raw.copyAsList();
    } finally {
      _raw.memoryProtection = MemoryProtection.noAccess;
    }
  }

  @override
  void dispose() {
    _raw.dispose();
  }
}
