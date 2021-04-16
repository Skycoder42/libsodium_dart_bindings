import 'dart:typed_data';

import 'package:meta/meta.dart';

import '../../api/crypto.dart';
import '../../api/randombytes.dart';
import '../../api/secure_key.dart';
import '../../api/sodium.dart';
import '../../api/sodium_version.dart';
import '../bindings/sodium.js.dart';
import '../bindings/to_safe_int.dart';
import 'crypto_js.dart';
import 'randombytes_js.dart';
import 'secure_key_js.dart';

@internal
class SodiumJS implements Sodium {
  final LibSodiumJS sodium;

  SodiumJS(this.sodium);

  @override
  SodiumVersion get version => SodiumVersion(
        sodium.SODIUM_LIBRARY_VERSION_MAJOR.toSafeUInt32(),
        sodium.SODIUM_LIBRARY_VERSION_MINOR.toSafeUInt32(),
        sodium.sodium_version_string(),
      );

  @override
  Uint8List pad(Uint8List buf, int blocksize) => sodium.pad(buf, blocksize);

  @override
  Uint8List unpad(Uint8List buf, int blocksize) => sodium.unpad(buf, blocksize);

  @override
  SecureKey secureAlloc(int length) => SecureKeyJS.alloc(sodium, length);

  @override
  SecureKey secureRandom(int length) => SecureKeyJS.random(sodium, length);

  @override
  late final Randombytes randombytes = RandombytesJS(sodium);

  @override
  late final Crypto crypto = CryptoJS(sodium);
}
