# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.1] - 2021-08-26
### Changed
- `SodiumInit.init` now automatically handles multiple initializations and no
longer requires the `initNative` parameter for consecutive invocations (#3)
- Updated minimum required `sodium` version to `1.1.1`
### Deprecated
- The `initNative` parameter of `SodiumInit.init` has been deprecated as it no
longer has any effect (#3)

## [1.1.0] - 2021-08-17
### Added
- `SodiumInit.init` can now be called with `initNative: false` to disable
initialization of the native library, in case it has already been initialized
### Changed
- Updated minimum required `sodium` version to `1.1.0`

## [1.0.1] - 2021-07-13
### Fixed
- Make links in README secure (pub.dev score)
- Use longer package description (pub.dev score)

## [1.0.0] - 2021-07-12
### Fixed
- Web/Windows builds did not work when packages was installed via pub.dev

## [0.1.0] - 2021-06-24
### Added
- Initial release

## [Unreleased]
### Added
### Changed
### Deprecated
### Removed
### Fixed
### Security
