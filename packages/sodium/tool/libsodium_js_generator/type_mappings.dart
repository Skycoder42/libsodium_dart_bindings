import 'dart:io';

import 'package:path/path.dart';

import 'file_loader.dart';

class TypeInfo {
  final String dartType;
  final String? typeDef;
  final bool force;

  const TypeInfo(
    this.dartType, {
    this.typeDef,
    this.force = false,
  });
}

class TypeMappings {
  static const _mappings = <String, TypeInfo>{
    // simple types
    'void': TypeInfo('void'),
    'boolean': TypeInfo('bool'),
    'uint': TypeInfo('num'),
    'u64': TypeInfo('JSBigInt'),
    'string': TypeInfo('String'),
    'buf': TypeInfo('JSUint8Array'),
    'buf_optional': TypeInfo('JSUint8Array?'),
    'unsized_buf': TypeInfo('JSUint8Array'),
    'unsized_buf_optional': TypeInfo('JSUint8Array?'),
    'minsized_buf': TypeInfo('JSUint8Array'),
    // simple result mappings
    'randombytes_random_result': TypeInfo('int'),
    'randombytes_uniform_result': TypeInfo('int'),
    'sodium_version_string_result': TypeInfo('String'),
    // complex result mappings
    'crypto_aead_chacha20poly1305_encrypt_detached_result': TypeInfo(
      'CryptoBox',
    ),
    'crypto_aead_chacha20poly1305_ietf_encrypt_detached_result': TypeInfo(
      'CryptoBox',
    ),
    'crypto_aead_xchacha20poly1305_ietf_encrypt_detached_result': TypeInfo(
      'CryptoBox',
    ),
    'crypto_box_curve25519xchacha20poly1305_keypair_result': TypeInfo(
      'KeyPair',
    ),
    'crypto_box_detached_result': TypeInfo('CryptoBox'),
    'crypto_box_keypair_result': TypeInfo('KeyPair'),
    'crypto_box_seed_keypair_result': TypeInfo('KeyPair'),
    'crypto_kx_client_session_keys_result': TypeInfo('CryptoKX'),
    'crypto_kx_keypair_result': TypeInfo('KeyPair'),
    'crypto_kx_seed_keypair_result': TypeInfo('KeyPair'),
    'crypto_kx_server_session_keys_result': TypeInfo('CryptoKX'),
    'crypto_secretbox_detached_result': TypeInfo('SecretBox'),
    'crypto_secretstream_xchacha20poly1305_init_push_result': TypeInfo(
      'SecretStreamInitPush',
    ),
    'crypto_secretstream_xchacha20poly1305_pull_result': TypeInfo(
      'JSAny',
      force: true,
    ),
    'crypto_sign_keypair_result': TypeInfo('KeyPair'),
    'crypto_sign_seed_keypair_result': TypeInfo('KeyPair'),
    'crypto_aead_aegis128l_encrypt_detached_result': TypeInfo('CryptoBox'),
    'crypto_aead_aegis256_encrypt_detached_result': TypeInfo('CryptoBox'),
    'crypto_box_curve25519xchacha20poly1305_detached_result':
        TypeInfo('CryptoBox'),
    'crypto_box_curve25519xchacha20poly1305_detached_afternm_result':
        TypeInfo('CryptoBox'),
    'crypto_box_curve25519xchacha20poly1305_seed_keypair_result':
        TypeInfo('KeyPair'),
    // state typedefs
    'secretstream_xchacha20poly1305_state': TypeInfo(
      'SecretstreamXchacha20poly1305State',
      typeDef: 'JSNumber',
    ),
    'secretstream_xchacha20poly1305_state_address':
        TypeInfo('SecretstreamXchacha20poly1305State'),
    'sign_state': TypeInfo('SignState', typeDef: 'JSNumber'),
    'sign_state_address': TypeInfo('SignState'),
    'generichash_state': TypeInfo('GenerichashState', typeDef: 'JSNumber'),
    'generichash_state_address': TypeInfo('GenerichashState'),
    'hash_sha256_state': TypeInfo('HashSha256State', typeDef: 'JSNumber'),
    'hash_sha256_state_address': TypeInfo('HashSha256State'),
    'hash_sha512_state': TypeInfo('HashSha512State', typeDef: 'JSNumber'),
    'hash_sha512_state_address': TypeInfo('HashSha512State'),
    'onetimeauth_state': TypeInfo('OnetimeauthState', typeDef: 'JSNumber'),
    'onetimeauth_state_address': TypeInfo('OnetimeauthState'),
    'auth_hmacsha256_state':
        TypeInfo('AuthHmacsha256State', typeDef: 'JSNumber'),
    'auth_hmacsha256_state_address': TypeInfo('AuthHmacsha256State'),
    'auth_hmacsha512_state':
        TypeInfo('AuthHmacsha512State', typeDef: 'JSNumber'),
    'auth_hmacsha512_state_address': TypeInfo('AuthHmacsha512State'),
    'auth_hmacsha512256_state':
        TypeInfo('AuthHmacsha512256State', typeDef: 'JSNumber'),
    'auth_hmacsha512256_state_address': TypeInfo('AuthHmacsha512256State'),
    // hidden types
    'randombytes_implementation': TypeInfo('JSAny'),
    'randombytes_set_implementation_result': TypeInfo('JSAny'),
  };

  late final fileLoader = FileLoader(
    Directory(
      join(
        FileLoader.scriptDir.path,
        'libsodium_js_generator',
        'types',
      ),
    ),
  );

  TypeMappings();

  String operator [](String type) {
    final mappedType = _mappings[type];
    if (mappedType == null) {
      stderr.writeln('Missing type-mapping: $type');
      exitCode = 1;
      return 'dynamic';
    } else {
      return mappedType.dartType;
    }
  }

  bool isForced(String type) => _mappings[type]?.force ?? false;

  Future<void> writeTypeDefinitions(StringSink sink) async {
    for (final info in _mappings.values) {
      if (info.typeDef != null) {
        sink.writeln('typedef ${info.dartType} = ${info.typeDef};\n');
      }
    }

    final typeFiles = await fileLoader.listFilesSorted(
      '.',
      (file) => file.path.endsWith('.dart.type'),
    );
    for (final typeFile in typeFiles) {
      sink.writeln(await typeFile.readAsString());
    }
  }
}
