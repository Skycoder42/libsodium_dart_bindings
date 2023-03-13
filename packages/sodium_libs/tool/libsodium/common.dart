import 'dart:async';
import 'dart:io';

import '../../../../tool/util.dart';
import '../../libsodium_version.dart';

export '../../../../tool/util.dart';

enum CiPlatform {
  // ignore: constant_identifier_names
  android_arm64_v8a('.tar.gz', 'arm64_v8a', 'armv8-a'),
  // ignore: constant_identifier_names
  android_armeabi_v7a('.tar.gz', 'armeabi_v7a', 'armv7-a'),
  // ignore: constant_identifier_names
  android_x86_64('.tar.gz', 'x86_64', null),
  // ignore: constant_identifier_names
  android_x86('.tar.gz', 'x86', null),
  windows('-msvc.zip', null, null);

  final String _suffix;
  final String? _architecture;
  final String? _buildTarget;

  const CiPlatform(this._suffix, this._architecture, this._buildTarget);

  Uri get downloadUrl => Uri.https(
        'download.libsodium.org',
        '/libsodium/releases/libsodium-${libsodium_version.ffi}-stable$_suffix',
      );

  File get lastModifiedFile =>
      File('tool/libsodium/.last-modified/${libsodium_version.ffi}/$name.txt');

  String get architecture => _architecture ?? name;

  String get buildTarget => _buildTarget ?? architecture;
}

abstract class GithubEnv {
  GithubEnv._();

  static Directory get runnerTemp {
    final runnerTemp = Platform.environment['RUNNER_TEMP'];
    return runnerTemp != null ? Directory(runnerTemp) : Directory.systemTemp;
  }

  static Future<void> setOutput(String name, Object? value) async {
    final githubOutput = Platform.environment['GITHUB_OUTPUT'];
    if (githubOutput == null) {
      throw Exception('Cannot set output! GITHUB_OUTPUT env var is not set');
    }

    final githubOutputFile = File(githubOutput);
    await githubOutputFile.writeAsString(
      '$name=$value\n',
      mode: FileMode.writeOnlyAppend,
    );
  }
}

typedef CreateArtifactCb = FutureOr<void> Function(
  CiPlatform platform,
  Directory extractDir,
  String lastModifiedHeader,
  Directory artifactDir,
);

Future<void> buildArtifact(
  CiPlatform platform,
  CreateArtifactCb createArtifact,
) async {
  final httpClient = HttpClient();
  final tmpDir = await GithubEnv.runnerTemp.createTemp();
  try {
    late String lastModifiedHeader;

    final archive = await httpClient.download(
      tmpDir,
      platform.downloadUrl,
      withSignature: true,
      headerExtractor: (headers) =>
          lastModifiedHeader = headers[HttpHeaders.lastModifiedHeader]!.first,
    );
    await verify(archive);
    await extract(archive: archive, outDir: tmpDir);

    final artifactDir = await GithubEnv.runnerTemp
        .subDir('libsodium-${platform.name}')
        .create();
    await createArtifact(
      platform,
      tmpDir,
      lastModifiedHeader,
      artifactDir,
    );
    await artifactDir
        .subFile('last-modified.txt')
        .writeAsString(lastModifiedHeader);
  } finally {
    await tmpDir.delete(recursive: true);
    httpClient.close(force: true);
  }
}
