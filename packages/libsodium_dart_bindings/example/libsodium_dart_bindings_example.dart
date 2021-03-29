// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:libsodium_dart_bindings/libsodium_dart_bindings.dart';

Uint8List argon2id(SodiumFFI sodium, String password) {
  SodiumPointer<Int8>? passwordPtr;
  SodiumPointer<Uint8>? saltPtr;
  SodiumPointer<Uint8>? outPtr;

  try {
    passwordPtr = password.toPointer(sodium)
      ..memoryProtection = MemoryProtection.readOnly;

    saltPtr = SodiumPointer.alloc(
      sodium,
      sodium.crypto_pwhash_saltbytes(),
    );
    sodium.randombytes_buf(saltPtr.ptr.cast(), saltPtr.byteLength);
    saltPtr.memoryProtection = MemoryProtection.readOnly;

    outPtr = SodiumPointer.alloc(sodium, 16)..zeroMemory();

    final result = sodium.crypto_pwhash(
      outPtr.ptr,
      outPtr.count,
      passwordPtr.ptr,
      passwordPtr.count,
      saltPtr.ptr,
      sodium.crypto_pwhash_opslimit_min(),
      sodium.crypto_pwhash_memlimit_min(),
      sodium.crypto_pwhash_alg_default(),
    );
    if (result != 0) {
      throw Exception('crypto_pwhash: $result');
    }

    return outPtr.copyAsList();
  } finally {
    passwordPtr?.dispose();
    saltPtr?.dispose();
    outPtr?.dispose();
  }
}

void main() {
  final libsodium = DynamicLibrary.open('/usr/lib/libsodium.so');

  final sodium = SodiumFFI(libsodium);

  print('Init: ${sodium.sodium_init()}');

  const password = 'testtesttesttesttesttesttest';

  final out = SecureKey.alloc(
    sodium,
    sodium.crypto_hash_sha256_bytes(),
  );
  print('out ready ${sodium.crypto_hash_sha256_bytes()}');

  final pwPtr = password.toPointer(sodium)
    ..memoryProtection = MemoryProtection.readOnly;
  print('pwPtr ready: ${pwPtr.asList()}');

  out.runUnlockedSync((outPtr) {
    final hashResult = sodium.crypto_hash_sha256(
      outPtr.ptr,
      pwPtr.ptr.cast(),
      pwPtr.count,
    );
    print('Hash: $hashResult');

    print('Result: ${outPtr.asList()}');

    final hexRes =
        outPtr.asList().map((e) => e.toRadixString(16).padLeft(2, '0')).join();
    print('Final: 0x$hexRes');
  });

  print(argon2id(sodium, 'testtesttesttesttesttesttesttest'));
}
