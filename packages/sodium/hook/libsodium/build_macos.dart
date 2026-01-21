import 'package:code_assets/code_assets.dart';

import 'build_common.dart';

class BuildMacos extends BuildCommon {
  @override
  List<Object> hashValues(CodeConfig config) => [
    ...super.hashValues(config),
    config.macOS.targetVersion,
  ];

  @override
  Map<String, String> createEnvironment(CodeConfig config) {
    final ldFlags = [
      '-arch',
      _mapArch(config.targetArchitecture),
      '-mmacosx-version-min=${config.macOS.targetVersion}',
    ];
    final cFlags = ['-O3', ...ldFlags];

    return {
      ...super.createEnvironment(config),
      'CFLAGS': cFlags.join(' '),
      'LDFLAGS': ldFlags.join(' '),
    };
  }

  @override
  List<String> createConfigureArguments(CodeConfig config) => [
    ...super.createConfigureArguments(config),
    '--host=${_mapMacosHost(config.targetArchitecture)}',
  ];

  String _mapArch(Architecture arch) => switch (arch) {
    .arm64 => 'arm64',
    .x64 => 'x86_64',
    _ => throw UnsupportedError('Unsupported macOS architecture: $arch'),
  };

  String _mapMacosHost(Architecture arch) => switch (arch) {
    .arm64 => 'aarch64-apple-darwin23',
    .x64 => 'x86_64-apple-darwin23',
    _ => throw UnsupportedError('Unsupported macOS architecture: $arch'),
  };
}
