import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/secure_key.dart';
import '../bindings/libsodium.ffi.wrapper.dart';
import '../bindings/memory_protection.dart';
import '../bindings/secure_key_native.dart';
import '../bindings/sodium_pointer.dart';
import '../bindings/sodium_scope.dart';

@internal
typedef SecureFFICallbackFn<T> = T Function(
  SodiumPointer<UnsignedChar> pointer,
);

@internal
typedef SecureKeyFFINativeHandle = (int address, int count);

@internal
class SecureKeyFFI(final SodiumPointer<UnsignedChar> _raw)
    with SecureKeyEquality
    implements SecureKeyNative {
  this {
    _raw
      ..locked = true
      ..memoryProtection = MemoryProtection.noAccess;
  }

  factory alloc(LibSodiumFFI sodium, int length) => SecureKeyFFI(
    SodiumPointer<UnsignedChar>.alloc(
      sodium,
      count: length,
      memoryProtection: MemoryProtection.noAccess,
    ),
  );

  factory random(LibSodiumFFI sodium, int length) =>
      sodiumScope(sodium, (scope) {
        final raw = scope.alloc<UnsignedChar>(length);
        sodium.randombytes_buf(raw.ptr.cast(), raw.byteLength);
        return SecureKeyFFI(scope.takePointer(raw));
      });

  @internal
  factory attach(LibSodiumFFI sodium, SecureKeyFFINativeHandle nativeHandle) =>
      SecureKeyFFI(
        SodiumPointer.raw(
          sodium,
          Pointer.fromAddress(nativeHandle.$1),
          nativeHandle.$2,
        ),
      );

  @override
  int get length => _raw.count;

  @override
  T runUnlockedNative<T>(
    SecureFFICallbackFn<T> callback, {
    bool writable = false,
  }) {
    try {
      _raw.memoryProtection = writable
          ? MemoryProtection.readWrite
          : MemoryProtection.readOnly;
      return callback(_raw);
    } finally {
      _raw.memoryProtection = MemoryProtection.noAccess;
    }
  }

  @override
  T runUnlockedSync<T>(SecureCallbackFn<T> callback, {bool writable = false}) =>
      runUnlockedNative(
        (pointer) => callback(pointer.asListView()),
        writable: writable,
      );

  @override
  FutureOr<T> runUnlockedAsync<T>(
    SecureCallbackFn<FutureOr<T>> callback, {
    bool writable = false,
  }) async {
    try {
      _raw.memoryProtection = writable
          ? MemoryProtection.readWrite
          : MemoryProtection.readOnly;
      return await callback(_raw.asListView());
    } finally {
      _raw.memoryProtection = MemoryProtection.noAccess;
    }
  }

  @override
  Uint8List extractBytes() =>
      runUnlockedNative((pointer) => Uint8List.fromList(pointer.asListView()));

  @override
  SecureKeyFFI copy() => runUnlockedNative(
    (originalPointer) => SecureKeyFFI(
      originalPointer.asListView().toSodiumPointer(
        _raw.sodium,
        memoryProtection: MemoryProtection.noAccess,
      ),
    ),
  );

  @override
  void dispose() {
    _raw.dispose();
  }

  @internal
  @useResult
  SecureKeyFFINativeHandle detach() => (_raw.detach().address, _raw.count);
}
