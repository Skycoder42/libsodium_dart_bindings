import 'dart:io';

import 'package:dart_test_tools/tools.dart';

import '../../libsodium_version.dart';
import 'platforms/plugin_targets.dart';

Future<void> main() => Github.runZoned(() async {
      // always set version, in case of a forced build
      await Github.env.setOutput('version', libsodium_version.ffi);

      final downloadUrls =
          PluginTargets.allTargets.map((t) => t.downloadUrl).toSet();

      final lastModifiedMap = <Uri, String>{};
      final httpClient = HttpClient();
      try {
        for (final downloadUrl in downloadUrls) {
          Github.logInfo(
            'Getting last modified header for: $downloadUrl',
          );
          final lastModifiedHeader = await httpClient.getHeader(
            downloadUrl,
            HttpHeaders.lastModifiedHeader,
          );

          lastModifiedMap[downloadUrl] = lastModifiedHeader;
        }
      } finally {
        httpClient.close(force: true);
      }

      final newLastModified = _buildLastModifiedFile(lastModifiedMap);
      await Github.env.setOutput(
        'last-modified-content',
        newLastModified,
        multiline: true,
      );

      final lastModifiedFile = _getLastModifiedFile();
      if (lastModifiedFile.existsSync()) {
        final oldLastModified = await _getLastModifiedFile()
            .readAsString()
            .then((content) => content.trim());
        if (newLastModified == oldLastModified) {
          Github.logNotice('All upstream archives are unchanged');
          await Github.env.setOutput('modified', false);
          return;
        }
      }

      Github.logNotice(
        'At least one upstream archive has been modified!',
      );
      await Github.env.setOutput('modified', true);
    });

String _buildLastModifiedFile(Map<Uri, String> lastModifiedMap) {
  final lines = lastModifiedMap.entries
      .map((e) => '${e.key} - ${e.value}\n')
      .toList()
    ..sort();
  return lines.join().trim();
}

File _getLastModifiedFile() => File('tool/libsodium/.last-modified.txt');
