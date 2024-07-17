import '../json/struct.dart';
import '../json/type_info.dart';
import '../json/type_mapping.dart';
import 'file_loader.dart';

class TypeMappingsLoader {
  final FileLoader _sourceLoader;

  TypeMappingsLoader(this._sourceLoader);

  TypeMapping get typeMapping => const TypeMapping(_mappings);

  Iterable<DartTypeDef> get dartTypeDefs =>
      _mappings.values.map((m) => m.dartTypeDef).nonNulls;

  Stream<Struct> get jsCustomStructs => _sourceLoader.loadFilesJson(
        'types',
        (file) => file.path.endsWith('.json'),
        Struct.fromJson,
      );

  static const _mappings = <String, TypeInfo>{
    // simple types
    'void': TypeInfo('void'),
    'boolean': TypeInfo('bool'),
    'uint': TypeInfo('int'),
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
}
