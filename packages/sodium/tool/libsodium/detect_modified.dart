import 'dart:io';

import 'package:dart_test_tools/tools.dart';

import 'package:sodium/src/hooks/constants.dart';

Future<void> main() => Github.runZoned(() async {
  final lastModified = await _getLastModified();

  final lastModifiedFile = File('tool/libsodium/.last-modified.txt');
  if (lastModifiedFile.existsSync()) {
    final oldLastModified = await lastModifiedFile.readAsString().then(
      (content) => content.trim(),
    );

    if (lastModified == oldLastModified) {
      Github.logNotice('Upstream archive is unchanged');
      await Github.env.setOutput('modified', false);
      return;
    }
  }

  Github.logNotice('Upstream archive has been modified!');
  await lastModifiedFile.writeAsString(lastModified);
  await Github.env.setOutput('version', HookConstants.libsodiumVersion.ffi);
  await Github.env.setOutput('last-modified', lastModified);
  await Github.env.setOutput('modified', true);
});

Future<String> _getLastModified() async {
  final httpClient = HttpClient();
  try {
    Github.logInfo(
      'Getting last modified header for: '
      '${HookConstants.libsodiumSrcDownloadUri}',
    );
    return await httpClient.getHeader(
      HookConstants.libsodiumSrcDownloadUri,
      HttpHeaders.lastModifiedHeader,
    );
  } finally {
    httpClient.close(force: true);
  }
}
