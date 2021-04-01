import 'package:libsodium_dart_bindings/src/api/crypto.dart';
import 'package:libsodium_dart_bindings/src/api/randombytes.dart';
import 'package:libsodium_dart_bindings/src/api/secure_key.dart';
import 'package:libsodium_dart_bindings/src/api/pwhash.dart';
import 'package:libsodium_dart_bindings/src/api/sodium_version.dart';
import 'package:libsodium_dart_bindings/src/js/bindings/num_x.dart';
import 'package:libsodium_dart_bindings/src/js/api/pwhash_js.dart';
import 'package:libsodium_dart_bindings/src/js/api/randombytes_js.dart';
import 'package:libsodium_dart_bindings/src/js/api/secure_key_js.dart';
import 'package:libsodium_dart_bindings/src/js/bindings/node_modules/@types/libsodium-wrappers.dart';

class CrypoJS implements Crypto {
  @override
  SodiumVersion get version => SodiumVersion(
        SODIUM_LIBRARY_VERSION_MAJOR.toSafeInt(),
        SODIUM_LIBRARY_VERSION_MINOR.toSafeInt(),
        sodium_version_string(),
      );

  @override
  SecureKey secureAlloc(int length) => SecureKeyJs.alloc(length);

  @override
  SecureKey secureRandom(int length) => SecureKeyJs.random(length);

  @override
  late final Randombytes randombytes = RandombytesJS();

  @override
  late final Pwhash pwhash = PwhashJs();
}
