import 'dart:io';

import 'package:dart_test_tools/tools.dart';

import 'plugin_target.dart';

class DarwinTarget extends PluginTarget {
  final String platform;
  final List<String> architectures;
  final String libraryType;

  const DarwinTarget({
    required this.platform,
    required this.architectures,
    required this.libraryType,
  });

  @override
  String get name => platform;

  @override
  String get suffix => '.tar.gz';

  @override
  Future<void> build({
    required Directory extractDir,
    required Directory artifactDir,
  }) async {
    final buildDir = extractDir.subDir('libsodium-stable');
    final buildScriptFile =
        buildDir.subDir('dist-build').subFile('apple-xcframework.sh');
    await _patchBuildScript(buildScriptFile);
    await _runBuildScript(buildScriptFile, buildDir);
    await _buildLipoArchive(buildDir, artifactDir);
  }

  Future<void> _patchBuildScript(File buildScriptFile) async {
    final originalLines = await buildScriptFile.readAsLines();
    final modifiedLines = originalLines
        .takeWhile((line) => line != r'mkdir -p "${PREFIX}/tmp"')
        .followedBy([
      r'mkdir -p "${PREFIX}/tmp"',
      'echo "Building for $name..."',
      'build_$platform || exit 1',
    ]);
    await buildScriptFile.writeAsString(modifiedLines.join('\n'), flush: true);
  }

  Future<void> _runBuildScript(
    File buildScriptFile,
    Directory buildDir,
  ) async {
    await Github.exec(
      buildScriptFile.path,
      const [],
      workingDirectory: buildDir,
      environment: {
        'LIBSODIUM_FULL_BUILD': '1',
      },
    );
  }

  Future<void> _buildLipoArchive(
    Directory buildDir,
    Directory artifactDir,
  ) async {
    final libraryName = 'libsodium.$libraryType';
    final tmpDir = buildDir.subDir('libsodium-apple').subDir('tmp');

    await Github.exec('lipo', [
      '-create',
      for (final architecture in architectures)
        tmpDir.subDir(architecture).subDir('lib').subFile(libraryName).path,
      '-output',
      artifactDir.subFile(libraryName).path,
    ]);
  }
}
