# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [3.4.7] - 2025-08-06
### Changed
- Updated min sdk version to ^3.8.0
- Updated dependencies

## [3.4.6] - 2025-07-23
### Changed
- Updated dependencies
- Updated min required dart SDK to 3.8.0

## [3.4.5] - 2025-03-16
### Changed
- Updated dependencies
  - Including freezed 3.0
- Updated min required dart SDK to 3.7.0

## [3.4.4] - 2024-12-28
### Changed
- Updated dependencies
- Updated min required dart SDK to 3.6.0

## [3.4.3] - 2024-11-26
### Changed
- Allow SecureKeys and KeyPairs to be disposed more then once

### Fixed
- Fixed crash when Uint8Lists are returned as isolate result (#134)
- Ensure keys are diposed as early as possible on isolates

## [3.4.2] - 2024-11-20
### Changed
- Updated dependencies

### Fixed
- Fixed wrong invalid buffer offset for `signedView()` and `unsignedView()`

## [3.4.1] - 2024-11-07
### Changed
- Improved performance by removing unnecessary byte array copies for output data
- Updated dependencies

## [3.4.0] - 2024-10-20
### Added
- Added low level isolate helpers

### Changed
- Updated dependencies

## [3.3.0] - 2024-09-20
### Added
- Added `crypto_sign_ed25519_pk_to_curve25519` and `crypto_sign_ed25519_sk_to_curve25519` sumo functions (#123)

### Changed
- Updated dependencies
- Improved isolate transfers for FFI secure keys
- Add finalization to JS secure keys if forgotten to dispose
- Exposed `ready` property on `LibSodiumJS`

## [3.2.0+1] - 2024-08-22
### Changed
- Improved documentation
- Updated dev dependencies
- Fix linter issues

## [3.2.0] - 2024-08-18
### Added
- Added `crypto.secretStream.pushChunked` and `crypto.secretStream.pullChunked`
  - Serve as a replacement for the deprecated `push` and `pull` APIs
  - Allow for a secure and bug-free encryption of files and other binary streams
  by requiring a `chunkSize` that is used to partition the incoming binary
  data into fix-sized chunks, just as the API expects.
- Added file encryption/decryption example

### Deprecated
- Deprecated  `crypto.secretStream.push` and `crypto.secretStream.pull`
  - These methods where error prone and hard to use, as the API assumes that
  the stream events are pre-chunked and "separate" from each other, while
  `Stream<List<int>>` in dart typically means an "arbitrary binary stream"
  - Use `pushChunked` and `pullChunked` as replacement
  - Related: #114, #52, #26

## [3.1.0] - 2024-08-15
### Fixed
- Added override for SodiumSumo.runIsolated that passes a SodiumSumo instance to the callback (#116)

## [3.0.1] - 2024-08-15
### Changed
- Updated min required dart SDK to 3.5.0
- Updated dependencies

## [3.0.0] - 2024-07-26
### Changed
- Updated min required dart SDK to 3.4.0
- Updated dependencies
- Updated expected libsodium version 1.0.20
- **\[BREAKING\]** Use `BigInt` for `crypto.kdf.deriveFromKey`s `subKeyId`
  - This ensure that 64bit integers can be used safely in the VM and JS
- Refactor JS implementation to use the new `dart:js\_interop` and `package:web` libraries
  - This ensures compatibility with WASM and modern dart/flutter
- Seal all data types

### Removed
- **\[BREAKING\]** Removed deprecations
  - Removed `pwhash` and `aead` from the non-sumo API
    - They still exist in the sumo API
  - Removed old `SodiumInit.init*` methods
    - The  `SodiumInit.init*2` methods have been renamed to remove the `2`

## [2.3.1+1] - 2024-03-12
### Fixed
- Fix pana linter issues

## [2.3.1] - 2024-03-12
### Changed
- Updated min required dart SDK to 3.3.0
- Updated dependencies

### Fixed
- Fixed deprecations

## [2.3.0+2] - 2024-02-05
### Fixed
- Make compatible with cider 0.2.6

## [2.3.0+1] - 2024-02-03
### Changed
- Updated dependencies

## [2.3.0] - 2023-09-23
### Changed
- Update supported libsodium version to 1.0.19
  - The library will still work with older versions, but it is recommended to upgrade your binaries to 1.0.19
  - Any modifications to the API in future versions may not be compatible with older versions of libsodium
- Update dependencies
- Update tooling for building libsodium in the CI

## [2.2.0] - 2023-09-12
### Added
- Add implementation for `crypto_aead_chacha20poly1305` as `sodium.crypto.aeadChaCha20Poly1305`. (#61)

### Changed
- `sodium.crypto.aead` has been renamed to `sodium.crypto.aeadXChaCha20Poly1305IETF`. The implementation has not
changed, only the name of the getter. (#61)

### Deprecated
- `sodium.crypto.aead` was renamed and thus deprecated. Use `sodium.crypto.aeadXChaCha20Poly1305IETF` instead. (#61)

## [2.1.2] - 2023-09-06
### Changed
- Update min required dart SDK to 3.1.0
- Update dependencies
- Update formatting

## [2.1.1] - 2023-06-06
### Changed
- Update dependencies
- Update min dart SDK to 3.0.0

### Removed
- Remove non libsodium definitions from generated ffi code

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

[3.4.7]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium-v3.4.6...sodium-v3.4.7
[3.4.6]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium-v3.4.5...sodium-v3.4.6
[3.4.5]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium-v3.4.4...sodium-v3.4.5
[3.4.4]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium-v3.4.3...sodium-v3.4.4
[3.4.3]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium-v3.4.2...sodium-v3.4.3
[3.4.2]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium-v3.4.1...sodium-v3.4.2
[3.4.1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium-v3.4.0...sodium-v3.4.1
[3.4.0]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium-v3.3.0...sodium-v3.4.0
[3.3.0]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium-v3.2.0+1...sodium-v3.3.0
[3.2.0+1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium-v3.2.0...sodium-v3.2.0+1
[3.2.0]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium-v3.1.0...sodium-v3.2.0
[3.1.0]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium-v3.0.1...sodium-v3.1.0
[3.0.1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium-v3.0.0...sodium-v3.0.1
[3.0.0]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium-v2.3.1+1...sodium-v3.0.0
[2.3.1+1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium-v2.3.1...sodium-v2.3.1+1
[2.3.1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium-v2.3.0+2...sodium-v2.3.1
[2.3.0+2]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium-v2.3.0+1...sodium-v2.3.0+2
[2.3.0+1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium-v2.3.0...sodium-v2.3.0+1
[2.3.0]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium-v2.2.0...sodium-v2.3.0
[2.2.0]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium-v2.1.2...sodium-v2.2.0
[2.1.2]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium-v2.1.1...sodium-v2.1.2
[2.1.1]: https://github.com/Skycoder42/libsodium_dart_bindings/compare/sodium-v2.1.0...sodium-v2.1.1
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
