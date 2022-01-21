import 'dart:io';

import 'package:args/args.dart';

import '../../../tool/util.dart' as util;
import '../libsodium_version.dart' show libsodium_version;

const _defaultOutDir = 'android/src/main/jniLibs';

Future<void> main(List<String> rawArgs) async {
  final parser = ArgParser(allowTrailingOptions: false)
    ..addOption(
      'out-dir',
      abbr: 'o',
      defaultsTo: _defaultOutDir,
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
    version: args['version'] as String,
  );
}

Future<void> _run({
  required String outDir,
  required String version,
}) async {
  final targetDir = Directory(outDir);
  await targetDir.create(recursive: true);

  final downloadUri = Uri.https(
    'github.com',
    '/Skycoder42/libsodium_dart_bindings/releases/download/libsodium-binaries/android/v$version/libsodium-android.tar.gz',
  );

  final httpClient = HttpClient();
  final tmpDir = await Directory.systemTemp.createTemp();
  try {
    final outFile = await httpClient.download(tmpDir, downloadUri);
    await util.extract(
      archive: outFile,
      outDir: targetDir,
    );
  } finally {
    stdout.writeln('> Cleaning up');
    httpClient.close();
    await tmpDir.delete(recursive: true);
  }
}
