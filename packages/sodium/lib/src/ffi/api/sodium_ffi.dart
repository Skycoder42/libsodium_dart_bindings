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

/// @nodoc
@internal
class SodiumFFI implements Sodium {
  /// @nodoc
  final LibSodiumFFI sodium;

  /// @nodoc
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
    SodiumPointer<UnsignedChar>? extendedBuffer;
    SodiumPointer<Size>? paddedLength;
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
      return Uint8List.fromList(
        extendedBuffer.viewAt(0, paddedLength.ptr.value).asListView(),
      );
    } finally {
      extendedBuffer?.dispose();
      paddedLength?.dispose();
    }
  }

  @override
  Uint8List unpad(Uint8List buf, int blocksize) {
    SodiumPointer<UnsignedChar>? extendedBuffer;
    SodiumPointer<Size>? unpaddedLength;
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
      return Uint8List.fromList(
        extendedBuffer.viewAt(0, unpaddedLength.ptr.value).asListView(),
      );
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
  SecureKey secureCopy(Uint8List data) => SecureKeyFFI(
        data.toSodiumPointer(
          sodium,
          memoryProtection: MemoryProtection.noAccess,
        ),
      );

  @override
  SecureKey secureHandle(covariant SecureKeyFFINativeHandle nativeHandle) {
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
  late final Randombytes randombytes = RandombytesFFI(sodium);

  @override
  late final Crypto crypto = CryptoFFI(sodium);
}
