import 'dart:js';

import '../../api/crypto.dart';
import '../../api/randombytes.dart';
import '../../api/secure_key.dart';
import '../../api/sodium.dart';
import '../../api/sodium_version.dart';
import '../bindings/num_x.dart';
import 'crypto_js.dart';

class SodiumJS implements Sodium {
  final JsObject sodium;

  SodiumJS(this.sodium);

  @override
  SodiumVersion get version => SodiumVersion(
        (sodium['SODIUM_LIBRARY_VERSION_MAJOR'] as num).toSafeInt(),
        (sodium['SODIUM_LIBRARY_VERSION_MINOR'] as num).toSafeInt(),
        sodium.callMethod('sodium_version_string') as String,
      );

  @override
  // SecureKey secureAlloc(int length) => SecureKeyJs.alloc(sodium, length);
  SecureKey secureAlloc(int length) => throw UnimplementedError();

  @override
  // SecureKey secureRandom(int length) => SecureKeyJs.random(sodium, length);
  SecureKey secureRandom(int length) => throw UnimplementedError();

  @override
  // late final Randombytes randombytes = RandombytesJS(sodium);
  Randombytes get randombytes => throw UnimplementedError();

  @override
  late final Crypto crypto = CrypoJS(sodium);
}
