# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2023-03-08
### Added
- `SodiumInit.init2` and `SodiumSumoInit.init2` - these methods replace the now deprecated `.init` methods (#24)
  - This change was made to support the new `Sodium.runIsolated` APIs
  - The new variants take callbacks instead of the already resolved binaries
  - Your implementation should move the logic to load said binaries into these callbacks to allow the use of isolates.
  - Check the README, the example and the documentation for more details
- `KeyPair.copy` and `KeyPair.dispose` methods to copy and dispose a key pair (#24)
- `Sodium.runIsolated` method to allow execution of cryptographic operations on a separate isolate (#24)

### Changed
- Set minimum required dart SDK version to 2.19.0
- Update dependencies

### Deprecated
- The `sodium.crypto.pwhash` API has been deprecated for **non sumo variants** of sodium
  - The `SodiumSumo` APIs still fully support `pwhash`
  - However, the simple `Sodium` APIs do not anymore
  - This is due to upstream changes in `sodium.js`, as there the `pwhash` APIs have been mode to the sumo variant of
  this library. If you use the library with the newest non sumo sodium.js, trying to use the `pwhash` APIs will throw
  an exception!
  - If you need the `pwhash` APIs, simply switch to using the sumo variant of the library
- `SodiumInit.init` - use `SodiumInit.init2` instead for support of the new `Sodium.runIsolated` APIs (#24)
- `SodiumSumoInit.init` - use `SodiumSumoInit.init2` instead for support of the new `Sodium.runIsolated` APIs (#24)

### Removed
- Removed the experimental `Sodium.secureHandle`, `SecureKey.fromNativeHandle` and `SecureKey.nativeHandle` APIs (#24)
  - They are not needed anymore to work around isolate limitations, as you can simply use `Sodium.runIsolated` instead

## [2.0.1] - 2022-12-07
### Fixed
- Implemented temporary workaround for #22 until https://github.com/flutter/flutter/issues/116405 is fixed

## [2.0.0] - 2022-10-23
### Added
- Added new `SodiumSumo` class that extends the basic sodium APIs with advanced APIs.
  - **Important:** On some platforms this requires you to use a different binary
  - The new variant is available via the `package:sodium/sodium_sumo.dart` import and can be initialized with
  `SodiumSumoInit.init`
- Added `crypto.scalarmult` as sumo interface for https://libsodium.gitbook.io/doc/advanced/scalar\_multiplication
- Extended `crypto.sign` as sumo interface

### Changed
- **Breaking:** Moved the `Sign.skToSeed` and `Sign.skToPk` methods into `SignSumo`

### Removed
- Removed all previously deprecated APIs

## [1.2.5] - 2022-09-26
### Fixed
- Fixed performance issue that caused the "dart -> native" copy process of bytes to take extremely long (#19)

## [1.2.4] - 2022-09-13
### Added
- Let `GenericHashConsumer` implement `Sink` to allow synchronous adding of data
- Let `SignatureConsumer` implement `Sink` to allow synchronous adding of data
- Let `VerificationConsumer` implement `Sink` to allow synchronous adding of data

### Fixed
- Rename `JsError.wrap` to `jsErrorWrap` to prevent problems when debugging JS applications

## [1.2.3+1] - 2022-09-07
### Changed
- Update dependencies
- Set minimum required dart SDK version to 2.18.0

## [1.2.3] - 2022-08-18
### Changed
- Update dependencies
- Activate stricter linter rules, fix resulting issues

## [1.2.2] - 2022-05-25
### Changed
- Add missing tests and coverage ignores

## [1.2.1] - 2022-05-25
### Changed
- Updated minimum required dart SDK to 1.17.0
- Refactor implementation to make use of newly added ABI-specific integers
  - Makes the library more robust on non x64 platforms
  - Future-proof if new platforms are added

## [1.2.0+2] - 2022-01-25
### Changed
- Replaced `lint` with `dart_test_tools` which makes the default rules of `lint` even more strict
- Refactored test setup tooling

## [1.2.0+1] - 2022-01-14
### Changed
- Set minimum required dart SDK version to 2.15
- Updated dependencies

## [1.2.0] - 2021-11-26
### Added
- Support for 32bit architectures by generalizing the native FFI bindings (#7)

### Changed
- Set minimum required dart SDK version to 2.14
- Updated dependencies
- Upgraded dart ffi language bindings
- Use new callable workflows for workflow simplification

### Fixed
- Fix formatting and linter issues with the newer dart SDK & dependencies

## [1.1.2] - 2021-09-03
### Added
- Added missing `skToSeed` and `skToPk` methods to `crypto.sign` (#4)

## [1.1.1] - 2021-08-26
### Changed
- `SodiumInit.init` now automatically handles multiple initializations and no longer requires the `initNative` parameter for consecutive invocations (#3)

### Deprecated
- The `initNative` parameter of `SodiumInit.init` has been deprecated as it no longer has any effect (#3)

## [1.1.0] - 2021-08-17
### Added
- `SecureKey.split` extension that allows to split one key into multiple (#2)
- `SecureKey.nativeHandle` and `SecureKey.fromNativeHandle` to allow passing secure keys across isolate boundaries
- `SodiumInit.init` can now be called with `initNative: false` to disable initialization of the native library, in case it has already been initialized

## [1.0.0] - 2021-07-08
### Added
- Initial stable release

[2.1.0]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium%2Fv2.0.1...sodium-v2.1.0
[2.0.1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium%2Fv2.0.0...sodium%2Fv2.0.1
[2.0.0]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium%2Fv1.2.5...sodium%2Fv2.0.0
[1.2.5]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium%2Fv1.2.4...sodium%2Fv1.2.5
[1.2.4]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium%2Fv1.2.3+1...sodium%2Fv1.2.4
[1.2.3+1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium%2Fv1.2.3...sodium%2Fv1.2.3+1
[1.2.3]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium%2Fv1.2.2...sodium%2Fv1.2.3
[1.2.2]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium%2Fv1.2.1...sodium%2Fv1.2.2
[1.2.1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium%2Fv1.2.0+2...sodium%2Fv1.2.1
[1.2.0+2]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium%2Fv1.2.0+1...sodium%2Fv1.2.0+2
[1.2.0+1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium%2Fv1.2.0...sodium%2Fv1.2.0+1
[1.2.0]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium%2Fv1.1.2...sodium%2Fv1.2.0
[1.1.2]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium%2Fv1.1.1...sodium%2Fv1.1.2
[1.1.1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium%2Fv1.1.0...sodium%2Fv1.1.1
[1.1.0]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium%2Fv1.0.0...sodium%2Fv1.1.0
[1.0.0]: https://github.com/Skycoder42/libsodium_dart_bindings/releases/tag/sodium%2Fv1.0.0
