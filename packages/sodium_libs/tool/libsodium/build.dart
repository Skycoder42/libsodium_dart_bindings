import 'dart:async';
import 'dart:io';

import '../../../../tool/util.dart';
import 'github/github_env.dart';
import 'github/github_logger.dart';
import 'platforms/plugin_target.dart';
import 'platforms/plugin_targets.dart';

Future<void> main(List<String> args) => GithubLogger.runZoned(() async {
      final platform = PluginTargets.fromName(args.first);

      final tmpDir = await GithubEnv.runnerTemp.createTemp();
      try {
        await _getArchive(tmpDir, platform.downloadUrl);
        await _build(platform, tmpDir);
      } finally {
        await tmpDir.delete(recursive: true);
      }
    });

Future<void> _build(PluginTarget platform, Directory tmpDir) =>
    GithubLogger.logGroupAsync(
      'Build libsodium-${platform.name} artifact',
      () async {
        final artifactDir = await GithubEnv.runnerTemp
            .subDir('libsodium-${platform.name}')
            .create();

        await platform.build(
          extractDir: tmpDir,
          artifactDir: artifactDir,
        );
      },
    );

Future<void> _getArchive(
  Directory downloadDir,
  Uri downloadUrl,
) =>
    GithubLogger.logGroupAsync(
      'Download, verify and extract $downloadUrl',
      () async {
        final httpClient = HttpClient();
        try {
          final archive = await httpClient.download(
            downloadDir,
            downloadUrl,
            withSignature: true,
          );
          await verify(archive);
          await extract(archive: archive, outDir: downloadDir);
        } finally {
          httpClient.close(force: true);
        }
      },
    );
