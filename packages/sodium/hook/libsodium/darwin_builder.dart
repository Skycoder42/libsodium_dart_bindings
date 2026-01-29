import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';

import 'sodium_builder.dart';
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

abstract base class DarwinBuilder extends SodiumBuilder {
  DarwinConfig? _cachedPlatformConfig;

  DarwinBuilder(super.config);

  @override
  Stream<Object> get configHash async* {
    yield* super.configHash;
    yield* Stream.fromFuture(_platformConfig).expand((c) => c._hashValues);
  }

  @override
  Future<Map<String, String>> get environment async {
    final DarwinConfig(:platform, :arch, :sdk, :versionParameter) =
        await _platformConfig;

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
      ...await super.environment,
      'PATH': path,
      'CFLAGS': cFlags.join(' '),
      'LDFLAGS': cFlags.followedBy(ldFlags).join(' '),
    };
  }

  @override
  Future<List<String>> get configureArgs async {
    final DarwinConfig(:host, :sdk) = await _platformConfig;

    return [
      ...await super.configureArgs,
      '--host=$host',
      '--with-sysroot=${sdk.toFilePath()}',
    ];
  }

  @visibleForOverriding
  FutureOr<DarwinConfig> getPlatformConfig(Uri xcodeDir);

  Future<DarwinConfig> get _platformConfig async =>
      _cachedPlatformConfig ??= await getPlatformConfig(await _getXcodeDir());

  Future<Uri> _getXcodeDir() async {
    final result = await execStream('xcode-select', const [
      '-p',
    ]).transform(utf8.decoder).join();
    return Uri.file(result.trim()).withTrailingSlash;
  }
}
