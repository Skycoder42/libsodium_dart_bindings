import 'dart:async';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/secure_key.dart';
import '../bindings/libsodium.ffi.dart';
import '../bindings/memory_protection.dart';
import '../bindings/secure_key_native.dart';
import '../bindings/sodium_pointer.dart';

/// @nodoc
@internal
typedef SecureFFICallbackFn<T> = T Function(
  SodiumPointer<UnsignedChar> pointer,
);

/// @nodoc
@internal
typedef SecureKeyFFINativeHandle = List<int>;

/// @nodoc
@internal
class SecureKeyFFI with SecureKeyEquality implements SecureKeyNative {
  final SodiumPointer<UnsignedChar> _raw;

  /// @nodoc
  SecureKeyFFI(this._raw) {
    _raw
      ..locked = true
      ..memoryProtection = MemoryProtection.noAccess;
  }

  /// @nodoc
  factory SecureKeyFFI.alloc(LibSodiumFFI sodium, int length) => SecureKeyFFI(
        SodiumPointer<UnsignedChar>.alloc(
          sodium,
          count: length,
          memoryProtection: MemoryProtection.noAccess,
        ),
      );

  /// @nodoc
  factory SecureKeyFFI.random(LibSodiumFFI sodium, int length) {
    final raw = SodiumPointer<UnsignedChar>.alloc(sodium, count: length);
    try {
      sodium.randombytes_buf(raw.ptr.cast(), raw.byteLength);
      return SecureKeyFFI(raw);
    } catch (e) {
      raw.dispose();
      rethrow;
    }
  }

  /// @nodoc
  @internal
  factory SecureKeyFFI.attach(
    LibSodiumFFI sodium,
    SecureKeyFFINativeHandle nativeHandle,
  ) {
    if (nativeHandle.length != 2) {
      throw ArgumentError.value(
        nativeHandle,
        'nativeHandle',
        'Must be two integers',
      );
    }

    return SecureKeyFFI(
      SodiumPointer.raw(
        sodium,
        Pointer.fromAddress(nativeHandle[0]),
        nativeHandle[1],
      ),
    );
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
        (pointer) => callback(pointer.asListView() as Uint8List),
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
      return await callback(_raw.asListView() as Uint8List);
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

  /// @nodoc
  @internal
  SecureKeyFFINativeHandle detach() => [_raw.detach().address, _raw.count];
}
