import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'sodium.ffi.dart';
import 'sodium_pointer.dart';

class SecureKey {
  final SodiumPointer<Uint8> raw;

  SecureKey(this.raw) {
    raw
      ..locked = true
      ..memoryProtection = MemoryProtection.noAccess;
  }

  factory SecureKey.alloc(SodiumFFI sodium, int length) =>
      SecureKey(SodiumPointer<Uint8>.alloc(sodium, length));

  factory SecureKey.random(SodiumFFI sodium, int length) =>
      SecureKey(SodiumPointer<Uint8>.random(sodium, length));

  T runUnlockedSync<T>(
    T Function(SodiumPointer<Uint8>) callback,
  ) {
    try {
      raw.memoryProtection = MemoryProtection.readOnly;
      return callback(raw);
    } finally {
      raw.memoryProtection = MemoryProtection.noAccess;
    }
  }

  Future<T> runUnlockedAsync<T>(
    FutureOr<T> Function(SodiumPointer<Uint8>) callback,
  ) async {
    try {
      raw.memoryProtection = MemoryProtection.readOnly;
      return await callback(raw);
    } finally {
      raw.memoryProtection = MemoryProtection.noAccess;
    }
  }

  Uint8List extractBytes() {
    try {
      raw.memoryProtection = MemoryProtection.readOnly;
      return raw.copyAsList();
    } finally {
      raw.memoryProtection = MemoryProtection.noAccess;
    }
  }

  void dispose() {
    raw.dispose();
  }
}
