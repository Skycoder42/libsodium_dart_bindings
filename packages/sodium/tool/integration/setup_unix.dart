import 'dart:async';
import 'dart:io';

import 'package:dart_test_tools/tools.dart';

import '../../../sodium_libs/libsodium_version.dart';

Future<void> main() => Github.runZoned(() async {
      await Github.logGroupAsync(
        'Ensure minisign is installed',
        Minisign.ensureInstalled,
      );

      final tmpDir = await Directory.systemTemp.createTemp();
      try {
        final buildDir = await _downloadAndVerify(tmpDir);
        await _build(buildDir);
        await _install(buildDir);
      } finally {
        Github.logInfo('Cleaning up');
        await tmpDir.delete(recursive: true);
      }
    });

Future<Directory> _downloadAndVerify(Directory tmpDir) =>
    Github.logGroupAsync('Download, verify and extract libsodium sources',
        () async {
      final baseUri = Uri.https(
        'download.libsodium.org',
        '/libsodium/releases/libsodium-${libsodium_version.ffi}-stable.tar.gz',
      );

      final httpClient = HttpClient();
      final archive = await httpClient.download(
        tmpDir,
        baseUri,
      );
      await Minisign.verify(archive, libsodiumSigningKey);
      await Archive.extract(archive: archive, outDir: tmpDir);

      return tmpDir.subDir('libsodium-stable');
    });

Future<void> _build(Directory buildDir) =>
    Github.logGroupAsync('Build libsodium', () async {
      await Github.exec(
        './configure',
        const ['--enable-shared=yes'],
        workingDirectory: buildDir,
      );

      await Github.exec(
        'make',
        ['-j${Platform.numberOfProcessors}'],
        workingDirectory: buildDir,
      );
    });

Future<void> _install(Directory buildDir) =>
    Github.logGroupAsync('Install libsodium', () async {
      await Github.exec(
        'sudo',
        const ['make', 'install'],
        workingDirectory: buildDir,
      );
    });
