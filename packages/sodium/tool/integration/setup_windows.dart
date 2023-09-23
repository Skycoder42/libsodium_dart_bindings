import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_test_tools/tools.dart';

import '../../../sodium_libs/libsodium_version.dart';

const _defaultOutDir = 'test/integration/binaries/win';
const _defaultArch = 'x64';
const _defaultMode = 'Release';
const _defaultVsVersion = 'v142';

Future<void> main(List<String> rawArgs) => Github.runZoned(() async {
      final parser = ArgParser(allowTrailingOptions: false)
        ..addOption(
          'arch',
          abbr: 'a',
          defaultsTo: _defaultArch,
        )
        ..addOption(
          'release-mode',
          abbr: 'm',
          defaultsTo: _defaultMode,
        )
        ..addOption(
          'vs-version',
          abbr: 's',
          defaultsTo: _defaultVsVersion,
        )
        ..addFlag('help', abbr: 'h', negatable: false);

      final args = parser.parse(rawArgs);
      if (args['help'] as bool) {
        stdout.writeln(parser.usage);
        return;
      }

      await Github.logGroupAsync(
        'Ensure minisign is installed',
        Minisign.ensureInstalled,
      );

      await _run(
        arch: args['arch'] as String,
        mode: args['release-mode'] as String,
        vsVersion: args['vs-version'] as String,
      );
    });

Future<void> _run({
  required String arch,
  required String mode,
  required String vsVersion,
}) =>
    Github.logGroupAsync('Download, verify and extract libsodium MSVC binaries',
        () async {
      final baseUri = Uri.https(
        'download.libsodium.org',
        '/libsodium/releases/libsodium-${libsodium_version.ffi}-stable-msvc.zip',
      );

      final tmpDir = await Directory.systemTemp.createTemp();
      final httpClient = HttpClient();
      try {
        final archive = await httpClient.download(
          tmpDir,
          baseUri,
        );
        await Minisign.verify(archive, libsodiumSigningKey);
        await Archive.extract(archive: archive, outDir: tmpDir);

        final binariesDir = tmpDir
            .subDir('libsodium')
            .subDir(arch)
            .subDir(mode)
            .subDir(vsVersion)
            .subDir('dynamic')
          ..assertExists();

        final winTestDir = Directory(_defaultOutDir);
        await winTestDir.parent.create(recursive: true);
        Github.logInfo('Moving ${binariesDir.path} to ${winTestDir.path}');
        await binariesDir.rename(winTestDir.path);
      } finally {
        Github.logInfo('Cleaning up');
        await tmpDir.delete(recursive: true);
      }
    });
