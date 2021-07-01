# sodium_libs
[![Continous Integration for package sodium_libs](https://github.com/Skycoder42/libsodium_dart_bindings/actions/workflows/sodium_libs_ci.yaml/badge.svg)](https://github.com/Skycoder42/libsodium_dart_bindings/actions/workflows/sodium_libs_ci.yaml)
[![Pub Version](https://img.shields.io/pub/v/sodium_libs)](https://pub.dev/packages/sodium_libs)

Flutter Companion-Package to [sodium](https://pub.dev/packages/sodium) that
provides the low-level libsodium binaries for easy use.

## Table of contents

## Features
- Extends [sodium](https://pub.dev/packages/sodium) for Flutter with binaries
- Easy, effort-less initialization on all major flutter platforms (Android, iOS,
Linux, Windows, macOS, Web)
- Binaries are either directly included or automatically downloaded/built at
compile time

**Note:** This package only handles the libsodium binaries for each supported
platform and provides them to [sodium](https://pub.dev/packages/sodium). Check
the documentation of that package for more details about the actual APIs.

## Installation
Simply add `sodium_libs` to your `pubspec.yaml` and run `pub get` (or 
`flutter pub get`).

### Platform requirements
In addition to installing the package, you will also have to install operating
system specific tools for some platforms:

### Linux
You have to install [libsodium](https://github.com/jedisct1/libsodium) on your
system. How you do this depends on your distribution:
- Arch/Manjaro: `sudo pacman -S libsodium`
- Ubuntu/Debian: `sudo apt install libsodium-dev`
- ...

### Windows
Since the plugin downloads the binaries at build time, it needs 
[minisign](https://jedisct1.github.io/minisign/) to validate their integrity.
The easiest way to install minisign is via 
[Chocolatey](https://chocolatey.org/install):

```.ps1
choco install minisign
```

### Web
TODO

## Usage
The API can be consumed in the excact same way as the `sodium` package. The only
difference is, that `sodium_libs` simplifies the initialization of that package.
To initialize it, simply do the following:

```.dart
import 'package:sodium_libs/sodium_libs.dart';

final sodium = await SodiumInit.init();
// You now have a Sodium instance, see sodium package to continue
```

## Documentation
The documentation is available at 
https://pub.dev/documentation/sodium_libs/latest/. A full example can be found 
at https://pub.dev/packages/sodium_libs/example.
