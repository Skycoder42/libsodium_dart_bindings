import 'dart:async';
import 'dart:io';

import 'package:dart_test_tools/tools.dart';

import '../../libsodium_version.dart';
import 'platforms/plugin_target.dart';
import 'platforms/plugin_targets.dart';

Future<void> main(List<String> args) => Github.runZoned(() async {
      final platform = PluginTargets.fromName(args.first);

      await Github.logGroupAsync(
        'Ensure minisign is installed',
        Minisign.ensureInstalled,
      );

      final tmpDir = await Github.env.runnerTemp.createTemp();
      try {
        await _getArchive(tmpDir, platform.downloadUrl);
        await _build(platform, tmpDir);
      } finally {
        await tmpDir.delete(recursive: true);
      }
    });

Future<void> _build(PluginTarget platform, Directory tmpDir) =>
    Github.logGroupAsync(
      'Build libsodium-${platform.name} artifact',
      () async {
        final artifactDir = await Github.env.runnerTemp
            .subDir('libsodium-${platform.name}')
            .create();

        try {
          await platform.build(
            extractDir: tmpDir,
            artifactDir: artifactDir,
          );
        } on Exception {
          final logFile =
              tmpDir.subDir('libsodium-stable').subFile('config.log');
          if (logFile.existsSync()) {
            final lines = await logFile.readAsLines();
            lines.forEach(Github.logError);
          }
          rethrow;
        }
      },
    );

Future<void> _getArchive(
  Directory downloadDir,
  Uri downloadUrl,
) =>
    Github.logGroupAsync(
      'Download, verify and extract $downloadUrl',
      () async {
        final httpClient = HttpClient();
        try {
          final archive = await httpClient.download(
            downloadDir,
            downloadUrl,
          );
          await Minisign.verify(archive, libsodiumSigningKey);
          await Archive.extract(archive: archive, outDir: downloadDir);
        } finally {
          httpClient.close(force: true);
        }
      },
    );
