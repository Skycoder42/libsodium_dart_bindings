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

class SodiumJS implements Sodium {
  final LibSodiumJS sodium;

  SodiumJS(this.sodium);

  @override
  SodiumVersion get version => SodiumVersion(
        sodium.SODIUM_LIBRARY_VERSION_MAJOR.toSafeInt(),
        sodium.SODIUM_LIBRARY_VERSION_MINOR.toSafeInt(),
        sodium.sodium_version_string(),
      );

  @override
  SecureKey secureAlloc(int length) => SecureKeyJS.alloc(sodium, length);

  @override
  SecureKey secureRandom(int length) => SecureKeyJS.random(sodium, length);

  @override
  late final Randombytes randombytes = RandombytesJS(sodium);

  @override
  late final Crypto crypto = CrypoJS(sodium);
}
