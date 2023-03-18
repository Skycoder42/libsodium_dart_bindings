import 'dart:io';

import '../../../../tool/util.dart';
import 'github/github_env.dart';
import 'github/github_logger.dart';
import 'platforms/plugin_targets.dart';

Future<void> main(List<String> args) async {
  final workspaceDir = GithubEnv.githubWorkspace;
  final artifactsDir = workspaceDir.subDir('artifacts');
  final archivesDir = workspaceDir.subDir('archive');
  final publishDir = workspaceDir.subDir('publish');
  final secretKey = GithubEnv.runnerTemp.subFile('minisign.key');

  await _createArchive(
    artifactsDir: artifactsDir,
    archivesDir: archivesDir,
  );

  await _archiveAndSignArtifacts(
    publishDir: publishDir,
    archivesDir: archivesDir,
    secretKey: secretKey,
  );
}

Future<void> _createArchive({
  required Directory artifactsDir,
  required Directory archivesDir,
}) async {
  for (final group in PluginTargets.targetGroups) {
    final archiveDir =
        await archivesDir.subDir(group.name).create(recursive: true);

    if (group.useLipo) {
      await _combineDylibs(
        group: group,
        artifactsDir: artifactsDir,
        archiveDir: archiveDir,
      );
    } else {
      await _mergeArtifacts(group, artifactsDir, archiveDir);
    }
  }
}

Future<void> _mergeArtifacts(
  PluginTargetGroup group,
  Directory artifactsDir,
  Directory archiveDir,
) =>
    GithubLogger.logGroupAsync(
      'Creating archive for ${group.name} by merging artifacts',
      () async {
        for (final target in group.targets) {
          final artifactDir = artifactsDir.subDir('libsodium-${target.name}');
          if (artifactDir.existsSync()) {
            continue;
          }

          await run('rsync', [
            '-a',
            '${artifactDir.path}/',
            '${archiveDir.path}/',
          ]);
        }
      },
    );

Future<void> _combineDylibs({
  required PluginTargetGroup group,
  required Directory artifactsDir,
  required Directory archiveDir,
}) =>
    GithubLogger.logGroupAsync(
      'Creating archive for ${group.name} by creating lipo combined binary',
      () async {
        final targetFile = archiveDir.subFile('libsodium.dylib');
        await targetFile.parent.create(recursive: true);
        await run('lipo', [
          '-create',
          ...group.targets.map(
            (target) => artifactsDir
                .subDir('libsodium-${target.name}')
                .subFile('libsodium.dylib')
                .path,
          ),
          '-output',
          targetFile.path,
        ]);
      },
    );

Future<void> _archiveAndSignArtifacts({
  required Directory publishDir,
  required Directory archivesDir,
  required File secretKey,
}) =>
    GithubLogger.logGroupAsync(
      'Creating and signing archives.',
      () async {
        await publishDir.create();

        final dirs = archivesDir
            .list(followLinks: false)
            .where((e) => e is Directory)
            .cast<Directory>();
        await for (final directory in dirs) {
          // "last" is otherwise the trailing slash
          final dirName = directory.uri.pathSegments.reversed.skip(1).first;
          final archive = publishDir.subFile('libsodium-$dirName.tar.xz');

          await run(
            'tar',
            ['-cJf', archive.path, '.'],
            workingDirectory: directory,
          );

          await sign(archive, secretKey);
        }
      },
    );
