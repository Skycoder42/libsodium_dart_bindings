# sodium
[![Continuous Integration for package sodium](https://github.com/Skycoder42/libsodium_dart_bindings/actions/workflows/sodium_ci.yaml/badge.svg)](https://github.com/Skycoder42/libsodium_dart_bindings/actions/workflows/sodium_ci.yaml)
[![Pub Version](https://img.shields.io/pub/v/sodium)](https://pub.dev/packages/sodium)

Dart bindings for libsodium, supporting both the VM and JS without flutter dependencies.

## Table of contents
- [Version 4.0 Migration Guide](#version-40-migration-guide)
- [Features](#features)
  * [API Status](#api-status)
    + [Considered for the future](#considered-for-the-future)
- [Installation](#installation)
- [Usage](#usage)
  * [Sodium vs SodiumSumo](#sodium-vs-sodiumsumo)
  * [Loading libsodium](#loading-libsodium)
    + [Transpiled JavaScript - loading the JavaScript code](#transpiled-javascript---loading-the-javascript-code)
  * [Using the API](#using-the-api)
  * [Running computations in a separate isolate](#running-computations-in-a-separate-isolate)
    + [Using custom isolates](#using-custom-isolates)
- [Documentation](#documentation)

<small><i><a href='https://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

## Version 4.0 Migration Guide
Version 4 introduces only one major change: The native `libsodium` binaries are now built on demand using the new build
hooks, instead of being pre-built and bundled with the library. This has no impact on the API, but it does change how
the library has to be initialized. You no longer need to pass in a reference to the native library:

```dart
// Before:
final sodium = await SodiumInit.init(loadLibsodium);
// After:
final sodium = await SodiumInit.init();
```

Another minor change that follows from this is that `Sodium.runIsolated` now only takes a callback with 2 arguments, as
the `Sodium` instance is now available in the isolate without needing to be passed in. It can be captured via the
closure context. See [Running computations in a separate isolate](#running-computations-in-a-separate-isolate) for an
updated example.

## Features
- Provides a simple to use dart API for accessing libsodium - High-Level API that is the same for both VM and JS - Aims
to provide access to all primary libsodium APIs. See [API Status](#api-status) for more details.
- Provides native APIs for tighter integration, if necessary
- Works on all major dart and flutter platforms (Android, iOS, Linux, Windows, macOS, Web)
- Uses the new build hooks to build native dependencies on demand for every platform

### API Status
The following table shows the current status of the implementation. APIs that have already been ported get the ✔️, those
that are planned but not there yet have 🚧. If you see an ❌, it means that the API is not available on that platform
and thus cannot be implemented. The Sumo column specifies whether the API is available as sumo extension. Those listed
with a ✔️ are available *only* in the sumo API, while those marked with ➕ have extended sumo APIs. APIs that are not
listet yet have either been forgotten or are not planned. If you find one you would like to have made available, please
create an issue for it, and I will add it to the list.

API based on libsodium version: *1.0.21*

 libsodium API                | VM  | JS | Sumo | Documentation
---------------------------   |-----|----|------|---------------
 padding                      | ✔️   | ✔️  |      | https://libsodium.gitbook.io/doc/padding
 memory                       | ✔️   | ❌  |      | https://libsodium.gitbook.io/doc/memory_management
 randombytes                  | ✔️   | ✔️  |      | https://libsodium.gitbook.io/doc/generating_random_data
 crypto_secretbox             | ✔️   | ✔️  |      | https://libsodium.gitbook.io/doc/secret-key_cryptography/secretbox
 crypto_secretstream          | ✔️   | ✔️  |      | https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream
 crypto_aead_...              | ✔️   | ✔️  |      | https://libsodium.gitbook.io/doc/secret-key_cryptography/aead
 &gt; _xchacha20poly1305_ietf | ✔️   | ✔️  |      | https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/xchacha20-poly1305_construction
 &gt; _chacha20poly1305       | ✔️   | ✔️  |      | https://libsodium.gitbook.io/doc/secret-key_cryptography/aead/chacha20-poly1305/original_chacha20-poly1305_construction
 crypto_auth                  | ✔️   | ✔️  |      | https://libsodium.gitbook.io/doc/secret-key_cryptography/secret-key_authentication
 crypto_box                   | ✔️   | ✔️  |      | https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption
 crypto_sign                  | ✔️   | ✔️  | ➕   | https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures
 crypto_box_seal              | ✔️   | ✔️  |      | https://libsodium.gitbook.io/doc/public-key_cryptography/sealed_boxes
 crypto_generichash           | ✔️   | ✔️  |      | https://libsodium.gitbook.io/doc/hashing/generic_hashing
 crypto_shorthash             | ✔️   | ✔️  |      | https://libsodium.gitbook.io/doc/hashing/short-input_hashing
 crypto_pwhash                | ✔️   | ✔️  | ✔️   | https://libsodium.gitbook.io/doc/password_hashing/default_phf
 crypto_kdf                   | ✔️   | ✔️  |      | https://libsodium.gitbook.io/doc/key_derivation
 crypto_kx                    | ✔️   | ✔️  |      | https://libsodium.gitbook.io/doc/key_exchange
 crypto_scalarmult            | ✔️   | ✔️  | ✔️   | https://libsodium.gitbook.io/doc/advanced/scalar_multiplication

**Note:** Memory Management in JS is limited to overwriting the memory with 0. All other Memory-APIs are only available
in the VM.

#### Considered for the future
The following APIs I considered adding, but since they all appear below the "Advanced" Tab in the documentation, I
decided against it for version 1.0.0. However, with version 2.0.0, support for advanced APIs has been enabled via sumo.
This means all of those have now become feasible to implement and might be added in the future. If you need one of these
or some other advanced API, please create an issue.

 libsodium API       | VM  | JS | Documentation
---------------------|-----|----|---------------
 crypto_onetimeauth  | ❔  | ❔ | https://libsodium.gitbook.io/doc/advanced/poly1305
 crypto_hash_sha     | ❔  | ❔ | https://libsodium.gitbook.io/doc/advanced/sha-2_hash_function
 crypto_auth_hmacsha | ❔  | ❔ | https://libsodium.gitbook.io/doc/advanced/hmac-sha2

## Installation
Simply add `sodium` to your `pubspec.yaml` and run `pub get` (or `flutter pub get`).

## Usage
The usage can be split into two parts. The first one is about loading the native libsodium into dart, the second one
about using the API.

### Sodium vs SodiumSumo
As this library aims to support both native and JavaScript targets, it needs to unify both APIs under one single dart
API. This comes with one major consideration: The separation between a "normal" and a "sumo" variant of the library.
These terms are absent in the C-library, but have been introduced in the JS-Variant (See
https://github.com/jedisct1/libsodium.js/?tab=readme-ov-file#standard-vs-sumo-version).

In order support both library variants in this library, the APIs have been split here as well. However, this **only**
affects the JS part of the code, as for the native implementation there is no differentiation between the two. What
this means for you as a consumer of the library is the following:

- If you only ever intend to use the native variant (i. e. your application will not be transpiled to JS), you can
simply always use the sumo variant.
- If you want to support both, native and web, you have to check wich of the APIs you need are available in which
version. The Sumo-Variant is more complete, but has a bigger binary size, which might matter depending on the usecase.

### Loading libsodium
Thanks to the use of native assets, the library initialization is pretty straight forward on all platforms, as the
library will be automatically built when compiling the app and automatically bundled with the app. To use it, simply
call `SodiumInit.init()` and the library will be ready to use.

**Note:** When using the sumo APIs, simply replace `SodiumInit` with `SodiumSumoInit` from the
`package:sodium/sodium_sumo.dart` import.

```dart
import 'package:sodium/sodium.dart';

final sodium = await SodiumInit.init();
// You now have a Sodium instance, see sodium package to continue
```

#### Transpiled JavaScript - loading the JavaScript code
For JavaScript, the situation is a little more complex, as there currently the build hooks do not support bundled JS
assets. This means that the JS code of libsodium cannot be automatically bundled with the library and thus needs to be
downloaded manually. To do this, the package ships with a helper binary that downloads the correct version of
[`sodium.js`](https://github.com/jedisct1/libsodium.js) and adds the corresponding `<script>`-tag to the `index.html`.
You can run this tool with the following command:

```.sh
dart run sodium:update_web [--sumo] [--no-edit-index] [--target-directory <target_directory>]
```

The `--sumo` parameter is optional. If specified, the Sumo-Variant of sodium.js will be downloaded. It is bigger in
size, but contains all APIs. With the non-sumo version, you can only use `SodiumInit.init`, which should suffice for
most usecases. However, if you need access to the `SodiumSumo`-APIs and thus need to invoke `SodiumSumoInit.init`, you
have to make sure to add this parameter.

By default, the `index.html` is modified to automatically load the `sodium.js` before the dart code starts. If you want
to customize when and how the library is loaded, you can disable this behavior with the `--no-edit-index` parameter and
add the script tag manually.

Finally, if your web project files are for whatever reason not located in the `web` directory, you can set a custom
directory.

### Using the API
Once you have acquired the `Sodium` instance, usage is fairly straight forward. The API mirrors the original native C
api, splitting different categories of methods into different classes for maintainability, which are all built up in
hierarchical order starting at `Sodium`. For example, if you wanted to use the `crypto_secretbox_easy` method from the C
api, the equivalent dart method would be `.crypto.secretBox.easy`. The following example shows how to use it:

```dart
final sodium = await SodiumInit.init();

// The message to be encrypted, converted to an unsigned char array.
final String message = 'my very secret message';
final Int8List messageChars = message.toCharArray();
final Uint8List messageBytes = messageChars.unsignedView();

// A randomly generated nonce
final nonce = sodium.randombytes.buf(
  sodium.crypto.secretBox.nonceBytes,
);

// Generate a secret key
final SecureKey key = sodium.crypto.secretBox.keygen();

// Encrypt the data
final encryptedData = sodium.crypto.secretBox.easy(
  message: messageBytes,
  nonce: nonce,
  key: key,
)

print(encryptedData);

// after you are done:
key.dispose();
```

The only main differences here are, that instead of raw pointers, the dart typed lists are used. Also, instead of simply
passing a byte array as the key, the `SecureKey` is used. It is a special class created for this library that wraps
native memory, thus providing a secure way of keeping your keys in memory. You can either create such keys via the
`*_keygen` methods, or directly via `sodium.secure*`.

**Note:** Since these keys wrap native memory, it is mandatory that you dispose of them after you are done with a key,
as otherwise they will leak memory.

### Running computations in a separate isolate
Some operations with libsodium (like password hashing) can take multiple seconds to execute. In such a case, running the
computation on a separate isolate is mandatory to not block the UI. However, the standard
[compute](https://api.flutter.dev/flutter/foundation/compute.html) or
[Isolate.run](https://api.flutter.dev/flutter/dart-isolate/Isolate/run.html) methods will not work, as it is not
possible to pass a `Sodium` instance between isolates. For this reason, the library has a helper method:
[Sodium.runIsolated](https://pub.dev/documentation/sodium/latest/sodium/Sodium/runIsolated.html)

The usage is pretty straight forward: It is a compute callback, but any `SecretKey` or `KeyPair` values must be passed
as addition parameters, as they need special intervention to be transferred to the isolate. Returning however works and
allows you to simply pass back a key (or pair) if needed. A simple example that runs a key derivation would look like
this:

```dart
final subkeyId = BigInt.from(42);
final masterKey = sodium.crypto.kdf.keygen();
final derivedKey = await sodium.runIsolated(
  secureKeys: [masterKey],
  // keyPairs: use if a KeyPair needs to be passed to the isolate
  (secureKeys, keyPairs) {
    final [masterKey] = secureKeys;
    final derivedKey = sodium.crypto.kdf.deriveFromKey(
      masterKey: masterKey, // keys must be passed via the extra parameters
      context: 'computed',
      subkeyId: subkeyId, // normal values can be used as usual
      subkeyLen: 64,
    );
    return derivedKey; // keys can be returned
  }
);
```

#### Using custom isolates
While the example above works fine if you simply want to run an asynchronous computation, it might not be sufficient for
more complex scenarios. For example, if you want to use an isolate pool, you would want to execute sodium methods on an
existing isolate and not create a new one every time. For this, the library provides low-level isolate APIs that allow
you to do exactly this.

**Warning:** These APIs are low-level and can lead to memory leaks and hard crashes if used incorrectly. So read the
following with care!

The most important part to understand are the create/materialize methods. They allow you to make a secure key
"transferrable". This is needed, as dart does not allow the transfer of pointers between isolates. The
`Sodium.createTransferrableSecureKey` and `createTransferrableKeyPair` will create a special *copy* of the original
key/key pair that can be transferred. You can then call `Sodium.materializeTransferrableSecureKey` or
`Sodium.materializeTransferrableKeyPair` on the target isolate to get a normal key/key pair back. This is preferred
over simply sending the keys as `Uint8List`, as the transferrable keys will still apply all the advanced security
measures that `SecureKey` uses as well.

**IMPORTANT:** As the transferrable variants do work around darts pointer management, they will **not** be automatically
garbage collected if left dangling. You **MUST** materialize every transferrable key/key pair *exactly* once, or you
will create memory leaks for sensitive data! If you need to send keys to multiple isolates, create one per isolate.

For other data, like public keys or plain/cipher text, you can simply send the `Uint8List`, however, if performance is
relevant, you should instead use the
[TransferableTypedData](https://api.flutter.dev/flutter/dart-isolate/TransferableTypedData-class.html), as it will
reduce the number of times data has to be copied.

Here is a simple variant of the above example that uses the low level APIs instead.

```dart
Future<SecureKey> deriveKey() {
  final subkeyId = BigInt.from(42);
  final masterKey = sodium.crypto.kdf.keygen();

  final transferrableMasterKey = sodium.createTransferrableSecureKey(masterKey);

  final result = compute(_deriveKey, (sodium, transferrableMasterKey, subkeyId));

  return sodium.materializeTransferrableSecureKey(result);
}

static Future<TransferrableSecureKey> _deriveKey((Sodium, TransferrableSecureKey, BigInt) message) async {
  final (sodium, transferrableMasterKey, subkeyId) = message;
  final masterKey = sodium.materializeTransferrableSecureKey(transferrableMasterKey);
  final derivedKey = sodium.crypto.kdf.deriveFromKey(
    masterKey: masterKey, // keys must be passed via the extra parameters
    context: 'computed',
    subkeyId: subkeyId, // normal values can be used as usual
    subkeyLen: 64,
  );
  final transferrableDerivedKey = sodium.createTransferrableSecureKey(derivedKey);
  return transferrableDerivedKey;
}
```

## Documentation
The documentation is available at https://pub.dev/documentation/sodium/latest/. A full example can be found at
https://pub.dev/packages/sodium/example.

The example is a flutter app on purpose, so it is easier to test the library on all platforms. However, the code is
pure dart and can be easily adapted to work in a pure dart environment.

See the [Example README](example/README.md) for more details on the example.
