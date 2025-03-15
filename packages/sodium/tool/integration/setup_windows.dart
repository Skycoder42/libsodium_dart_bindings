import 'dart:async';
import 'dart:io';

import 'package:dart_test_tools/tools.dart';

import '../../../sodium_libs/libsodium_version.dart';

Future<void> main(List<String> rawArgs) => Github.runZoned(() async {
  await Github.logGroupAsync(
    'Ensure minisign is installed',
    Minisign.ensureInstalled,
  );

  await _run();
});

Future<void> _run() => Github.logGroupAsync(
  'Download, verify and extract libsodium MSVC binaries',
  () async {
    final installDir = Directory.current
        .subDir('test')
        .subDir('integration')
        .subDir('binaries')
        .subDir('windows');

    final baseUri = Uri.https(
      'download.libsodium.org',
      '/libsodium/releases/libsodium-${libsodium_version.ffi}-stable-msvc.zip',
    );

    final tmpDir = await Directory.systemTemp.createTemp();
    final httpClient = HttpClient();
    try {
      final archive = await httpClient.download(tmpDir, baseUri);
      await Minisign.verify(archive, libsodiumSigningKey);
      await Archive.extract(archive: archive, outDir: installDir.parent);

      await installDir.parent.subDir('libsodium').rename(installDir.path);
    } finally {
      Github.logInfo('Cleaning up');
      await tmpDir.delete(recursive: true);
    }
  },
);
