import 'dart:async';
import 'dart:io';

import '../../../../tool/util.dart';
import '../../libsodium_version.dart';

export '../../../../tool/util.dart';

enum CiPlatform {
  // ignore: constant_identifier_names
  android_arm64_v8a('.tar.gz'),
  // ignore: constant_identifier_names
  android_armeabi_v7a('.tar.gz'),
  // ignore: constant_identifier_names
  android_x86_64('.tar.gz'),
  // ignore: constant_identifier_names
  android_x86('.tar.gz'),
  windows('-msvc.zip');

  final String _suffix;

  const CiPlatform(this._suffix);

  Uri get downloadUrl => Uri.https(
        'download.libsodium.org',
        '/libsodium/releases/libsodium-${libsodium_version.ffi}-stable$_suffix',
      );

  String get lastModifiedFileName => 'last-modified-$name.txt';

  File get lastModifiedFile => File('tool/libsodium/$lastModifiedFileName');
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
  Directory archiveContents,
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
      CiPlatform.windows.downloadUrl,
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
      tmpDir.subDir('libsodium'),
      lastModifiedHeader,
      artifactDir,
    );
    await artifactDir
        .subFile(platform.lastModifiedFileName)
        .writeAsString(lastModifiedHeader);
  } finally {
    await tmpDir.delete(recursive: true);
    httpClient.close(force: true);
  }
}
