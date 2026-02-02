import 'package:code_assets/code_assets.dart';

import 'darwin_builder.dart';

final class IosBuilder extends DarwinBuilder {
  IosBuilder(super.config);

  @override
  DarwinConfig getPlatformConfig(Uri xcodeDir) {
    assert(config.targetOS == .iOS, 'Expected target OS to be iOS.');

    final sdkName = _mapSdk(config.iOS.targetSdk);

    final platform = xcodeDir.resolve('Platforms/$sdkName.platform/Developer/');
    return DarwinConfig(
      arch: _mapArch(config.targetArchitecture),
      build: 'aarch64-apple-darwin',
      host: _mapHost(config.targetArchitecture),
      platform: platform,
      sdk: platform.resolve('SDKs/$sdkName.sdk/'),
      versionParameter: _mapIosVersionParam(
        config.iOS.targetSdk,
        config.iOS.targetVersion,
      ),
    );
  }

  String _mapArch(Architecture arch) => switch (arch) {
    .arm64 => 'arm64',
    .x64 => 'x86_64',
    _ => throw UnsupportedError('Unsupported iOS architecture: $arch'),
  };

  String _mapHost(Architecture arch) => switch (arch) {
    .arm64 => 'aarch64-apple-darwin23',
    .x64 => 'x86_64-apple-darwin23',
    _ => throw UnsupportedError('Unsupported iOS architecture: $arch'),
  };

  String _mapSdk(IOSSdk sdk) => switch (sdk) {
    .iPhoneOS => 'iPhoneOS',
    .iPhoneSimulator => 'iPhoneSimulator',
    _ => throw UnsupportedError('Unsupported iOS SDK: $sdk'),
  };

  String _mapIosVersionParam(IOSSdk sdk, int version) => switch (sdk) {
    .iPhoneOS => '-mios-version-min=$version',
    .iPhoneSimulator => '-mios-simulator-version-min=$version',
    _ => throw UnsupportedError('Unsupported iOS SDK: $sdk'),
  };
}
