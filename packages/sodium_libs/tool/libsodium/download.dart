import 'dart:io';

import '../../../../tool/util.dart';
import 'github/github_logger.dart';
import 'platforms/plugin_targets.dart';

const _libsodiumDartBindingsPublicKey =
    'RWQV/WsoL5F1nbrM9y7gJtszibGirYi+hNUI4P3orTZD8dZBCsBd7D/h';

Future<void> main(List<String> args) => GithubLogger.runZoned(() async {
      final targetGroups = args.isNotEmpty
          ? args.map(PluginTargets.groupFromName)
          : PluginTargets.targetGroups;

      for (final targetGroup in targetGroups) {
        await _downloadTarget(targetGroup);
      }
    });

Future<void> _downloadTarget(PluginTargetGroup targetGroup) =>
    GithubLogger.logGroupAsync(
      'Downloading libsodium binaries for ${targetGroup.name}',
      () async {
        final client = HttpClient();
        final tmpDir = await Directory.systemTemp.createTemp();
        try {
          final archive = await client.download(
            tmpDir,
            targetGroup.downloadUrl,
            withSignature: true,
          );

          await verify(archive, _libsodiumDartBindingsPublicKey);

          final subDir = Directory.current.subDir(targetGroup.binaryDir);
          await subDir.create(recursive: true);

          await extract(
            archive: archive,
            outDir: subDir,
          );
        } finally {
          client.close(force: true);
          await tmpDir.delete(recursive: true);
        }
      },
    );
