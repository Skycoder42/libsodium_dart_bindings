# sodium_libs
[![Continous Integration for package sodium_libs](https://github.com/Skycoder42/libsodium_dart_bindings/actions/workflows/sodium_libs_ci.yaml/badge.svg)](https://github.com/Skycoder42/libsodium_dart_bindings/actions/workflows/sodium_libs_ci.yaml)
[![Pub Version](https://img.shields.io/pub/v/sodium_libs)](https://pub.dev/packages/sodium_libs)

Flutter companion package to [sodium](https://pub.dev/packages/sodium) that provides the low-level libsodium binaries
for easy use.

## Table of contents
- [Features](#features)
- [Installation](#installation)
  * [iOS](#ios)
  * [Linux](#linux)
  * [Windows](#windows)
  * [Web](#web)
- [Usage](#usage)
- [Documentation](#documentation)

<small><i><a href='https://ecotrust-canada.github.io/markdown-toc/'>Table of contents generated with markdown-toc</a></i></small>

## Features
- Extends [sodium](https://pub.dev/packages/sodium) for Flutter with binaries
- Easy, effort-less initialization on all major flutter platforms (Android, iOS, Linux, Windows, macOS, Web)
- Binaries are either directly included or automatically downloaded/built at compile time

**Note:** This package only handles the libsodium binaries for each supported platform and provides them to
[sodium](https://pub.dev/packages/sodium). Check the documentation of that package for more details about the actual
APIs.

## Installation
Simply add `sodium_libs` to your `pubspec.yaml` and run `pub get` (or `flutter pub get`).

### Web
When working with flutter for web, an additional install step is needed, as for web, the JS-library cannot directly be
bundled with the library. For it to work, [`sodium.js`](https://github.com/jedisct1/libsodium.js) must be added to the
project. You can do this automatically by running the following command in every new project.

```.sh
flutter pub run sodium_libs:update_web [--sumo] [--no-edit-index] [<target_directory>]
```

The `--sumo` parameter is optional. If specified, the Sumo-Variant of sodium.js will be downloaded. It is bigger in
size, but contains all APIs. With the non-sumo version, you can only use `SodiumInit.init`, which should suffice for
most usecases. However, if you need access to the `SodiumSumo`-APIs and thus need to invoke `SodiumSumoInit.init`, you
have to make sure to add this parameter.

By default, the `index.html` is modified to automatically load the `sodium.js` before the flutter app starts. This leads
to a faster initialization of the app and allows debugging. To disable this behavior, you can set the `--no-edit-index`
parameter.

Finally, if your web project files are for whatever reason not located in the `web` directory, you can set a custom
directory.

### Linux
When working with linux, you can **optionally** decide to use `pkg-config` for resolving libsodium instead of using the
bundled library. This will cause the linux build to link against the system library instead of the embedded one,
providing it is installed.

To enable this mode, simply set the `LIBSODIUM_USE_PKGCONFIG` environment variable to anything but an empty value
before compiling. Example:

```bash
export LIBSODIUM_USE_PKGCONFIG=1
flutter clean # recommended to ensure no build artifacts are cached
flutter build linux
```

## Usage
The API can be consumed in the exact same way as the `sodium` package. The only difference is, that `sodium_libs`
simplifies the initialization of that package. To initialize it, simply do the following:

```dart
import 'package:sodium_libs/sodium_libs.dart';

// when used before rendering the first frame:
WidgetsFlutterBinding.ensureInitialized();

final sodium = await SodiumInit.init();
// You now have a Sodium instance, see sodium package to continue
```

In case you want to use the `SodiumSumo` APIs, use the following instead. Also, remember to initialize web projects with
`--sumo`, as otherwise the initialization will fail.

```dart
import 'package:sodium_libs/sodium_libs_sumo.dart';

// when used before rendering the first frame:
WidgetsFlutterBinding.ensureInitialized();

final sodium = await SodiumSumoInit.init();
// You now have a SodiumSumo instance, see sodium package to continue
```

See (Sodium vs SodiumSumo)[https://github.com/Skycoder42/libsodium_dart_bindings/blob/main/packages/sodium/README.md#sodium-vs-sodiumsumo]
for more details on the differences between those two variants.

## Documentation
The documentation is available at https://pub.dev/documentation/sodium_libs/latest/. A full example can be found at
https://pub.dev/packages/sodium_libs/example.
