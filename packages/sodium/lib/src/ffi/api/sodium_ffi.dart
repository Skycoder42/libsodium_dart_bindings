import 'package:ffi/ffi.dart';

import '../../api/crypto.dart';
import '../../api/randombytes.dart';
import '../../api/secure_key.dart';
import '../../api/sodium.dart';
import '../../api/sodium_version.dart';
import '../bindings/libsodium.ffi.dart';
import 'crypto_ffi.dart';
import 'randombytes_ffi.dart';
import 'secure_key_ffi.dart';

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
  SecureKey secureAlloc(int length) => SecureKeyFFI.alloc(sodium, length);

  @override
  SecureKey secureRandom(int length) => SecureKeyFFI.random(sodium, length);

  @override
  late final Randombytes randombytes = RandombytesFFI(sodium);

  @override
  late final Crypto crypto = CryptoFFI(sodium);
}
