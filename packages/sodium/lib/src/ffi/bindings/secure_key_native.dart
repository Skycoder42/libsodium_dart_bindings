import 'dart:ffi';

import 'package:meta/meta.dart';

import '../../api/secure_key.dart';
import 'libsodium.ffi.dart';
import 'memory_protection.dart';
import 'sodium_pointer.dart';

/// @nodoc
@internal
typedef SecureFFICallbackFn<T> = T Function(SodiumPointer<Uint8> keyPtr);

/// @nodoc
@internal
typedef SecureFFINullableCallbackFn<T> = T Function(
  SodiumPointer<Uint8>? keyPtr,
);

/// @nodoc
@internal
abstract class SecureKeyNative implements SecureKey {
  const SecureKeyNative._(); // coverage:ignore-line

  T runUnlockedNative<T>(
    SecureFFICallbackFn<T> callback, {
    bool writable = false,
  });
}

/// @nodoc
@internal
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
              data.setRange(0, data.length, ptr.asList());
            }
            return result;
          } finally {
            ptr.dispose();
          }
        },
        writable: writable,
      );
}

/// @nodoc
@internal
extension SecureKeyNullableSafeCastX on SecureKey? {
  T runMaybeUnlockedNative<T>(
    LibSodiumFFI sodium,
    SecureFFINullableCallbackFn<T> callback,
  ) =>
      this != null ? this!.runUnlockedNative(sodium, callback) : callback(null);
}
