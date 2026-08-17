import 'dart:ffi';
import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/helpers/validations.dart';
import '../../api/randombytes.dart';
import '../../api/sodium_exception.dart';
import '../bindings/libsodium.ffi.wrapper.dart';
import '../bindings/sodium_scope.dart';

/// @nodoc
@internal
class RandombytesFFI implements Randombytes {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
  new(this.sodium);

  @override
  int get seedBytes => sodium.randombytes_seedbytes();

  @override
  int random() => sodium.randombytes_random();

  @override
  int uniform(int upperBound) => sodium.randombytes_uniform(upperBound);

  @override
  Uint8List buf(int size) => sodiumScope(sodium, (scope) {
    final ptr = scope.alloc<UnsignedChar>(size);
    sodium.randombytes_buf(ptr.ptr.cast(), ptr.byteLength);
    return scope.takeBytes(ptr);
  });

  @override
  Uint8List bufDeterministic(int size, Uint8List seed) {
    Validations.checkIsSame(seed.length, seedBytes, 'seed');

    return sodiumScope(sodium, (scope) {
      final seedPtr = scope.copyList<UnsignedChar>(seed);
      final resultPtr = scope.alloc<UnsignedChar>(size);
      sodium.randombytes_buf_deterministic(
        resultPtr.ptr.cast(),
        resultPtr.byteLength,
        seedPtr.ptr,
      );
      return scope.takeBytes(resultPtr);
    });
  }

  @override
  void close() {
    final result = sodium.randombytes_close();
    SodiumException.checkSucceededInt(result);
  }

  @override
  void stir() => sodium.randombytes_stir();
}
