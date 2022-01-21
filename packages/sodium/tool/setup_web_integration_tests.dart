import 'dart:io';

import 'package:args/args.dart';

import '../../../tool/util.dart' as util;
import '../../sodium_libs/libsodium_version.dart' show libsodium_version;

const _defaultOutDir = 'test/integration/binaries/js';

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
      defaultsTo: libsodium_version.js,
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
  final tmpDir = await Directory.systemTemp.createTemp();
  try {
    await _cloneTo(
      version: version,
      targetDir: tmpDir,
    );
    await _createJsSrc(
      tmpDir: tmpDir,
      outDir: outDir,
      moduleName: 'browsers',
      outFileName: 'sodium.js.dart',
    );
    await _createJsSrc(
      tmpDir: tmpDir,
      outDir: outDir,
      moduleName: 'browsers-sumo',
      outFileName: 'sodium_sumo.js.dart',
    );
  } finally {
    stdout.writeln('> Cleaning up');
    await tmpDir.delete(recursive: true);
  }
}

Future<void> _cloneTo({
  required String version,
  required Directory targetDir,
}) async {
  stdout
      .writeln('> Cloning jedisct1/libsodium.js@$version to ${targetDir.path}');
  await util.run(
    'git',
    [
      'clone',
      '-b',
      version,
      '--depth',
      '1',
      'https://github.com/jedisct1/libsodium.js.git',
      '.',
    ],
    workingDirectory: targetDir,
  );
}

Future<void> _createJsSrc({
  required Directory tmpDir,
  required String outDir,
  required String moduleName,
  required String outFileName,
}) async {
  final sodiumJsFile = File.fromUri(
    tmpDir.uri.resolve('dist/$moduleName/sodium.js'),
  );
  await sodiumJsFile.assertExists();

  final jsTestDir = Directory(outDir);
  await jsTestDir.create(recursive: true);
  final sodiumTestJs = File.fromUri(jsTestDir.uri.resolve(outFileName));
  final sodiumTestJsSink = sodiumTestJs.openWrite();
  try {
    stdout.writeln('> Creating ${sodiumTestJs.path} from ${sodiumJsFile.path}');
    sodiumTestJsSink.writeln('const sodiumJsSrc = r"""');
    await sodiumTestJsSink.addStream(sodiumJsFile.openRead());
    sodiumTestJsSink.writeln('""";');
  } finally {
    await sodiumTestJsSink.close();
  }
}
