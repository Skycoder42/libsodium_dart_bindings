import 'dart:io';

import 'package:dart_test_tools/tools.dart';

import 'platforms/darwin_target.dart';
import 'platforms/plugin_target.dart';
import 'platforms/plugin_targets.dart';

Future<void> main(List<String> args) async {
  final targetGroups = args.isNotEmpty
      ? args.map(PluginTargets.groupFromName).toList()
      : PluginTargets.targetGroups;

  final workspaceDir = Github.env.githubWorkspace;
  final artifactsDir = workspaceDir.subDir('artifacts');
  final archivesDir = workspaceDir.subDir('archive');
  final publishDir = workspaceDir.subDir('publish');
  final secretKey = Github.env.runnerTemp.subFile('minisign.key');

  await _createArchive(
    targetGroups: targetGroups,
    artifactsDir: artifactsDir,
    archivesDir: archivesDir,
  );

  await _archiveAndSignArtifacts(
    targetGroups: targetGroups,
    publishDir: publishDir,
    archivesDir: archivesDir,
    secretKey: secretKey,
  );
}

Future<void> _createArchive({
  required List<PluginTargetGroup> targetGroups,
  required Directory artifactsDir,
  required Directory archivesDir,
}) async {
  for (final group in targetGroups) {
    final archiveDir =
        await archivesDir.subDir(group.name).create(recursive: true);

    switch (group.publishKind) {
      case PublishKind.rsync:
        await _mergeArtifacts(group, artifactsDir, archiveDir);
      case PublishKind.lipo:
        await _createLipoLibrary(
          group: group,
          artifactsDir: artifactsDir,
          archiveDir: archiveDir,
        );
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

Future<void> _createLipoLibrary({
  required PluginTargetGroup group,
  required Directory artifactsDir,
  required Directory archiveDir,
}) =>
    Github.logGroupAsync(
      'Creating combined lipo library for ${group.name}',
      () async {
        final libsodiumDylib = archiveDir.subFile('libsodium.dylib');
        await _createLipoLibraryImpl(
          outTarget: libsodiumDylib,
          artifactsDir: artifactsDir,
          targets: group.targets,
        );

        await Github.exec('install_name_tool', [
          '-id',
          '@rpath/libsodium.dylib',
          libsodiumDylib.path,
        ]);
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
        final platforms = <DarwinPlatform, List<DarwinTarget>>{};
        for (final target in group.targets.cast<DarwinTarget>()) {
          (platforms[target.platform] ??= []).add(target);
        }

        final lipoDir = await Github.env.runnerTemp.createTemp();
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
          await Github.exec('xcodebuild', [
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
  await Github.exec('lipo', [
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
  required List<PluginTargetGroup> targetGroups,
  required Directory publishDir,
  required Directory archivesDir,
  required File secretKey,
}) =>
    Github.logGroupAsync(
      'Creating and signing archives.',
      () async {
        await publishDir.create();

        for (final targetGroup in targetGroups) {
          final archiveDir = archivesDir.subDir(targetGroup.name);
          final archive = publishDir.subFile(targetGroup.artifactName);

          await Archive.compress(inDir: archiveDir, archive: archive);
          await Minisign.sign(archive, secretKey);
        }
      },
    );
