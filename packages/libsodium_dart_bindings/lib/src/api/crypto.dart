import 'pwhash.dart';
import 'randombytes.dart';
import 'secure_key.dart';
import 'sodium_version.dart';

abstract class Crypto {
  const Crypto._();

  SodiumVersion get version;

  SecureKey secureAlloc(int length);

  SecureKey secureRandom(int length);

  Randombytes get randombytes;

  Pwhash get pwhash;
}
