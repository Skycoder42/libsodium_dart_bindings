# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.1+1] - 2023-03-09
### Fixed
- Fixed invalid publishing config that prevented android binaries from beeing published

## [2.0.1] - 2023-03-09
### Changed
- The plugin now does not call `WidgetsFlutterBinding.ensureInitialized();` anymore. Instead, you have to do so yourself
in case you need to initialize sodium before the first frame is rendered. See README for more details (#24)
- Depends on sodium version 2.1.0
- Set minimum required dart SDK version to 2.19.0
- Set minimum required flutter SDK version to 3.7.0
- Update dependencies

## [2.0.0] - 2022-10-23
### Added
- Added support for loading the `SodiumSumo` interface via `SodiumSumoInit.init`
  - All native platforms (android, ios, linux, windows, macos) support the new APIs
  - The web-platform also supports this, as long as it was initialized with `--sumo`

### Changed
- **Breaking:** Depends on sodium version 2.0.0
  - Check that release for more details on all of the changes in that release.
- **Breaking:** Added `loadSodiumSumo` to `SodiumPlatform` interface

## [1.2.5+1] - 2022-09-14
### Changed
- Update README

## [1.2.5] - 2022-09-13
### Added
- The web variant will now check if sodium.js was already loaded before attempting to add the `<script>` element to
the page
- The `update_web` command will now add a `<script>` element to the `<head>` of your `index.html`
  - Speeds up page loads
  - Fixes problems with debugging flutter web applications
  - Can be disabled by passing the `--no-edit-index` flag to `update_web`

### Changed
- Updated minimum required `sodium` version to 1.2.4

### Fixed
- Debugging flutter web applications now works, as long as the `sodium.js` library is preloaded
  - Simply run `dart run sodium_libs:update_web` again on your project to automatically update your `index.html` to
  preload `sodium.js`

## [1.2.4+2] - 2022-09-07
### Changed
- Update dependencies
- Set minimum required dart SDK version to 2.18.0
- Set minimum required flutter SDK version to 3.3.0

## [1.2.4+1] - 2022-08-19
### Fixed
- use pubspec\_overrides.yaml for development to ensure all overrides are removed before deploying to pub.dev

## [1.2.4] - 2022-08-18
### Changed
- Updated minimum required `sodium` version to 1.2.3
- Updated dependencies
- Deploy full android native libraries (#15)

## [1.2.3] - 2022-05-27
### Changed
- Updated minimum required dart version to 1.17.0
- Updated minimum required flutter version to 3.0.0
- Updated minimum required `sodium` version to 1.2.2
- Updated dependencies

## [1.2.2] - 2022-04-27
### Changed
- updated referenced libsodium.js to version 0.7.10
  - integration tests now run this version
  - the `update_web` command will now download this version

## [1.2.1] - 2022-04-14
### Fixed
- Windows: Invoke dart via CMD in CMake to prevent problems on Windows 11 (#9)

## [1.2.0] - 2022-01-05
### Added
- Added support for the Sumo-Version of sodium.js (#4)

### Changed
- Changed dependency requirements
  - Set minimum required dart SDK version to 2.15
  - Set minimum required flutter SDK version to 2.8
  - Updated minimum required `sodium` version to 1.2.0+2
  - Updated dependencies
- Use newer platform setups of flutter 2.8
- Replaced `lint` with `dart_test_tools` which makes the default rules of `lint` even more strict
- Refactored test setup tooling
- Windows builds now required `dart` to be in the PATH (should be like that per default)

### Deprecated
- `SodiumInit.ensurePlatformRegistered` is no longer needed, as platform registration now works automatically

### Fixed
- Fix formatting and linter issues with the newer dart SDK & dependencies
- Removed unused native code
- Added README hint on how to use the library on iOs Simulators

### Removed
- Various internal APIs have been removed

## [1.1.1] - 2021-08-26
### Changed
- `SodiumInit.init` now automatically handles multiple initializations and no longer requires the `initNative` parameter for consecutive invocations (#3)
- Updated minimum required `sodium` version to `1.1.1`

### Deprecated
- The `initNative` parameter of `SodiumInit.init` has been deprecated as it no longer has any effect (#3)

## [1.1.0] - 2021-08-17
### Added
- `SodiumInit.init` can now be called with `initNative: false` to disable initialization of the native library, in case it has already been initialized

### Changed
- Updated minimum required `sodium` version to `1.1.0`

## [1.0.1] - 2021-07-13
### Fixed
- Make links in README secure (pub.dev score)
- Use longer package description (pub.dev score)

## [1.0.0] - 2021-07-13
### Added
- Initial stable release

[2.0.1+1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.0.1...sodium_libs-v2.0.1+1
[2.0.1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs%2Fv2.0.0...sodium_libs-v2.0.1
[2.0.0]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs%2Fv1.2.5+1...sodium_libs%2Fv2.0.0
[1.2.5+1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs%2Fv1.2.5...sodium_libs%2Fv1.2.5+1
[1.2.5]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs%2Fv1.2.4+2...sodium_libs%2Fv1.2.5
[1.2.4+2]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs%2Fv1.2.4+1...sodium_libs%2Fv1.2.4+2
[1.2.4+1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs%2Fv1.2.4...sodium_libs%2Fv1.2.4+1
[1.2.4]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs%2Fv1.2.3...sodium_libs%2Fv1.2.4
[1.2.3]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs%2Fv1.2.2...sodium_libs%2Fv1.2.3
[1.2.2]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs%2Fv1.2.1...sodium_libs%2Fv1.2.2
[1.2.1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs%2Fv1.2.0...sodium_libs%2Fv1.2.1
[1.2.0]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs%2Fv1.1.1...sodium_libs%2Fv1.2.0
[1.1.1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs%2Fv1.1.0...sodium_libs%2Fv1.1.1
[1.1.0]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs%2Fv1.0.1...sodium_libs%2Fv1.1.0
[1.0.1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs%2Fv1.0.0...sodium_libs%2Fv1.0.1
[1.0.0]: https://github.com/Skycoder42/libsodium_dart_bindings/releases/tag/sodium_libs%2Fv1.0.0