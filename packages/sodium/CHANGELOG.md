# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 2.0.1
### Fixed
- Implemented temporary workaround for #22 until https://github.com/flutter/flutter/issues/116405 is fixed

## 2.0.0
### Added
- Added new `SodiumSumo` class that extends the basic sodium APIs with advanced APIs.
  - **Important:** On some platforms this requires you to use a different binary
  - The new variant is available via the `package:sodium/sodium_sumo.dart` import and can be initialized with
  `SodiumSumoInit.init`
- Added `crypto.scalarmult` as sumo interface for https://libsodium.gitbook.io/doc/advanced/scalar_multiplication
- Extended `crypto.sign` as sumo interface
### Changed
- **Breaking:** Moved the `Sign.skToSeed` and `Sign.skToPk` methods into `SignSumo`
### Removed
- Removed all previously deprecated APIs

## 1.2.5
### Fixed
- Fixed performance issue that caused the "dart -> native" copy process of bytes to take extremely long (#19)

## 1.2.4
### Added
- Let `GenericHashConsumer` implement `Sink` to allow synchronous adding of data
- Let `SignatureConsumer` implement `Sink` to allow synchronous adding of data
- Let `VerificationConsumer` implement `Sink` to allow synchronous adding of data
### Fixed
- Rename `JsError.wrap` to `jsErrorWrap` to prevent problems when debugging JS applications

## 1.2.3+1
### Changed
- Update dependencies
- Set minimum required dart SDK version to 2.18.0

## 1.2.3
### Changed
- Update dependencies
- Activate stricter linter rules, fix resulting issues

## 1.2.2
### Changed
- Add missing tests and coverage ignores

## 1.2.1
### Changed
- Updated minimum required dart SDK to 1.17.0
- Refactor implementation to make use of newly added ABI-specific integers
  - Makes the library more robust on non x64 platforms
  - Future-proof if new platforms are added

## 1.2.0+2
### Changed
- Replaced `lint` with `dart_test_tools` which makes the default rules of `lint` even more strict
- Refactored test setup tooling

## 1.2.0+1
### Changed
- Set minimum required dart SDK version to 2.15
- Updated dependencies

## 1.2.0
## Added
- Support for 32bit architectures by generalizing the native FFI bindings (#7)
### Changed
- Set minimum required dart SDK version to 2.14
- Updated dependencies
- Upgraded dart ffi language bindings
- Use new callable workflows for workflow simplification
### Fixed
- Fix formatting and linter issues with the newer dart SDK & dependencies

## 1.1.2
### Added
- Added missing `skToSeed` and `skToPk` methods to `crypto.sign` (#4)

## 1.1.1
### Changed
- `SodiumInit.init` now automatically handles multiple initializations and no longer requires the `initNative` parameter for consecutive invocations (#3)
### Deprecated
- The `initNative` parameter of `SodiumInit.init` has been deprecated as it no longer has any effect (#3)

## 1.1.0
### Added
- `SecureKey.split` extension that allows to split one key into multiple (#2)
- `SecureKey.nativeHandle` and `SecureKey.fromNativeHandle` to allow passing secure keys across isolate boundaries
- `SodiumInit.init` can now be called with `initNative: false` to disable initialization of the native library, in case it has already been initialized

## 1.0.0
### Changed
- Update dependencies
- Refactor integration tests and CI scripts

## 0.2.4
### Fixed
- Downgrade requirements for package meta to be compatible with flutter

## 0.2.3
### Added
- New libsodium API: crypto_kx
- Added missing tests for crypto_kdf

## 0.2.2
### Added
- New libsodium API:
  - crypto_aead
    - Only crypto_aead_xchacha20poly1305_ietf has been implemented for now
  - crypto_kdf
### Fixed
- Improve secretstream API usage

## 0.2.1
### Added
- New libsodium API: crypto_shorthash

## 0.2.0
### Added
- Added the beforenm/afternm variants of crypto_box
### Changed
- Removed sender/recipient prefixes from publicKey/secretKey parameters of Box
### Fixed
- Added missing `@internal` on some internal classes

## 0.1.5
### Added
- New libsodium API: crypto_generichash

## 0.1.4
### Added
- New libsodium API: crypto_box_seal

## 0.1.3
### Added
- New libsodium APIs:
  - crypto_box
  - crypto_sign
### Changed
- Set minimum required dart version to 2.13.0

## 0.1.1
### Added
- New libsodium API: crypto_auth
- Add `Sodium.secureCopy` (#1)

## 0.1.0
### Added
- New libsodium APIS:
  - padding
  - memory
  - randombytes
  - crypto_secretbox
  - crypto_secretstream
  - crypto_pwhash
- Extended unit and integration tests
- Documentation

## 0.0.1
### Added
- Initial test release - not ready for use yet!

## Unreleased
### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security
