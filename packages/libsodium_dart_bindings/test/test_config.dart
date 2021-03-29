import 'dart:ffi';

DynamicLibrary loadLibSodium() => DynamicLibrary.open('/usr/lib/libsodium.so');
