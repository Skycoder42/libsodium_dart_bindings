# sodium
[![Continous Integration for package sodium](https://github.com/Skycoder42/libsodium_dart_bindings/actions/workflows/sodium_ci.yaml/badge.svg)](https://github.com/Skycoder42/libsodium_dart_bindings/actions/workflows/sodium_ci.yaml)
[![Pub Version](https://img.shields.io/pub/v/sodium)](https://pub.dev/packages/sodium)

Dart bindings for libsodium, supporting both the VM and JS without flutter dependencies.

## Features
- Provides a simple to use dart API for accessing libsodium
- High-Level API that is the same for both VM and JS

## API Status
The following table shows the current status of the implementation. APIs that
have not been implemented yet, but are planned to, are listed with X. If you
find an API is missing from this table, please create an issue and it will be
added, unless it is one of the "extended" APIs.

 libsodium API       | FFI | JS | Documentation
---------------------|-----|----|---------------
 padding             | ✔️ | ✔️ | https://libsodium.gitbook.io/doc/padding
 memory              | ✔️ | ⚠️ | https://libsodium.gitbook.io/doc/memory_management
 randombytes         | ✔️ | ✔️ | https://libsodium.gitbook.io/doc/generating_random_data
 secretbox           | ✔️ | ✔️ | https://libsodium.gitbook.io/doc/secret-key_cryptography/secretbox
 secretstream        | ✔️ | ✔️ | https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream
 crypto_auth         | ❌ | ❌ | https://libsodium.gitbook.io/doc/secret-key_cryptography/secret-key_authentication
 crypto_box          | ❌ | ❌ | https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption
 crypto_sign         | ❌ | ❌ | https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures
 crypto_box_seal     | ❌ | ❌ | https://libsodium.gitbook.io/doc/public-key_cryptography/sealed_boxes
 crypto_generichash  | ❌ | ❌ | https://libsodium.gitbook.io/doc/hashing/generic_hashing
 crypto_shorthash    | ❌ | ❌ | https://libsodium.gitbook.io/doc/hashing/short-input_hashing
 crypto_pwhash       | ✔️ | ✔️ | https://libsodium.gitbook.io/doc/password_hashing/default_phf
 crypto_kdf          | ❌ | ❌ | https://libsodium.gitbook.io/doc/key_derivation
 crypto_kx           | ❌ | ❌ | https://libsodium.gitbook.io/doc/key_exchange
 crypto_scalarmult   | ❌ | ❌ | https://libsodium.gitbook.io/doc/advanced/scalar_multiplication
 crypto_onetimeauth  | ❌ | ❌ | https://libsodium.gitbook.io/doc/advanced/poly1305
 crypto_hash_sha     | ❔  | ❔  | https://libsodium.gitbook.io/doc/advanced/sha-2_hash_function
 crypto_auth_hmacsha | ❔  | ❔  | https://libsodium.gitbook.io/doc/advanced/hmac-sha2

**Note:** Memory Management in JS is limited to overwriting the memory with 0.
All other Memory-APIs are limited to FFI

## Installation
Simply add `sodium` to your `pubspec.yaml` and run `pub get` (or `flutter pub get`).

## Usage
TODO

## Documentation
The documentation is available at https://pub.dev/documentation/sodium/latest/. A full example can be found at https://pub.dev/packages/sodium/example.