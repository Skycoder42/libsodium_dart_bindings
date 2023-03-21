import 'dart:io';

import '../../../../tool/util.dart';
import 'github/github_env.dart';
import 'github/github_logger.dart';
import 'platforms/darwin_target.dart';
import 'platforms/plugin_target.dart';
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

    switch (group.publishKind) {
      case PublishKind.rsync:
        await _mergeArtifacts(group, artifactsDir, archiveDir);
        break;
      case PublishKind.lipo:
        await _createLipoLibrary(
          group: group,
          artifactsDir: artifactsDir,
          archiveDir: archiveDir,
        );
        break;
      case PublishKind.xcFramework:
        await _createXcframework(
          group: group,
          artifactsDir: artifactsDir,
          archiveDir: archiveDir,
        );
        break;
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
          await run('rsync', [
            '-av',
            '${artifactDir.path}/',
            '${archiveDir.path}/',
          ]);
        }
      },
    );

Future<void> _createLipoLibrary({
  required PluginTargetGroup group,
  required Directory artifactsDir,
  required Directory archiveDir,
}) =>
    GithubLogger.logGroupAsync(
      'Creating combined lipo library for ${group.name}',
      () => _createLipoLibraryImpl(
        outTarget: archiveDir.subFile('libsodium.dylib'),
        artifactsDir: artifactsDir,
        targets: group.targets,
      ),
    );

Future<void> _createXcframework({
  required PluginTargetGroup group,
  required Directory artifactsDir,
  required Directory archiveDir,
}) =>
    GithubLogger.logGroupAsync(
      'Creating combined xcframework for ${group.name}',
      () async {
        final platforms = <DarwinPlatform, List<DarwinTarget>>{};
        for (final target in group.targets.cast<DarwinTarget>()) {
          (platforms[target.platform] ??= []).add(target);
        }

        final lipoDir = await GithubEnv.runnerTemp.createTemp();
        try {
          // create lipo Archives
          for (final entry in platforms.entries) {
            await _createLipoLibraryImpl(
              outTarget: lipoDir.subDir(entry.key.name).subFile('libsodium.a'),
              artifactsDir: artifactsDir,
              targets: entry.value,
            );
          }

          // create xcframework
          final xcFramework = archiveDir.subDir('libsodium.xcframework');
          await run('xcodebuild', [
            '-create-xcframework',
            for (final platform in platforms.keys) ...[
              '-library',
              lipoDir.subDir(platform.name).subFile('libsodium.a').path,
            ],
            '-output',
            xcFramework.path,
          ]);
        } finally {
          await lipoDir.delete(recursive: true);
        }
      },
    );

Future<void> _createLipoLibraryImpl({
  required File outTarget,
  required Directory artifactsDir,
  required List<PluginTarget> targets,
}) async {
  final outTargetName = outTarget.uri.pathSegments.last;

  await outTarget.parent.create(recursive: true);
  await run('lipo', [
    '-create',
    ...targets.map(
      (target) => artifactsDir
          .subDir('libsodium-${target.name}')
          .subFile(outTargetName)
          .path,
    ),
    '-output',
    outTarget.path,
  ]);
}

Future<void> _archiveAndSignArtifacts({
  required Directory publishDir,
  required Directory archivesDir,
  required File secretKey,
}) =>
    GithubLogger.logGroupAsync(
      'Creating and signing archives.',
      () async {
        await publishDir.create();

        for (final targetGroup in PluginTargets.targetGroups) {
          final archiveDir = archivesDir.subDir(targetGroup.name);
          final archive = publishDir.subFile(targetGroup.artifactName);

          await compress(inDir: archiveDir, archive: archive);
          await sign(archive, secretKey);
        }
      },
    );
