import 'dart:io';

import 'package:path/path.dart';

import 'file_loader.dart';

class TypeInfo {
  final String dartType;
  final String? template;

  const TypeInfo(this.dartType, {this.template});
}

class TypeMappings {
  static const _classNameParam = '%{className}';

  static const _mappings = <String, TypeInfo>{
    // simple types
    'void': TypeInfo('void'),
    'boolean': TypeInfo('bool'),
    'uint': TypeInfo('num'),
    'string': TypeInfo('String'),
    'buf': TypeInfo('Uint8List'),
    'unsized_buf': TypeInfo('Uint8List'),
    'unsized_buf_optional': TypeInfo('Uint8List?'),
    'minsized_buf': TypeInfo('Uint8List'),
    // simple result mappings
    'randombytes_random_result': TypeInfo('num'),
    'randombytes_uniform_result': TypeInfo('num'),
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
      'CryptoInitPush',
    ),
    'crypto_sign_keypair_result': TypeInfo('KeyPair'),
    'crypto_sign_seed_keypair_result': TypeInfo('KeyPair'),
    // opaque types (states)
    'generichash_state': TypeInfo('GenerichashState', template: 'opaque_type'),
    'generichash_state_address': TypeInfo('GenerichashState'),
    'hash_sha256_state': TypeInfo('HashSha256State', template: 'opaque_type'),
    'hash_sha256_state_address': TypeInfo('HashSha256State'),
    'hash_sha512_state': TypeInfo('HashSha512State', template: 'opaque_type'),
    'hash_sha512_state_address': TypeInfo('HashSha512State'),
    'sign_state': TypeInfo('SignState', template: 'opaque_type'),
    'sign_state_address': TypeInfo('SignState'),
    'onetimeauth_state': TypeInfo('OnetimeauthState', template: 'opaque_type'),
    'onetimeauth_state_address': TypeInfo('OnetimeauthState'),
    'secretstream_xchacha20poly1305_state': TypeInfo(
      'SecretstreamXchacha20poly1305State',
      template: 'opaque_type',
    ),
    'secretstream_xchacha20poly1305_state_address': TypeInfo(
      'SecretstreamXchacha20poly1305State',
    ),
    // hidden types
    'randombytes_implementation': TypeInfo('Never'),
    'randombytes_set_implementation_result': TypeInfo('Never'),
  };

  late final fileLoader = FileLoader(Directory(
    join(
      FileLoader.scriptDir.path,
      'libsodium_js_generator',
      'types',
    ),
  ));

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

  Future<void> writeTypeDefinitions(StringSink sink) async {
    final typeFiles = await fileLoader.listFilesSorted(
      '.',
      (file) => file.path.endsWith('.dart.type'),
    );

    for (final typeFile in typeFiles) {
      sink.writeln(await typeFile.readAsString());
    }

    for (final info in _mappings.values) {
      if (info.template != null) {
        final templateStr = await fileLoader.loadFile(
          '${info.template}.dart.template',
        );
        final outStr = templateStr.replaceAll(_classNameParam, info.dartType);
        sink.writeln(outStr);
      }
    }
  }
}
