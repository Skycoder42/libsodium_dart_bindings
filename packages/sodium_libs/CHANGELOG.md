# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.4.7] - 2025-08-06
### Changed
- Updated min sdk version to ^3.8.0
- Updated min flutter version to ^3.32.0
- Updated dependencies

## [3.4.6+1] - 2025-08-05
### Changed
- Updated embedded libsodium binaries

## [3.4.6] - 2025-07-23
### Changed
- Updated dependencies
- Updated min dart sdk to 3.8.0
- Updated min flutter sdk to 3.32.0
- Updated min sodium version to 3.4.6

## [3.4.5+2] - 2025-06-17
### Changed
- Updated embedded libsodium binaries

## [3.4.5+1] - 2025-05-27
### Changed
- Updated embedded libsodium binaries

## [3.4.5] - 2025-05-13
### Fixed
- Fixed typo in pkgconfig check for linux build (#156, #157)

## [3.4.4+5] - 2025-05-13
### Changed
- Updated embedded libsodium binaries

## [3.4.4+4] - 2025-05-06
### Changed
- Updated embedded libsodium binaries

## [3.4.4+3] - 2025-04-29
### Changed
- Updated embedded libsodium binaries

## [3.4.4+2] - 2025-04-08
### Changed
- Updated embedded libsodium binaries

## [3.4.4+1] - 2025-03-16
### Changed
- Update native dependencies for flutter 3.29.0

## [3.4.4] - 2025-03-16
### Changed
- Updated dependencies
- Updated min dart sdk to 3.7.0
- Updated min flutter sdk to 3.29.0
- Updated min sodium version to 3.4.5
- Updated embedded libsodium binaries

## [3.4.3+2] - 2025-02-25
### Changed
- Updated embedded libsodium binaries

## [3.4.3+1] - 2025-01-21
### Changed
- Updated embedded libsodium binaries

## [3.4.3] - 2025-01-08
### Fixed
- Explicitly request dart.bat on windows hosts (#140)
- Detect dart path for android gradle builds via local.properties (#140)

## [3.4.2] - 2025-01-02
### Fixed
- Fixed dart path in windows CMake (#140)

## [3.4.1+2] - 2025-01-02
### Changed
- Switched to zip archives for embedded libsodium binaries to ensure windows compatibility (#142)

## [3.4.1+1] - 2024-12-31
### Changed
- Updated embedded libsodium binaries

## [3.4.1] - 2024-12-28
### Added
- Added swift package manager support

### Changed
- Updated dependencies
- Updated min dart sdk to 3.6.0
- Updated min flutter sdk to 3.27.0
- Updated min sodium version to 3.4.4
- Updated embedded libsodium binaries

### Fixed
- Fixed detection of dart tool for CMake based platforms (#140)

## [3.4.0+1] - 2024-12-10
### Changed
- Updated embedded libsodium binaries

## [3.4.0] - 2024-12-05
### Changed
- Refactor `sodium_libs` to dynamically download libsodium during the build
  - This was required for iOS/macOS because of #135
  - Introduced for all platforms to keep it consistent
  - sha512sums of the binaries are embedded into the package and validated at build time

## [3.3.1] - 2024-12-03
### Fixed
- Download framework via Podfile for darwin targets (#135)
  - Is required because pub.dev does not support directory symlinks, which are required for macOS
  - Fix is temporary and will cause the build to break if the release binaries are updated. Proper fix will come soon.

## [3.3.0+4] - 2024-12-01
### Fixed
- Fixed invalid framework anatomy for macOS framework (#135)

## [3.3.0+3] - 2024-11-26
### Changed
- Updated dependencies
- Updated min sodium version to 3.4.3
  - Includes important bug fix

## [3.3.0+2] - 2024-11-05
### Changed
- Update embedded libsodium binaries

## [3.3.0+1] - 2024-10-29
### Changed
- Update embedded libsodium binaries

## [3.3.0] - 2024-10-21
### Added
- Run integration tests via firebase test labs

### Changed
- Updated dependencies
- Update embedded libsodium binaries
- Updated min sodium version to 3.4.0
  - This includes the newly added low level isolate APIs

### Removed
- Removed BrowserStack integration tests as, BrowserStack does not sponsor
App Automate

## [3.2.0+2] - 2024-09-24
### Changed
- Update embedded libsodium binaries

## [3.2.0+1] - 2024-08-22
### Changed
- Improved documentation
- Updated dev dependencies
- Fix linter issues

## [3.2.0] - 2024-08-18
### Changed
- Updated min sodium version to 3.2.0
  - This includes the newly added `pushChunked` and `pullChunked` APIs

## [3.0.0] - 2024-08-15
### Changed
- Updated dependencies
- Updated min dart sdk to 3.5.0
- Updated min flutter sdk to 3.24.0
- Updated min sodium version to 3.0.1
- Updated embedded libsodium to version 1.0.20 (0.7.14 for JS)
- **\[BREAKING\]** Updated min Android SDK level to 21
- Unified iOS and macOS plugin code
  - Uses xcframwork with embedded frameworks for both
  - Supported platforms have not changed
- \~\~Run Android/iOS Integration tests via https://www.browserstack.com/\~\~
  - \~\~Special thanks to BrowserStack for sponsoring this project with a free subscription to App Automate!\~\~

## [2.2.1+6] - 2024-06-11
### Changed
- Update embedded libsodium binaries

## [2.2.1+5] - 2024-05-21
### Changed
- Update embedded libsodium binaries

## [2.2.1+4] - 2024-05-14
### Changed
- Update embedded libsodium binaries

## [2.2.1+3] - 2024-05-08
### Changed
- Update embedded libsodium binaries

## [2.2.1+2] - 2024-05-07
### Changed
- Update embedded libsodium binaries

## [2.2.1+1] - 2024-03-26
### Changed
- Update embedded libsodium binaries

## [2.2.1] - 2024-03-12
### Changed
- Update dependencies
- Update min dart sdk to 3.3.0
- Update min flutter sdk to 3.19.0
- Update min sodium version to 2.3.1
- Update embedded libsodium binaries

## [2.2.0+11] - 2024-02-05
### Fixed
- Make compatible with cider 0.2.6

## [2.2.0+10] - 2024-01-23
### Changed
- Update embedded libsodium binaries

## [2.2.0+9] - 2024-01-16
### Changed
- Update embedded libsodium binaries

## [2.2.0+8] - 2024-01-09
### Changed
- Update embedded libsodium binaries

## [2.2.0+7] - 2023-12-20
### Changed
- Update embedded libsodium binaries

## [2.2.0+6] - 2023-11-28
### Changed
- Update embedded libsodium binaries

## [2.2.0+5] - 2023-11-14
### Changed
- Update embedded libsodium binaries

## [2.2.0+4] - 2023-11-07
### Changed
- Update embedded libsodium binaries

## [2.2.0+3] - 2023-10-31
### Changed
- Update embedded libsodium binaries

## [2.2.0+2] - 2023-10-24
### Changed
- Update embedded libsodium binaries

## [2.2.0+1] - 2023-10-10
### Changed
- Update embedded libsodium binaries

## [2.2.0] - 2023-09-23
### Added
- Added embedded binaries for linux
  - Optional, pkgconfig build is still supported, but not the default anymore
  - Currently, `x86_64` and `aarch64` are supported

### Changed
- Update embedded libsodium to version 1.0.19
- Update dependencies
- Update min sodium version to 2.3.0
- Update tooling for building libsodium in the CI

## [2.1.2+2] - 2023-09-19
### Changed
- Update embedded libsodium binaries

## [2.1.2+1] - 2023-09-12
### Changed
- Update embedded libsodium binaries

## [2.1.2] - 2023-09-07
### Changed
- Update dependencies
- Update min required dart SDK to 3.1.0
- Update min required flutter SDK to 3.13.0
- Update min sodium version to 2.1.2
- Update embedded libsodium binaries

## [2.1.1+3] - 2023-08-15
### Changed
- Update embedded libsodium binaries

## [2.1.1+2] - 2023-07-25
### Changed
- Update embedded libsodium binaries

## [2.1.1+1] - 2023-06-28
### Changed
- Update embedded libsodium binaries

## [2.1.1] - 2023-06-07
### Changed
- Update dependencies
- Update min dart sdk to 3.0.0
- Update min flutter sdk to 3.10.0
- Update min sodium version to 2.1.1
- Update embedded libsodium binaries

## [2.1.0+1] - 2023-03-26
### Changed
- Update embedded libsodium binaries

## [2.1.0] - 2023-03-24
### Changed
- macOs and iOs now use embedded libsodium binaries instead of depending on Swift-Sodium
  - This "unlocks" all libsodium APIs
  - Upstream changes to libsodium can be updated easier and faster
- Windows now uses an embedded libsodium instead of downloading it at build time
  - minisign is not needed anymore for the build
  - build is more robust and upstream changes can be distributed more easily
- Improve libsodium integration so stable upstream changes are available faster for the package

## [2.0.1+1] - 2023-03-09
### Fixed
- Fixed invalid publishing config that prevented android binaries from being published

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

[3.4.7]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.4.6+1...sodium_libs-v3.4.7
[3.4.6+1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.4.6...sodium_libs-v3.4.6+1
[3.4.6]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.4.5+2...sodium_libs-v3.4.6
[3.4.5+2]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.4.5+1...sodium_libs-v3.4.5+2
[3.4.5+1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.4.5...sodium_libs-v3.4.5+1
[3.4.5]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.4.4+5...sodium_libs-v3.4.5
[3.4.4+5]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.4.4+4...sodium_libs-v3.4.4+5
[3.4.4+4]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.4.4+3...sodium_libs-v3.4.4+4
[3.4.4+3]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.4.4+2...sodium_libs-v3.4.4+3
[3.4.4+2]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.4.4+1...sodium_libs-v3.4.4+2
[3.4.4+1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.4.4...sodium_libs-v3.4.4+1
[3.4.4]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.4.3+2...sodium_libs-v3.4.4
[3.4.3+2]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.4.3+1...sodium_libs-v3.4.3+2
[3.4.3+1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.4.3...sodium_libs-v3.4.3+1
[3.4.3]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.4.2...sodium_libs-v3.4.3
[3.4.2]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.4.1+2...sodium_libs-v3.4.2
[3.4.1+2]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.4.1+1...sodium_libs-v3.4.1+2
[3.4.1+1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.4.1...sodium_libs-v3.4.1+1
[3.4.1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.4.0+1...sodium_libs-v3.4.1
[3.4.0+1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.4.0...sodium_libs-v3.4.0+1
[3.4.0]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.3.1...sodium_libs-v3.4.0
[3.3.1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.3.0+4...sodium_libs-v3.3.1
[3.3.0+4]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.3.0+3...sodium_libs-v3.3.0+4
[3.3.0+3]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.3.0+2...sodium_libs-v3.3.0+3
[3.3.0+2]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.3.0+1...sodium_libs-v3.3.0+2
[3.3.0+1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.3.0...sodium_libs-v3.3.0+1
[3.3.0]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.2.0+2...sodium_libs-v3.3.0
[3.2.0+2]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.2.0+1...sodium_libs-v3.2.0+2
[3.2.0+1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.2.0...sodium_libs-v3.2.0+1
[3.2.0]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v3.0.0...sodium_libs-v3.2.0
[3.0.0]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.2.1+6...sodium_libs-v3.0.0
[2.2.1+6]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.2.1+5...sodium_libs-v2.2.1+6
[2.2.1+5]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.2.1+4...sodium_libs-v2.2.1+5
[2.2.1+4]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.2.1+3...sodium_libs-v2.2.1+4
[2.2.1+3]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.2.1+2...sodium_libs-v2.2.1+3
[2.2.1+2]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.2.1+1...sodium_libs-v2.2.1+2
[2.2.1+1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.2.1...sodium_libs-v2.2.1+1
[2.2.1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.2.0+11...sodium_libs-v2.2.1
[2.2.0+11]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.2.0+10...sodium_libs-v2.2.0+11
[2.2.0+10]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.2.0+9...sodium_libs-v2.2.0+10
[2.2.0+9]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.2.0+8...sodium_libs-v2.2.0+9
[2.2.0+8]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.2.0+7...sodium_libs-v2.2.0+8
[2.2.0+7]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.2.0+6...sodium_libs-v2.2.0+7
[2.2.0+6]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.2.0+5...sodium_libs-v2.2.0+6
[2.2.0+5]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.2.0+4...sodium_libs-v2.2.0+5
[2.2.0+4]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.2.0+3...sodium_libs-v2.2.0+4
[2.2.0+3]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.2.0+2...sodium_libs-v2.2.0+3
[2.2.0+2]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.2.0+1...sodium_libs-v2.2.0+2
[2.2.0+1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.2.0...sodium_libs-v2.2.0+1
[2.2.0]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.1.2+2...sodium_libs-v2.2.0
[2.1.2+2]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.1.2+1...sodium_libs-v2.1.2+2
[2.1.2+1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.1.2...sodium_libs-v2.1.2+1
[2.1.2]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.1.1+3...sodium_libs-v2.1.2
[2.1.1+3]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.1.1+2...sodium_libs-v2.1.1+3
[2.1.1+2]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.1.1+1...sodium_libs-v2.1.1+2
[2.1.1+1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.1.1...sodium_libs-v2.1.1+1
[2.1.1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.1.0+1...sodium_libs-v2.1.1
[2.1.0+1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.1.0...sodium_libs-v2.1.0+1
[2.1.0]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium_libs-v2.0.1+1...sodium_libs-v2.1.0
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
