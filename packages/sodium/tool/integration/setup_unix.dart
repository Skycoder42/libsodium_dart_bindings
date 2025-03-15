import 'dart:async';
import 'dart:io';

import 'package:dart_test_tools/tools.dart';

import '../../../sodium_libs/libsodium_version.dart';

Future<void> main(List<String> args) => Github.runZoned(() async {
  final platform = args.first;

  await Github.logGroupAsync(
    'Ensure minisign is installed',
    Minisign.ensureInstalled,
  );

  final tmpDir = await Directory.systemTemp.createTemp();
  try {
    final buildDir = await _downloadAndVerify(tmpDir);
    await _build(buildDir, platform);
    await _install(buildDir);
  } finally {
    Github.logInfo('Cleaning up');
    await tmpDir.delete(recursive: true);
  }
});

Future<Directory> _downloadAndVerify(Directory tmpDir) => Github.logGroupAsync(
  'Download, verify and extract libsodium sources',
  () async {
    final baseUri = Uri.https(
      'download.libsodium.org',
      '/libsodium/releases/libsodium-${libsodium_version.ffi}-stable.tar.gz',
    );

    final httpClient = HttpClient();
    final archive = await httpClient.download(tmpDir, baseUri);
    await Minisign.verify(archive, libsodiumSigningKey);
    await Archive.extract(archive: archive, outDir: tmpDir);

    return tmpDir.subDir('libsodium-stable');
  },
);

Future<void> _build(Directory buildDir, String platform) =>
    Github.logGroupAsync('Build libsodium', () async {
      final installDir = Directory.current
          .subDir('test')
          .subDir('integration')
          .subDir('binaries')
          .subDir(platform);

      await Github.exec('./configure', [
        '--enable-shared=yes',
        '--prefix=${installDir.absolute.path}',
      ], workingDirectory: buildDir);

      await Github.exec('make', [
        '-j${Platform.numberOfProcessors}',
      ], workingDirectory: buildDir);
    });

Future<void> _install(Directory buildDir) =>
    Github.logGroupAsync('Install libsodium', () async {
      await Github.exec('make', const ['install'], workingDirectory: buildDir);
    });
