import 'package:code_assets/code_assets.dart';

import 'darwin_builder.dart';

final class MacosBuilder extends DarwinBuilder {
  MacosBuilder(super.config);

  @override
  DarwinConfig getPlatformConfig(Uri xcodeDir) {
    assert(config.targetOS == .macOS, 'Expected target OS to be macOS.');

    final platform = xcodeDir.resolve('Platforms/MacOSX.platform/Developer/');
    return DarwinConfig(
      arch: _mapArch(config.targetArchitecture),
      host: _mapHost(config.targetArchitecture),
      platform: platform,
      sdk: platform.resolve('SDKs/MacOSX.sdk/'),
      versionParameter: '-mmacosx-version-min=${config.macOS.targetVersion}',
    );
  }

  String _mapArch(Architecture arch) => switch (arch) {
    .arm64 => 'arm64',
    .x64 => 'x86_64',
    _ => throw UnsupportedError('Unsupported macOS architecture: $arch'),
  };

  String _mapHost(Architecture arch) => switch (arch) {
    .arm64 => 'aarch64-apple-darwin23',
    .x64 => 'x86_64-apple-darwin23',
    _ => throw UnsupportedError('Unsupported macOS architecture: $arch'),
  };
}
