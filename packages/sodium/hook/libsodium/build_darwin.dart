import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:meta/meta.dart';

import 'build_common.dart';
import 'utils.dart';

class DarwinConfig {
  final String arch;
  final String host;
  final Uri platform;
  final Uri sdk;
  final String versionParameter;

  DarwinConfig({
    required this.arch,
    required this.host,
    required this.platform,
    required this.sdk,
    required this.versionParameter,
  });

  Iterable<Object> get _hashValues sync* {
    yield arch;
    yield host;
    yield platform;
    yield sdk;
    yield versionParameter;
  }
}

abstract base class BuildDarwin extends BuildCommon {
  DarwinConfig? _cachedPlatformConfig;

  @override
  Future<List<Object>> hashValues(CodeConfig config) async => [
    ...await super.hashValues(config),
    ...(await _getPlatformConfig(config))._hashValues,
  ];

  @override
  Future<Map<String, String>> createEnvironment(CodeConfig config) async {
    final DarwinConfig(:platform, :arch, :sdk, :versionParameter) =
        await _getPlatformConfig(config);

    final binUri = platform.resolve('usr/bin/');
    final sbinUri = platform.resolve('usr/sbin/');
    final path = [
      binUri.toFilePath(),
      sbinUri.toFilePath(),
      ?Platform.environment['PATH'],
    ].join(':');

    final cFlags = ['-O3'];
    final ldFlags = [
      '-arch',
      arch,
      '-isysroot',
      sdk.toFilePath(),
      versionParameter,
    ];

    return {
      ...await super.createEnvironment(config),
      'PATH': path,
      'CFLAGS': cFlags.join(' '),
      'LDFLAGS': cFlags.followedBy(ldFlags).join(' '),
    };
  }

  @override
  Future<List<String>> createConfigureArguments(CodeConfig config) async {
    final DarwinConfig(:host, :sdk) = await _getPlatformConfig(config);

    return [
      ...await super.createConfigureArguments(config),
      '--host=$host',
      '--with-sysroot=${sdk.toFilePath()}',
    ];
  }

  @visibleForOverriding
  FutureOr<DarwinConfig> getPlatformConfig(CodeConfig config, Uri xcodeDir);

  Future<DarwinConfig> _getPlatformConfig(CodeConfig config) async =>
      _cachedPlatformConfig ??= await getPlatformConfig(
        config,
        await _getXcodeDir(),
      );

  Future<Uri> _getXcodeDir() async {
    final result = await execStream('xcode-select', const [
      '-p',
    ]).transform(utf8.decoder).join();
    return Uri.file(result.trim()).withTrailingSlash;
  }
}
