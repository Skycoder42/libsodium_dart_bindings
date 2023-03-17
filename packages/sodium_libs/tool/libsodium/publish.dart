import 'dart:io';

import 'common.dart';

Future<void> main(List<String> args) async {
  final workspaceDir = GithubEnv.githubWorkspace;
  final artifactsDir = workspaceDir.subDir('artifacts');
  final archivesDir = workspaceDir.subDir('archive');
  final publishDir = workspaceDir.subDir('publish');
  final secretKey = GithubEnv.runnerTemp.subFile('minisign.key');

  await _mergeArtifacts(
    artifactsDir: artifactsDir,
    archivesDir: archivesDir,
  );

  await _archiveAndSignArtifacts(
    publishDir: publishDir,
    archivesDir: archivesDir,
    secretKey: secretKey,
  );
}

Future<void> _mergeArtifacts({
  required Directory artifactsDir,
  required Directory archivesDir,
}) async {
  final lipoGroups = <String, List<CiPlatform>>{};

  for (final platform in CiPlatform.values) {
    final artifactDir = artifactsDir.subDir('libsodium-${platform.name}');
    if (!artifactDir.existsSync()) {
      continue;
    }

    if (platform.useLipo) {
      (lipoGroups[platform.installGroup] ??= []).add(platform);
      continue;
    }

    final archiveDir =
        await archivesDir.subDir(platform.installGroup).create(recursive: true);
    await run('rsync', [
      '-a',
      '${artifactDir.path}/',
      '${archiveDir.path}/',
    ]);
  }

  for (final entry in lipoGroups.entries) {
    await _createLipoArchive(
      group: entry.key,
      platforms: entry.value,
      artifactsDir: artifactsDir,
      archivesDir: archivesDir,
    );
  }
}

Future<void> _createLipoArchive({
  required String group,
  required List<CiPlatform> platforms,
  required Directory artifactsDir,
  required Directory archivesDir,
}) async {
  final targetFile = archivesDir.subDir(group).subFile('libsodium.dylib');
  await targetFile.parent.create(recursive: true);
  await run('lipo', [
    'create',
    ...platforms.map(
      (p) => artifactsDir
          .subDir('libsodium-${p.name}')
          .subFile('libsodium.dylib')
          .path,
    ),
    '-output',
    targetFile.path,
  ]);
}

Future<void> _archiveAndSignArtifacts({
  required Directory publishDir,
  required Directory archivesDir,
  required File secretKey,
}) async {
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
}
