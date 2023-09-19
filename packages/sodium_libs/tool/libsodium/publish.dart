import 'dart:io';

import 'package:dart_test_tools/tools.dart';

import 'platforms/darwin_target.dart';
import 'platforms/plugin_targets.dart';

Future<void> main(List<String> args) async {
  final workspaceDir = Github.env.githubWorkspace;
  final artifactsDir = workspaceDir.subDir('artifacts');
  final archivesDir = workspaceDir.subDir('archive');
  final publishDir = workspaceDir.subDir('publish');
  final secretKey = Github.env.runnerTemp.subFile('minisign.key');

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

    switch (group.publishKind) {
      case PublishKind.rsync:
        await _mergeArtifacts(group, artifactsDir, archiveDir);
      case PublishKind.xcFramework:
        await _createXcframework(
          group: group,
          artifactsDir: artifactsDir,
          archiveDir: archiveDir,
        );
    }
  }
}

Future<void> _mergeArtifacts(
  PluginTargetGroup group,
  Directory artifactsDir,
  Directory archiveDir,
) =>
    Github.logGroupAsync(
      'Creating archive for ${group.name} by merging artifacts',
      () async {
        for (final target in group.targets) {
          final artifactDir = artifactsDir.subDir('libsodium-${target.name}');
          await Github.exec('rsync', [
            '-av',
            '${artifactDir.path}/',
            '${archiveDir.path}/',
          ]);
        }
      },
    );

Future<void> _createXcframework({
  required PluginTargetGroup group,
  required Directory artifactsDir,
  required Directory archiveDir,
}) =>
    Github.logGroupAsync(
      'Creating combined xcframework for ${group.name}',
      () async {
        // create xcframework
        final xcFramework = archiveDir.subDir('libsodium.xcframework');
        await Github.exec('xcodebuild', [
          '-create-xcframework',
          for (final platform in group.targets.cast<DarwinTarget>()) ...[
            '-library',
            artifactsDir
                .subDir('libsodium-${platform.platform}')
                .subFile('libsodium.${platform.libraryType}')
                .path,
          ],
          '-output',
          xcFramework.path,
        ]);
      },
    );

Future<void> _archiveAndSignArtifacts({
  required Directory publishDir,
  required Directory archivesDir,
  required File secretKey,
}) =>
    Github.logGroupAsync(
      'Creating and signing archives.',
      () async {
        await publishDir.create();

        for (final targetGroup in PluginTargets.targetGroups) {
          final archiveDir = archivesDir.subDir(targetGroup.name);
          final archive = publishDir.subFile(targetGroup.artifactName);

          await Archive.compress(inDir: archiveDir, archive: archive);
          await Minisign.sign(archive, secretKey);
        }
      },
    );
