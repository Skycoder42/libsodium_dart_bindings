import 'dart:io';

import 'package:dart_test_tools/tools.dart';

import 'platforms/plugin_targets.dart';

const _libsodiumDartBindingsPublicKey =
    'RWQV/WsoL5F1nbrM9y7gJtszibGirYi+hNUI4P3orTZD8dZBCsBd7D/h';

Future<void> main(List<String> args) => Github.runZoned(() async {
      final targetGroups = args.isNotEmpty
          ? args.map(PluginTargets.groupFromName)
          : PluginTargets.targetGroups;

      for (final targetGroup in targetGroups) {
        await _downloadTarget(targetGroup);
      }
    });

Future<void> _downloadTarget(PluginTargetGroup targetGroup) =>
    Github.logGroupAsync(
      'Downloading libsodium binaries for ${targetGroup.name}',
      () async {
        final client = HttpClient();
        final tmpDir = await Directory.systemTemp.createTemp();
        try {
          final archive = await client.download(
            tmpDir,
            targetGroup.downloadUrl,
          );

          await Minisign.verify(archive, _libsodiumDartBindingsPublicKey);

          final subDir = Directory.current
              .subDir(targetGroup.name)
              .subDir(targetGroup.binaryDir);
          await subDir.create(recursive: true);

          await Archive.extract(
            archive: archive,
            outDir: subDir,
          );
        } finally {
          client.close(force: true);
          await tmpDir.delete(recursive: true);
        }
      },
    );
