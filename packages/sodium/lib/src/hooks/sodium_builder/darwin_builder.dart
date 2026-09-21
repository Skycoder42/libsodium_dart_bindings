import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:meta/meta.dart';

import 'automake_builder.dart';

@internal
@immutable
// ignore: public_member_api_docs false positive
class const DarwinConfig({
  required final String arch,
  final String? build,
  required final String host,
  required final Uri platform,
  required final Uri sdk,
  required final String versionParameter,
}) {
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
// ignore: public_member_api_docs false positive
abstract base class DarwinBuilder(super.config, super.logger)
    extends AutomakeBuilder {
  late final DarwinConfig _platformConfig;

  @override
  @nonVirtual
  Future<void> prepare() async {
    final xcodeDir = await _getXcodeDir();
    logger.info('Xcode directory: $xcodeDir');
    _platformConfig = await getPlatformConfig(xcodeDir);
    logger
      ..debug('Detect architecture: ${_platformConfig.arch}')
      ..debug('Detect build: ${_platformConfig.build ?? '<default>'}')
      ..debug('Detect host: ${_platformConfig.host}')
      ..debug('Detect platform: ${_platformConfig.platform}')
      ..debug('Detect SDK: ${_platformConfig.sdk}')
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
    if (config.targetArchitecture != Architecture.current) {
      yield 'cross_compiling=yes';
    }
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
