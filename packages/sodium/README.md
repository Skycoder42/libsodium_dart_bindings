# sodium
[![Continous Integration for package sodium](https://github.com/Skycoder42/libsodium_dart_bindings/actions/workflows/sodium_ci.yaml/badge.svg)](https://github.com/Skycoder42/libsodium_dart_bindings/actions/workflows/sodium_ci.yaml)
[![Pub Version](https://img.shields.io/pub/v/sodium)](https://pub.dev/packages/sodium)

Dart bindings for libsodium, supporting both the VM and JS without flutter 
dependencies.

## Table of contents
* [Features](#features)
  + [API Status](#api-status)
* [Installation](#installation)
* [Usage](#usage)
  + [Loading libsodium](#loading-libsodium)
    - [VM - loading the dynamic library](#vm---loading-the-dynamic-library)
    - [Transpiled JavaScript - loading the JavaScript code.](#transpiled-javascript---loading-the-javascript-code)
      * [Loading sodium.js into the browser via dart.](#loading-sodiumjs-into-the-browser-via-dart)
  + [Using the API](#using-the-api)
* [Documentation](#documentation)
  + [Example for the dart VM](#example-for-the-dart-vm)
  + [Example in the browser](#example-in-the-browser)

<small><i><a href='https://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

## Features
- Provides a simple to use dart API for accessing libsodium
- High-Level API that is the same for both VM and JS
- Aims to provide access to all primary libsodium APIs. See 
[API Status](#api-status) for more details.
- Provides native APIs for tighter integration, if necessary

### API Status
The following table shows the current status of the implementation. APIs that
have already been ported get the ✔️, those that are planned but not there yet
have 🚧. If you see an ❌, it means that the API is not available on that 
platform and thus cannot be implemented. APIs that are marked with ❔ are still
up for debate, whether the will be added to the library Version 1.0.0, or maybe 
later. APIs that are not listet yet have either been forgotten or are not 
planned. If you find one you would like to have made available, please create an
issue for it, and I will add it to the list.

API based on libsodium version: *1.0.18*

 libsodium API       | VM  | JS | Documentation
---------------------|-----|----|---------------
 padding             | ✔️ | ✔️ | https://libsodium.gitbook.io/doc/padding
 memory              | ✔️ | ❌ | https://libsodium.gitbook.io/doc/memory_management
 randombytes         | ✔️ | ✔️ | https://libsodium.gitbook.io/doc/generating_random_data
 crypto_secretbox    | ✔️ | ✔️ | https://libsodium.gitbook.io/doc/secret-key_cryptography/secretbox
 crypto_secretstream | ✔️ | ✔️ | https://libsodium.gitbook.io/doc/secret-key_cryptography/secretstream
 crypto_auth         | ✔️ | ✔️ | https://libsodium.gitbook.io/doc/secret-key_cryptography/secret-key_authentication
 crypto_box          | ✔️ | ✔️ | https://libsodium.gitbook.io/doc/public-key_cryptography/authenticated_encryption
 crypto_sign         | 🚧 | 🚧 | https://libsodium.gitbook.io/doc/public-key_cryptography/public-key_signatures
 crypto_box_seal     | 🚧 | 🚧 | https://libsodium.gitbook.io/doc/public-key_cryptography/sealed_boxes
 crypto_generichash  | 🚧 | 🚧 | https://libsodium.gitbook.io/doc/hashing/generic_hashing
 crypto_shorthash    | 🚧 | 🚧 | https://libsodium.gitbook.io/doc/hashing/short-input_hashing
 crypto_pwhash       | ✔️ | ✔️ | https://libsodium.gitbook.io/doc/password_hashing/default_phf
 crypto_kdf          | 🚧 | 🚧 | https://libsodium.gitbook.io/doc/key_derivation
 crypto_kx           | 🚧 | 🚧 | https://libsodium.gitbook.io/doc/key_exchange
 crypto_scalarmult   | 🚧 | 🚧 | https://libsodium.gitbook.io/doc/advanced/scalar_multiplication
 crypto_onetimeauth  | 🚧 | 🚧 | https://libsodium.gitbook.io/doc/advanced/poly1305
 crypto_aead         | ❔  | ❔  | https://libsodium.gitbook.io/doc/secret-key_cryptography/aead
 crypto_hash_sha     | ❔  | ❔  | https://libsodium.gitbook.io/doc/advanced/sha-2_hash_function
 crypto_auth_hmacsha | ❔  | ❔  | https://libsodium.gitbook.io/doc/advanced/hmac-sha2

**Note:** Memory Management in JS is limited to overwriting the memory with 0. 
All other Memory-APIs are only available in the VM.

## Installation
Simply add `sodium` to your `pubspec.yaml` and run `pub get` (or `flutter pub get`).

## Usage
The usage can be split into two parts. The first one is about loading the native
libsodium into dart, the second one about using the API.

### Loading libsodium
How you load the library depends on whether you are running in the dart VM or
as transpiled JS code.

**Note:** For flutter users, there is a another library in the making that will
completely automate this part.

#### VM - loading the dynamic library
In the dart VM, `dart:ffi` is used as backend to load and interact with the
libsodium binary. So, all you need to do is load such a library and then pass
it to the sodium APIs. This generally looks like this:

```.dart
// required imports
import 'dart:ffi';
import 'package:sodium/sodium.dart';

// load the dynamic library into dart
final libsodium = DynamicLibrary.open('/path/to/libsodium.XXX'); // or DynamicLibrary.process()

// initialize the sodium APIs
final sodium = await SodiumInit.init(libsodium);
```

The tricky part here is the path, aka `'/path/to/libsodium.XXX'`. It depends on
the platform and how you intend to use the library. My recommendation is to
follow https://libsodium.gitbook.io/doc/installation to get the library binary
for your platform and then pass the correct path. If you are linking statically,
you can use `DynamicLibrary.process()` (except on windows) instead of the path.

However, here are some tips on how to get the library for some platforms and
how to load it there:
- **Linux**: Install `libsodium` via your system package manager. Then, you can load
the `libsodium.so` from where the package manager put it.
- **Windows**: Download the correct binary from 
https://download.libsodium.org/libsodium/releases/ and simply use the path where
you placed the library.
- **macOS**: Use homebrew and run `brew install libsodium` - then locate the binary
in the Cellar. It is typically something like 
`/usr/local/Cellar/libsodium/<version>/lib/libsodium.dylib`.
- **Android**: Coming soon...
- **iOS**: Coming soon...

#### Transpiled JavaScript - loading the JavaScript code.
The correct setup depends on your JavaScript environment (i.e. browser, nodejs,
...) - however, the general way is the same:

```.dart
// required imports
import 'package:sodium/sodium.dart';

final sodiumJS = // somehow load the sodium.js into dart

// initialize the sodium APIs
final sodium = await SodiumInit.init(sodiumJS);
```

The complex part is how to load the library into dart. Generally, you can refer
to https://github.com/jedisct1/libsodium.js/#installation on how to load the
library into your JS environment. However, since we are running JavaScript code,
the setup is a little more complex.

The only platform I have tried so far is the browser. However, similar 
approches should work for all JS environments that you can run transpiled dart
code in.

##### Loading sodium.js into the browser via dart.
The idea here is, that the dart code asynchronously loads the `sodium.js` into
the browser and then acquires the result of loading it (As recommended in 
https://github.com/jedisct1/libsodium.js/#usage-in-a-web-browser-via-a-callback
). The following code uses the [`package:js`](https://pub.dev/packages/js) to 
interop with JavaScript and perform these steps. You can download the
`sodium.js` file from here: 
https://github.com/jedisct1/libsodium.js/tree/master/dist/browsers

```.dart
// make the dart library JS-interoperable
@JS()
library interop;

// required imports
import 'package:js/js.dart';
import 'package:sodium/sodium.dart';

// declare a JavaScript type that will provide the callback for the loaded
// sodium JavaScript object.
@JS()
@anonymous
class SodiumBrowserInit {
  external void Function(dynamic sodium) get onload;

  external factory SodiumBrowserInit({void Function(dynamic sodium) onload});
}

Future<Sodium> loadSodiumInBrowser() async {
  // create a completer that will wait for the library to be loaded
  final completer = Completer<dynamic>();

  // Set the global `sodium` property to our JS type, with the callback beeing
  // redirected to the completer
  setProperty(window, 'sodium', SodiumBrowserInit(
    onload: allowInterop(completer.complete),
  ));
  
  // Load the sodium.js into the page by appending a `<script>` element
  final script = ScriptElement();
  script
    ..type = 'text/javascript'
    ..async = true
    ..src = 'sodium.js'; // use the path where you put the file on your server
  document.head!.append(script);

  // await the completer
  final dynamic sodiumJS = await completer.future;

  // initialize the sodium APIs
  return SodiumInit.init(sodiumJS);
```

### Using the API
Once you have acquired the `Sodium` instance, usage is fairly straight forward.
The API mirrors the original native C api, splitting different categories of
methods into different classes for maintainability, which are all built up in
hierachical order starting at `Sodium`. For example, if you wanted to use the
`crypto_secretbox_easy` method from the C api, the eqivalent dart code would be:

```.dart
final sodium = // load libsodium for your platform

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

The only main differences here are, that instead of raw pointers, the dart typed
lists are used. Also, instead of simply passing a byte array as the key, the
`SecureKey` is used. It is a special class created for this library that wraps
native memory, thus providing a secure way of keeping your keys in memory. You
can either create such keys via the `*_keygen` methods, or directly via
`sodium.secure*`.

**Note:** Since these keys wrap native memory, it is mandatory that you dispose
of them after you are done with a key, as otherwise they will leak memory.

## Documentation
The documentation is available at https://pub.dev/documentation/sodium/latest/. A full example can be found at https://pub.dev/packages/sodium/example.

The example runs both in the VM and on the web. To use it, see below.

As preparation for all platforms, run the following steps:
```.sh
cd packages/sodium
dart pub get
dart run build_runner build
```

### Example for the dart VM
Locate/Download the libsodium binrary and run the example with it:

```.sh
cd packages/sodium/example
dart pub get
dart run bin/main_native.dart '/path/to/libsodium.XXX'
```

### Example in the browser
First download `sodium.js` into the examples web directory. Then simply run the 
example:

```.sh
dart pub global activate webdev

cd packages/sodium/example/web
curl -Lo sodium.js https://raw.githubusercontent.com/jedisct1/libsodium.js/master/dist/browsers/sodium.js

cd ..
dart pub get
dart pub global run webdev serve --release
# Visit http://127.0.0.1:8080 in the browser
```