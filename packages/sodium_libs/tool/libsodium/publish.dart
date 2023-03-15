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
  for (final ciPlatform in CiPlatform.values) {
    final artifactDir = artifactsDir.subDir('libsodium-${ciPlatform.name}');
    if (!artifactDir.existsSync()) {
      continue;
    }

    final archiveDir = await archivesDir
        .subDir(ciPlatform.installGroup)
        .create(recursive: true);
    await run('rsync', [
      '-a',
      '${artifactDir.path}/',
      '${archiveDir.path}/',
    ]);
  }
}

Future<void> _archiveAndSignArtifacts({
  required Directory publishDir,
  required Directory archivesDir,
  required File secretKey,
}) async {
  await publishDir.create();
  await for (final directory in archivesDir.list()) {
    final dirName = directory.uri.pathSegments.last;
    final archive = publishDir.subFile('libsodium-$dirName.tar.xz');

    await run(
      'tar',
      ['-cJvf', archive.path, dirName],
      workingDirectory: directory.parent,
    );

    await sign(archive, secretKey);
  }
}
