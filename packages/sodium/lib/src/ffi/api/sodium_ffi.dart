import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:meta/meta.dart';

import '../../api/crypto.dart';
import '../../api/randombytes.dart';
import '../../api/secure_key.dart';
import '../../api/sodium.dart';
import '../../api/sodium_exception.dart';
import '../../api/sodium_version.dart';
import '../bindings/libsodium.ffi.dart';
import '../bindings/memory_protection.dart';
import '../bindings/sodium_pointer.dart';
import 'crypto_ffi.dart';
import 'randombytes_ffi.dart';
import 'secure_key_ffi.dart';

@internal
class SodiumFFI implements Sodium {
  final LibSodiumFFI sodium;

  SodiumFFI(this.sodium);

  @override
  SodiumVersion get version => SodiumVersion(
        sodium.sodium_library_version_major(),
        sodium.sodium_library_version_minor(),
        sodium.sodium_version_string().cast<Utf8>().toDartString(),
      );

  @override
  Uint8List pad(Uint8List buf, int blocksize) {
    final maxLen = buf.length + blocksize;
    SodiumPointer<Uint8>? extendedBuffer;
    SodiumPointer<Uint64>? paddedLength;
    try {
      extendedBuffer = SodiumPointer.alloc(sodium, count: maxLen)..fill(buf);
      paddedLength = SodiumPointer.alloc(sodium, zeroMemory: true);
      final result = sodium.sodium_pad(
        paddedLength.ptr,
        extendedBuffer.ptr,
        buf.length,
        blocksize,
        maxLen,
      );
      SodiumException.checkSucceededInt(result);
      return extendedBuffer.copyAsList(paddedLength.ptr.value);
    } finally {
      extendedBuffer?.dispose();
      paddedLength?.dispose();
    }
  }

  @override
  Uint8List unpad(Uint8List buf, int blocksize) {
    SodiumPointer<Uint8>? extendedBuffer;
    SodiumPointer<Uint64>? unpaddedLength;
    try {
      extendedBuffer = buf.toSodiumPointer(
        sodium,
        memoryProtection: MemoryProtection.readOnly,
      );
      unpaddedLength = SodiumPointer.alloc(sodium, zeroMemory: true);
      final result = sodium.sodium_unpad(
        unpaddedLength.ptr,
        extendedBuffer.ptr,
        extendedBuffer.count,
        blocksize,
      );
      SodiumException.checkSucceededInt(result);
      return extendedBuffer.copyAsList(unpaddedLength.ptr.value);
    } finally {
      extendedBuffer?.dispose();
      unpaddedLength?.dispose();
    }
  }

  @override
  SecureKey secureAlloc(int length) => SecureKeyFFI.alloc(sodium, length);

  @override
  SecureKey secureRandom(int length) => SecureKeyFFI.random(sodium, length);

  @override
  late final Randombytes randombytes = RandombytesFFI(sodium);

  @override
  late final Crypto crypto = CryptoFFI(sodium);
}
