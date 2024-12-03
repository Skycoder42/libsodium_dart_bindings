import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dart_test_tools/tools.dart';

import 'platforms/plugin_platform.dart';
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

  await Github.logGroupAsync(
    'Ensure minisign is installed',
    Minisign.ensureInstalled,
  );

  await _createArchive(
    targetGroups: targetGroups,
    artifactsDir: artifactsDir,
    archivesDir: archivesDir,
  );

  await _archiveAndSignArtifacts(
    targetPlatforms: targetGroups.map((g) => g.platform),
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

    if (group.publish case final PublishCallback publish) {
      await publish(
        group: group,
        artifactsDir: artifactsDir,
        archiveDir: archiveDir,
      );
    } else {
      await _mergeArtifacts(
        group: group,
        artifactsDir: artifactsDir,
        archiveDir: archiveDir,
      );
    }
  }
}

Future<void> _mergeArtifacts({
  required PluginTargetGroup group,
  required Directory artifactsDir,
  required Directory archiveDir,
}) =>
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

Future<void> _archiveAndSignArtifacts({
  required Iterable<PluginPlatform> targetPlatforms,
  required Directory publishDir,
  required Directory archivesDir,
  required File secretKey,
}) =>
    Github.logGroupAsync(
      'Creating and signing archives.',
      () async {
        await publishDir.create();

        final hashSums = <String, String>{};
        for (final targetGroup in targetPlatforms) {
          final archiveDir = archivesDir.subDir(targetGroup.name);
          final archive = publishDir.subFile(targetGroup.artifactName);

          await Archive.compress(inDir: archiveDir, archive: archive);
          await Minisign.sign(archive, secretKey);
          hashSums[targetGroup.name] = await _sha512sum(archive);
        }

        await Github.env.setOutput('hash-sums', json.encode(hashSums));
      },
    );

Future<String> _sha512sum(File target) => target
    .openRead()
    .transform(sha512)
    .map((digest) => digest.toString())
    .single;
