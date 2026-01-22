import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';

import 'build_common.dart';
import 'utils.dart';

class BuildMacos extends BuildCommon {
  Uri? _cachedPlatformUri;

  @override
  Future<List<Object>> hashValues(CodeConfig config) async => [
    ...await super.hashValues(config),
    await _platformUri,
    config.macOS.targetVersion,
  ];

  @override
  Future<Map<String, String>> createEnvironment(CodeConfig config) async {
    final platformUri = await _platformUri;
    final sdkUri = platformUri.resolve('SDKs/MacOSX.sdk/');
    final binUri = platformUri.resolve('usr/bin/');
    final sbinUri = platformUri.resolve('usr/sbin/');
    final path = [
      binUri.toFilePath(),
      sbinUri.toFilePath(),
      ?Platform.environment['PATH'],
    ].join(':');

    final ldFlags = [
      '-arch',
      _mapArch(config.targetArchitecture),
      '-isysroot',
      sdkUri.toFilePath(),
      '-mmacosx-version-min=${config.macOS.targetVersion}',
    ];
    final cFlags = ['-O3', ...ldFlags];

    return {
      ...await super.createEnvironment(config),
      'PATH': path,
      'CFLAGS': cFlags.join(' '),
      'LDFLAGS': ldFlags.join(' '),
    };
  }

  @override
  Future<List<String>> createConfigureArguments(CodeConfig config) async => [
    ...await super.createConfigureArguments(config),
    '--host=${_mapHost(config.targetArchitecture)}',
  ];

  Future<Uri> get _platformUri async {
    if (_cachedPlatformUri != null) {
      return _cachedPlatformUri!;
    }

    final result = await execStream('xcode-select', const [
      '-p',
    ]).transform(utf8.decoder).join();
    final baseUrl = Uri.file(result.trim());
    return _cachedPlatformUri ??= baseUrl.withTrailingSlash.resolve(
      'Platforms/MacOSX.platform/Developer/',
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
