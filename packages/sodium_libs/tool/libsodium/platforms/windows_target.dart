import 'dart:io';

import 'package:dart_test_tools/tools.dart';

import 'plugin_target.dart';

class WindowsTarget extends PluginTarget {
  const WindowsTarget();

  @override
  String get name => 'windows';

  @override
  String get suffix => '-msvc.zip';

  @override
  Future<void> build({
    required Directory extractDir,
    required Directory artifactDir,
  }) async {
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
          final source = extractDir
              .subDir('libsodium')
              .subDir(arch)
              .subDir(config)
              .subDir(msvcVersion)
              .subDir(libraryType)
              .subFile(file);
          final target =
              artifactDir.subDir(config).subDir(msvcVersion).subFile(file);

          Github.logInfo('Installing ${target.path}');
          await target.parent.create(recursive: true);
          await source.rename(target.path);
        }
      }
    }
  }
}
