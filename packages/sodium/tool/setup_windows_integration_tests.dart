import 'dart:io';

import 'package:args/args.dart';
import 'package:dart_test_tools/tools.dart';

import '../../sodium_libs/libsodium_version.dart';

const _defaultOutDir = 'test/integration/binaries/win';
const _defaultArch = 'x64';
const _defaultMode = 'Release';
const _defaultVsVersion = 'v142';

Future<void> main(List<String> rawArgs) async {
  final parser = ArgParser(allowTrailingOptions: false)
    ..addOption(
      'out-dir',
      abbr: 'o',
      defaultsTo: _defaultOutDir,
    )
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
    ..addOption(
      'version',
      abbr: 'v',
      defaultsTo: libsodium_version.ffi,
    )
    ..addFlag('help', abbr: 'h', negatable: false);

  final args = parser.parse(rawArgs);
  if (args['help'] as bool) {
    stdout.writeln(parser.usage);
    return;
  }

  await _run(
    outDir: args['out-dir'] as String,
    arch: args['arch'] as String,
    mode: args['release-mode'] as String,
    vsVersion: args['vs-version'] as String,
    version: args['version'] as String,
  );
}

Future<void> _run({
  required String outDir,
  required String arch,
  required String mode,
  required String vsVersion,
  required String version,
}) async {
  final baseUri = Uri.https(
    'download.libsodium.org',
    '/libsodium/releases/libsodium-$version-stable-msvc.zip',
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

    final libsodiumDll = File.fromUri(
      tmpDir.uri
          .resolve('libsodium/$arch/$mode/$vsVersion/dynamic/libsodium.dll'),
    )..assertExists();

    final winTestDir = Directory(outDir);
    await winTestDir.create(recursive: true);
    stdout.writeln('> Copying ${libsodiumDll.path} to ${winTestDir.path}');
    await libsodiumDll.copy(
      winTestDir.uri.resolve('libsodium.dll').toFilePath(),
    );
  } finally {
    stdout.writeln('> Cleaning up');
    await tmpDir.delete(recursive: true);
  }
}
