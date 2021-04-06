import 'dart:ffi';
import 'dart:typed_data';

import '../../api/randombytes.dart';
import '../bindings/libsodium.ffi.dart';
import '../bindings/sodium_pointer.dart';

class RandombytesFFI implements Randombytes {
  final LibSodiumFFI sodium;

  RandombytesFFI(this.sodium);

  @override
  int get seedBytes => sodium.randombytes_seedbytes();

  @override
  int random() => sodium.randombytes_random();

  @override
  int uniform(int upperBound) => sodium.randombytes_uniform(upperBound);

  @override
  Uint8List buf(int size) {
    final ptr = SodiumPointer<Uint8>.alloc(sodium, count: size);
    try {
      sodium.randombytes_buf(ptr.ptr.cast(), ptr.byteLength);
      return ptr.copyAsList();
    } finally {
      ptr.dispose();
    }
  }

  @override
  Uint8List bufDeterministic(int size, Uint8List seed) {
    RangeError.checkValueInInterval(seed.length, seedBytes, seedBytes, 'seed');

    SodiumPointer<Uint8>? seedPtr;
    SodiumPointer<Uint8>? resultPtr;
    try {
      seedPtr = SodiumPointer.fromList(
        sodium,
        seed,
        memoryProtection: MemoryProtection.readOnly,
      );
      resultPtr = SodiumPointer.alloc(sodium, count: size);
      sodium.randombytes_buf_deterministic(
        resultPtr.ptr.cast(),
        resultPtr.byteLength,
        seedPtr.ptr,
      );
      return resultPtr.copyAsList();
    } finally {
      resultPtr?.dispose();
      seedPtr?.dispose();
    }
  }

  @override
  void close() => sodium.randombytes_close();

  @override
  void stir() => sodium.randombytes_stir();
}
