import 'crypto.dart';
import 'randombytes.dart';
import 'secure_key.dart';
import 'sodium_version.dart';

abstract class Sodium {
  const Sodium._();

  SodiumVersion get version;

  SecureKey secureAlloc(int length);

  SecureKey secureRandom(int length);

  Randombytes get randombytes;

  Crypto get crypto;
}
