import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/src/config.dart';

import 'sodium_builder.dart';

final class AndroidBuilder extends SodiumBuilder {
  Uri? _cachedNdkPath;

  AndroidBuilder(super.config);

  @override
  Stream<Object> get configHash async* {
    yield* super.configHash;
    yield config.android.targetNdkApi;
    yield await _getAndroidNdkPath();
  }

  @override
  Future<CodeAsset> buildCached({
    required BuildInput input,
    required Directory sourceDir,
    required Uri installDir,
  }) async {
    final buildTarget = _mapBuildTarget(config.targetArchitecture);
    final installTarget = _mapInstallTarget(config.targetArchitecture);

    await exec(
      './dist-build/android-$buildTarget.sh',
      const [],
      workingDirectory: sourceDir,
      runInShell: true,
      environment: {
        'ANDROID_NDK_HOME': (await _getAndroidNdkPath()).toFilePath(),
        'NDK_PLATFORM': 'android-${config.android.targetNdkApi}',
        'LIBSODIUM_FULL_BUILD': '1',
      },
    );

    return createCodeAsset(
      sourceDir.uri.resolve('libsodium-android-$installTarget/lib/'),
    );
  }

  Future<Uri> _getAndroidNdkPath() async {
    if (_cachedNdkPath case final ndkPath?) {
      return ndkPath;
    }

    final flutterConfig = await execStream('flutter', ['config', '--machine'])
        .transform(utf8.decoder)
        .transform(json.decoder)
        .cast<Map<String, dynamic>>()
        .single;
    final androidSdk = flutterConfig['android-sdk'] as String?;
    if (androidSdk == null) {
      throw Exception('Android SDK path not found in flutter config');
    }

    final sdkUri = Uri.directory(androidSdk);
    final ndkCandidates = await Directory.fromUri(sdkUri.resolve('ndk/'))
        .list(followLinks: false)
        .where((e) => e is Directory)
        .cast<Directory>()
        .map((d) => d.absolute.uri)
        .toList();
    final bestCandidate = (ndkCandidates..sort(_compareFileName)).lastOrNull;
    if (bestCandidate == null) {
      throw Exception('No Android NDK found in $androidSdk/ndk/');
    }

    return _cachedNdkPath = bestCandidate;
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
