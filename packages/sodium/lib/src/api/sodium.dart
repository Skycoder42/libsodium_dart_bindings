import 'dart:typed_data';

import 'crypto.dart';
import 'randombytes.dart';
import 'secure_key.dart';
import 'sodium_version.dart';

abstract class Sodium {
  const Sodium._(); // coverage:ignore-line

  SodiumVersion get version;

  Uint8List pad(Uint8List buf, int blocksize);

  Uint8List unpad(Uint8List buf, int blocksize);

  SecureKey secureAlloc(int length);

  SecureKey secureRandom(int length);

  Randombytes get randombytes;

  Crypto get crypto;
}
