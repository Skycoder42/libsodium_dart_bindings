import 'package:libsodium_dart_bindings/src/api/randombytes.dart';
import 'package:libsodium_dart_bindings/src/api/sodium_version.dart';
import 'package:libsodium_dart_bindings/src/ffi/api/randombytes_ffi.dart';

import '../../api/crypto.dart';
import '../../api/pwhash.dart';
import '../../api/secure_key.dart';
import '../bindings/sodium.ffi.dart';
import '../bindings/sodium_pointer.dart';
import 'pwhash_ffi.dart';
import 'secure_key_ffi.dart';

class CryptoFFI implements Crypto {
  final SodiumFFI sodium;

  CryptoFFI(this.sodium);

  @override
  SodiumVersion get version => SodiumVersion(
        sodium.sodium_library_version_major(),
        sodium.sodium_library_version_minor(),
        sodium.sodium_version_string().toDartString(),
      );

  @override
  SecureKey secureAlloc(int length) => SecureKeyFFI.alloc(sodium, length);

  @override
  SecureKey secureRandom(int length) => SecureKeyFFI.random(sodium, length);

  @override
  late final Randombytes randombytes = RandombytesFFI(sodium);

  @override
  late final Pwhash pwhash = PwhashFFI(sodium);
}
