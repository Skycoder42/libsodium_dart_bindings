// ignore_for_file: non_constant_identifier_names

@JS()
library sodium.js;

import 'dart:typed_data';

import 'package:js/js.dart';

const uint8ArrayOutputFormat = 'uint8array';

@JS()
@anonymous
class LibSodiumJS {
  external int get SODIUM_LIBRARY_VERSION_MAJOR;

  external int get SODIUM_LIBRARY_VERSION_MINOR;

  external String sodium_version_string();

  external void memzero(Uint8List bytes);

  // randombytes
  external int randombytes_seedbytes();

  external Uint8List randombytes_buf(
    int size, [
    String outputFormat = uint8ArrayOutputFormat,
  ]);

  external Uint8List randombytes_buf_deterministic(
    int length,
    Uint8List seed, [
    String outputFormat = uint8ArrayOutputFormat,
  ]);

  external void randombytes_close();

  external int randombytes_random();

  external void randombytes_stir();

  external int randombytes_uniform(int upper_bound);

  // pwhash
  external int crypto_pwhash_ALG_ARGON2I13;

  external int crypto_pwhash_ALG_ARGON2ID13;

  external int crypto_pwhash_ALG_DEFAULT;

  external num crypto_pwhash_BYTES_MAX;

  external num crypto_pwhash_BYTES_MIN;

  external num crypto_pwhash_MEMLIMIT_INTERACTIVE;

  external num crypto_pwhash_MEMLIMIT_MAX;

  external num crypto_pwhash_MEMLIMIT_MIN;

  external num crypto_pwhash_MEMLIMIT_MODERATE;

  external num crypto_pwhash_MEMLIMIT_SENSITIVE;

  external num crypto_pwhash_OPSLIMIT_INTERACTIVE;

  external num crypto_pwhash_OPSLIMIT_MAX;

  external num crypto_pwhash_OPSLIMIT_MIN;

  external num crypto_pwhash_OPSLIMIT_MODERATE;

  external num crypto_pwhash_OPSLIMIT_SENSITIVE;

  external num crypto_pwhash_PASSWD_MAX;

  external num crypto_pwhash_PASSWD_MIN;

  external num crypto_pwhash_SALTBYTES;

  external num crypto_pwhash_STRBYTES;

  external Uint8List crypto_pwhash(
    int keyLength,
    Uint8List password,
    Uint8List salt,
    int opsLimit,
    int memLimit,
    int algorithm, [
    String outputFormat = uint8ArrayOutputFormat,
  ]);

  external String crypto_pwhash_str(
    String password,
    int opsLimit,
    int memLimit,
  );

  external bool crypto_pwhash_str_verify(
    String hashed_password,
    String password,
  );

  external bool crypto_pwhash_str_needs_rehash(
    String hashed_password,
    int opsLimit,
    int memLimit,
  );
}
