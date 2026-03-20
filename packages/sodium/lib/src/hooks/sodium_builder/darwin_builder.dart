import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:meta/meta.dart';

import 'automake_builder.dart';

@internal
@immutable
class DarwinConfig {
  final String arch;
  final String? build;
  final String host;
  final Uri platform;
  final Uri sdk;
  final String versionParameter;

  const DarwinConfig({
    required this.arch,
    this.build,
    required this.host,
    required this.platform,
    required this.sdk,
    required this.versionParameter,
  });

  Iterable<Object?> get _hashValues sync* {
    yield arch;
    yield build;
    yield host;
    yield platform;
    yield sdk;
    yield versionParameter;
  }
}

@internal
abstract base class DarwinBuilder extends AutomakeBuilder {
  late final DarwinConfig _platformConfig;

  DarwinBuilder(super.config, super.logger);

  @override
  @nonVirtual
  Future<void> prepare() async {
    final xcodeDir = await _getXcodeDir();
    logger.info('Xcode directory: ${xcodeDir.toFilePath()}');
    _platformConfig = await getPlatformConfig(xcodeDir);
    logger
      ..debug('Detect architecture: ${_platformConfig.arch}')
      ..debug('Detect build: ${_platformConfig.build ?? '<default>'}')
      ..debug('Detect host: ${_platformConfig.host}')
      ..debug('Detect platform: ${_platformConfig.platform.toFilePath()}')
      ..debug('Detect SDK: ${_platformConfig.sdk.toFilePath()}')
      ..debug('Detect version parameter: ${_platformConfig.versionParameter}');
  }

  @override
  Iterable<Object?> get configHash sync* {
    yield* super.configHash;
    yield* _platformConfig._hashValues;
  }

  @override
  Map<String, String> get environment {
    final DarwinConfig(:platform, :arch, :sdk, :versionParameter) =
        _platformConfig;

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
      ...super.environment,
      'PATH': path,
      'CFLAGS': cFlags.followedBy(ldFlags).join(' '),
      'LDFLAGS': ldFlags.join(' '),
    };
  }

  @override
  Iterable<String> get configureArgs sync* {
    final DarwinConfig(:build, :host, :sdk) = _platformConfig;
    yield* super.configureArgs;
    if (build != null) {
      yield '--build=$build';
    }
    yield '--host=$host';
    yield '--with-sysroot=${sdk.toFilePath()}';
  }

  @visibleForOverriding
  FutureOr<DarwinConfig> getPlatformConfig(Uri xcodeDir);

  Future<Uri> _getXcodeDir() async {
    final result = await execStream('xcode-select', const [
      '-p',
    ]).transform(utf8.decoder).join();
    return Uri.file(result.trim()).withTrailingSlash;
  }
}

extension on Uri {
  Uri get withTrailingSlash {
    if (path.endsWith('/')) {
      return this;
    } else {
      return replace(path: '$path/');
    }
  }
}
