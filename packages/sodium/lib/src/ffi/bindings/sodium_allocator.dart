import 'dart:ffi';

import 'libsodium.ffi.wrapper.dart';
import 'memory_protection.dart';

/// An [Allocator] using the libsodium memory functionality.
///
/// See https://libsodium.gitbook.io/doc/memory_management
class SodiumAllocator implements Allocator {
  /// The [LibSodiumFFI] instance used by this allocator.
  final LibSodiumFFI sodium;

  /// Default constructor
  const SodiumAllocator(this.sodium);

  /// Provides sodium_malloc.
  ///
  /// See https://libsodium.gitbook.io/doc/memory_management#guarded-heap-allocations
  @override
  Pointer<T> allocate<T extends NativeType>(int byteCount, {int? alignment}) {
    if (alignment != null) {
      throw ArgumentError('Cannot align memory when using SodiumAllocator');
    }

    return sodium.sodium_malloc(byteCount).cast();
  }

  /// Provides sodium_free.
  ///
  /// See https://libsodium.gitbook.io/doc/memory_management#guarded-heap-allocations
  @override
  void free(Pointer<NativeType> pointer) {
    sodium.sodium_free(pointer.cast());
  }

  /// Provides sodium_memzero.
  ///
  /// See https://libsodium.gitbook.io/doc/memory_management#zeroing-memory
  void memzero(Pointer<NativeType> pointer, int byteCount) {
    sodium.sodium_memzero(pointer.cast(), byteCount);
  }

  /// Provides sodium_mlock.
  ///
  /// See https://libsodium.gitbook.io/doc/memory_management#locking-memory
  bool lock(Pointer<NativeType> pointer, int byteCount) =>
      sodium.sodium_mlock(pointer.cast(), byteCount) == 0;

  /// Provides sodium_munlock.
  ///
  /// See https://libsodium.gitbook.io/doc/memory_management#locking-memory
  bool unlock(Pointer<NativeType> pointer, int byteCount) =>
      sodium.sodium_munlock(pointer.cast(), byteCount) == 0;

  /// Provides sodium_mprotect_*.
  ///
  /// Depending on the [memoryProtection] argument, the corresponding mprotect
  /// function will be used.
  ///
  /// See https://libsodium.gitbook.io/doc/memory_management#guarded-heap-allocations
  bool memoryProtect(
    Pointer<NativeType> pointer,
    MemoryProtection memoryProtection,
  ) {
    int result;
    switch (memoryProtection) {
      case MemoryProtection.noAccess:
        result = sodium.sodium_mprotect_noaccess(pointer.cast());
      case MemoryProtection.readOnly:
        result = sodium.sodium_mprotect_readonly(pointer.cast());
      case MemoryProtection.readWrite:
        result = sodium.sodium_mprotect_readwrite(pointer.cast());
    }
    return result == 0;
  }
}
