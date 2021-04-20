import 'dart:ffi';

import '../../api/secure_key.dart';
import 'libsodium.ffi.dart';
import 'sodium_pointer.dart';

typedef SecureFFICallbackFn<T> = T Function(SodiumPointer<Uint8> pointer);

abstract class SecureKeyNative implements SecureKey {
  const SecureKeyNative._(); // coverage:ignore-line

  T runUnlockedNative<T>(
    SecureFFICallbackFn<T> callback, {
    bool writable = false,
  });
}

extension SecureKeySafeCastX on SecureKey {
  T runUnlockedNative<T>(
    LibSodiumFFI sodium,
    SecureFFICallbackFn<T> callback, {
    bool writable = false,
  }) {
    if (this is SecureKeyNative) {
      return (this as SecureKeyNative).runUnlockedNative(
        callback,
        writable: writable,
      );
    } else {
      return _runUnlockedRawWrapped(sodium, callback, writable: writable);
    }
  }

  T _runUnlockedRawWrapped<T>(
    LibSodiumFFI sodium,
    SecureFFICallbackFn<T> callback, {
    bool writable = false,
  }) =>
      runUnlockedSync(
        (data) {
          final ptr = data.toSodiumPointer(
            sodium,
            memoryProtection: writable
                ? MemoryProtection.readWrite
                : MemoryProtection.readOnly,
          );
          try {
            final result = callback(ptr);
            if (writable) {
              data.setAll(0, ptr.asList());
            }
            return result;
          } finally {
            ptr.dispose();
          }
        },
        writable: writable,
      );
}
