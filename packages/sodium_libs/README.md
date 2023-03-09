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

In addition to installing the package, you will also have to install operating system specific tools for some platforms.

### iOS
Currently, there is a [Bug in the upstream Swift-Sodium package](https://github.com/jedisct1/swift-sodium/issues/251)
that prevents the library from being run on an iOs simulator with XCode 12 or higher. As a temporary workaround, you
have to add the following snippet to your `Podfile` in order to make it work. This will overwrite the required settings
in the dependencies until fixed upstream:

```Podfile
post_install do |installer|
  # You might already have code here. Keep that as is

  # Workaround for https://github.com/jedisct1/swift-sodium/issues/251
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end
```

### Linux
You have to install [libsodium](https://github.com/jedisct1/libsodium) on your system. How you do this depends on your
distribution:
- Arch/Manjaro: `[sudo] pacman -S libsodium`
- Ubuntu/Debian: `[sudo] apt install libsodium-dev`
- ...

When bundeling the application for release, remember to also include the `libsodium.so` into the deployment package.

### Windows
Since the plugin downloads the binaries at build time, it needs [minisign](https://jedisct1.github.io/minisign/) to
validate their integrity. The easiest way to install minisign is via [Chocolatey](https://chocolatey.org/install):

```ps1
choco install minisign
```

### Web
The web setup differs slightly from the others. Instead of just installing some system library or tool, you need to add
[`sodium.js`](https://github.com/jedisct1/libsodium.js) to each project. You can do this automatically by running the
following command in every new project.

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

## Documentation
The documentation is available at https://pub.dev/documentation/sodium_libs/latest/. A full example can be found at
https://pub.dev/packages/sodium_libs/example.
