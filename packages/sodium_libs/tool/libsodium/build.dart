import 'dart:io';

import 'common.dart';

Future<void> main(List<String> args) async {
  final platform = CiPlatform.values.byName(args.first);

  final CreateArtifactCb createArtifact;
  switch (platform) {
    case CiPlatform.android_arm64_v8a:
    case CiPlatform.android_armeabi_v7a:
    case CiPlatform.android_x86_64:
    case CiPlatform.android_x86:
      createArtifact = _createAndroidArtifact;
      break;
    case CiPlatform.windows:
      createArtifact = _createWindowsArtifact;
      break;
  }

  await buildArtifact(platform, createArtifact);
}

Future<void> _createAndroidArtifact(
  CiPlatform platform,
  Directory archiveContents,
  String lastModifiedHeader,
  Directory artifactDir,
) async {
  await run(
    './dist-build/android-${platform.buildTarget}.sh',
    const [],
    workingDirectory: archiveContents,
    environment: const {
      'LIBSODIUM_FULL_BUILD': '1',
    },
  );

  final source = archiveContents
      .subDir('libsodium-android-${platform.buildTarget}')
      .subDir('lib')
      .subFile('libsodium.so');
  final target =
      artifactDir.subDir(platform.architecture).subFile('libsodium.so');
  await target.parent.create(recursive: true);
  await source.rename(target.path);
}

Future<void> _createWindowsArtifact(
  CiPlatform platform,
  Directory archiveContents,
  String lastModifiedHeader,
  Directory artifactDir,
) async {
  const arch = 'x64';
  const libraryType = 'dynamic';
  const msvcVersions = ['v142', 'v143'];
  const releaseFiles = ['libsodium.dll'];
  const debugFiles = [...releaseFiles, 'libsodium.pdb'];
  const configurations = {
    'Debug': debugFiles,
    'Release': releaseFiles,
  };

  for (final configEntry in configurations.entries) {
    final config = configEntry.key;
    final configFiles = configEntry.value;
    for (final msvcVersion in msvcVersions) {
      for (final file in configFiles) {
        final source = archiveContents
            .subDir(arch)
            .subDir(config)
            .subDir(msvcVersion)
            .subDir(libraryType)
            .subFile(file);
        final target =
            artifactDir.subDir(config).subDir(msvcVersion).subFile(file);
        await target.parent.create(recursive: true);
        await source.rename(target.path);
      }
    }
  }
}
