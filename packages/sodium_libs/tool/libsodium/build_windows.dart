import 'dart:io';

import 'common.dart';

Future<void> main(List<String> args) =>
    buildArtifact(CiPlatform.windows, _createArtifactDir);

Future<void> _createArtifactDir(
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
