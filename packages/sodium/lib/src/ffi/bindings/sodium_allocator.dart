import 'dart:ffi';

import 'libsodium.ffi.dart';

class SodiumAllocator implements Allocator {
  final LibSodiumFFI sodium;

  const SodiumAllocator(this.sodium);

  @override
  Pointer<T> allocate<T extends NativeType>(int byteCount, {int? alignment}) {
    if (alignment != null) {
      throw ArgumentError('Cannot align memory when using SodiumAllocator');
    }

    return sodium.sodium_malloc(byteCount).cast();
  }

  @override
  void free(Pointer<NativeType> pointer) {
    sodium.sodium_free(pointer.cast());
  }
}
