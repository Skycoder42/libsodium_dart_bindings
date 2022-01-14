# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.0+1] - 2022-01-14
### Changed
- Set minimum required dart SDK version to 2.15
- Updated dependencies

## [1.2.0] - 2021-11-26
## Added
- Support for 32bit architectures by generalizing the native FFI bindings (#7)
### Changed
- Set minimum required dart SDK version to 2.14
- Updated dependencies
- Upgraded dart ffi language bindings
- Use new callable workflows for workflow simplification
### Fixed
- Fix formatting and linter issues with the newer dart SDK & dependencies

## [1.1.2] - 2021-08-26
### Added
- Added missing `skToSeed` and `skToPk` methods to `crypto.sign` (#4)

## [1.1.1] - 2021-08-26
### Changed
- `SodiumInit.init` now automatically handles multiple initializations and no
longer requires the `initNative` parameter for consecutive invocations (#3)
### Deprecated
- The `initNative` parameter of `SodiumInit.init` has been deprecated as it no
longer has any effect (#3)

## [1.1.0] - 2021-08-17
### Added
- `SecureKey.split` extension that allows to split one key into multiple (#2)
- `SecureKey.nativeHandle` and `SecureKey.fromNativeHandle` to allow passing
secure keys across isolate boundaries
- `SodiumInit.init` can now be called with `initNative: false` to disable
initialization of the native library, in case it has already been initialized

## [1.0.0] - 2021-07-08
### Changed
- Update dependencies
- Refactor integration tests and CI scripts

## [0.2.4] - 2021-06-23
### Fixed
- Downgrade requirements for package meta to be compatible with flutter

## [0.2.3] - 2021-06-23
### Added
- New libsodium API: crypto_kx
- Added missing tests for crypto_kdf

## [0.2.2] - 2021-06-01
### Added
- New libsodium API:
  - crypto_aead
    - Only crypto_aead_xchacha20poly1305_ietf has been implemented for now
  - crypto_kdf
### Fixed
- Improve secretstream API usage

## [0.2.1] - 2021-05-27
### Added
- New libsodium API: crypto_shorthash

## [0.2.0] - 2021-05-27
### Added
- Added the beforenm/afternm variants of crypto_box
### Changed
- Removed sender/recipient prefixes from publicKey/secretKey parameters of Box
### Fixed
- Added missing `@internal` on some internal classes

## [0.1.5] - 2021-05-27
### Added
- New libsodium API: crypto_generichash

## [0.1.4] - 2021-05-21
### Added
- New libsodium API: crypto_box_seal

## [0.1.3] - 2021-05-21
### Added
- New libsodium APIs:
  - crypto_box
  - crypto_sign
### Changed
- Set minimum required dart version to 2.13.0

## [0.1.1] - 2021-05-11
### Added
- New libsodium API: crypto_auth
- Add `Sodium.secureCopy` (#1)

## [0.1.0] - 2021-05-09
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

## [0.0.1] - 2021-04-06
### Added
- Initial test release - not ready for use yet!

## [Unreleased]
### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security
