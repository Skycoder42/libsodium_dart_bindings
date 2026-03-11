import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:meta/meta.dart';

import 'sodium_builder.dart';

@internal
final class AndroidBuilder extends SodiumBuilder {
  late final Uri _ndkPath;

  AndroidBuilder(super.config, super.logger);

  @override
  Future<void> prepare() async {
    _ndkPath = await _getAndroidNdkPath();
    logger.info('Detected Android NDK path: ${_ndkPath.toFilePath()}');
  }

  @override
  Iterable<Object?> get configHash sync* {
    yield* super.configHash;
    yield config.android.targetNdkApi;
    yield _ndkPath;
  }

  @override
  Future<Uri> buildCached({
    required BuildInput input,
    required Directory sourceDir,
  }) async {
    final buildTarget = _mapBuildTarget(config.targetArchitecture);
    final installTarget = _mapInstallTarget(config.targetArchitecture);
    logger
      ..debug('Detected build target: $buildTarget')
      ..debug('Detected install target: $installTarget')
      ..debug('Target API level: ${config.android.targetNdkApi}');

    await exec(
      './dist-build/android-$buildTarget.sh',
      const [],
      workingDirectory: sourceDir,
      runInShell: true,
      environment: {
        'ANDROID_NDK_HOME': _ndkPath.toFilePath(),
        'NDK_PLATFORM': 'android-${config.android.targetNdkApi}',
        'LIBSODIUM_FULL_BUILD': '1',
      },
    );

    return sourceDir.uri.resolve('libsodium-android-$installTarget/');
  }

  Future<Uri> _getAndroidNdkPath() async {
    final flutterConfig = await execStream('flutter', ['config', '--machine'])
        .transform(utf8.decoder)
        .transform(json.decoder)
        .cast<Map<String, dynamic>>()
        .single;
    final androidSdk = flutterConfig['android-sdk'] as String?;
    if (androidSdk == null) {
      throw Exception('Android SDK path not found in flutter config');
    }
    logger.debug('Detected android SDK path from flutter config: $androidSdk');

    final sdkUri = Uri.directory(androidSdk);
    final ndkCandidates = await Directory.fromUri(sdkUri.resolve('ndk/'))
        .list(followLinks: false)
        .where((e) => e is Directory)
        .cast<Directory>()
        .map((d) => d.absolute.uri)
        .toList();
    logger.debug('Found ${ndkCandidates.length} NDK candidates:');
    for (final candidate in ndkCandidates) {
      logger.debug('  > ${candidate.toFilePath()}');
    }

    final bestCandidate = (ndkCandidates..sort(_compareFileName)).lastOrNull;
    if (bestCandidate == null) {
      throw Exception('No Android NDK found in $androidSdk/ndk/');
    }

    return bestCandidate;
  }

  int _compareFileName(Uri a, Uri b) =>
      a.pathSegments.last.compareTo(b.pathSegments.last);

  String _mapBuildTarget(Architecture arch) => switch (arch) {
    .arm => 'armv7-a',
    .arm64 => 'armv8-a',
    .ia32 => 'x86',
    .x64 => 'x86_64',
    _ => throw UnsupportedError('Unsupported android architecture: $arch'),
  };

  String _mapInstallTarget(Architecture arch) => switch (arch) {
    .arm => 'armv7-a',
    .arm64 => 'armv8-a+crypto',
    .ia32 => 'i686',
    .x64 => 'westmere',
    _ => throw UnsupportedError('Unsupported android architecture: $arch'),
  };
}
