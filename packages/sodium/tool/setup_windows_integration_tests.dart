import 'dart:io';

import 'package:args/args.dart';

import '../../../scripts/fetch_libsodium/common.dart';
import '../../../scripts/fetch_libsodium/fetch.dart';

Future<void> main(List<String> rawArgs) async {
  final parser = ArgParser(allowTrailingOptions: false)
    ..addOption(
      'version-file',
      abbr: 'v',
      defaultsTo: _FetchWindows.defaultVersionPath,
    )
    ..addOption(
      'out-dir',
      abbr: 'o',
      defaultsTo: _FetchWindows.defaultOutDir,
    )
    ..addOption(
      'arch',
      abbr: 'a',
      defaultsTo: _FetchWindows.defaultArch,
    )
    ..addOption(
      'release-mode',
      abbr: 'm',
      defaultsTo: _FetchWindows.defaultMode,
    )
    ..addOption(
      'vs-version',
      abbr: 's',
      defaultsTo: _FetchWindows.defaultVsVersion,
    )
    ..addFlag('help', abbr: 'h', negatable: false);

  final args = parser.parse(rawArgs);
  if (args['help'] as bool) {
    stdout.writeln(parser.usage);
    return;
  }

  const fetch = _FetchWindows();
  final version = await fetch.readVersion(args['version-file'] as String);
  await fetch(
    version: version,
    outDir: args['out-dir'] as String,
    arch: args['arch'] as String,
    mode: args['release-mode'] as String,
    vsVersion: args['vs-version'] as String,
  );
}

class _FetchWindows with FetchCommon implements Fetch {
  static const defaultVersionPath = '../sodium_libs/libsodium_version.json';
  static const defaultOutDir = 'test/integration/binaries/win';
  static const defaultArch = 'x64';
  static const defaultMode = 'Release';
  static const defaultVsVersion = 'v142';

  const _FetchWindows();

  @override
  Future<void> call({
    required SodiumVersion version,
    String outDir = defaultOutDir,
    String arch = defaultArch,
    String mode = defaultMode,
    String vsVersion = defaultVsVersion,
  }) async {
    final releaseDir = await downloadRelease(
      version.ffiVersion,
      platform: 'msvc',
      isZip: true,
    );
    try {
      final libsodiumDll = File.fromUri(
        releaseDir.uri
            .resolve('libsodium/$arch/$mode/$vsVersion/dynamic/libsodium.dll'),
      );
      await libsodiumDll.assertExists();

      // copy to sodium integration testfelixf
      final winTestDir = Directory(outDir);
      await winTestDir.create(recursive: true);
      await libsodiumDll.copy(
        winTestDir.uri.resolve('libsodium.dll').toFilePath(),
      );
    } finally {
      await releaseDir.delete(recursive: true);
    }
  }
}
