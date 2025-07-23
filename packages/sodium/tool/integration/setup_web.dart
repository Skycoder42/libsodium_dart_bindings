import 'dart:async';
import 'dart:io';

import 'package:dart_test_tools/tools.dart';

import '../../../sodium_libs/libsodium_version.dart' show libsodium_version;

const _defaultOutDir = 'test/integration/binaries/js';

Future<void> main() => Github.runZoned(() async {
  final tmpDir = await Directory.systemTemp.createTemp();
  try {
    await _cloneTo(targetDir: tmpDir);
    await _createJsSrc(
      tmpDir: tmpDir,
      moduleName: 'browsers',
      outFileName: 'sodium.js.dart',
    );
    await _createJsSrc(
      tmpDir: tmpDir,
      moduleName: 'browsers-sumo',
      outFileName: 'sodium_sumo.js.dart',
    );
  } finally {
    Github.logInfo('Cleaning up');
    await tmpDir.delete(recursive: true);
  }
});

Future<void> _cloneTo({required Directory targetDir}) => Github.logGroupAsync(
  'Cloning jedisct1/libsodium.js@${libsodium_version.js}',
  () async {
    await Github.exec('git', [
      'clone',
      '-b',
      libsodium_version.js,
      '--depth',
      '1',
      'https://github.com/jedisct1/libsodium.js.git',
      '.',
    ], workingDirectory: targetDir);
  },
);

Future<void> _createJsSrc({
  required Directory tmpDir,
  required String moduleName,
  required String outFileName,
}) => Github.logGroupAsync('Creating $outFileName from sources', () async {
  final sodiumJsFile =
      tmpDir.subDir('dist').subDir(moduleName).subFile('sodium.js')
        ..assertExists();

  final jsTestDir = Directory(_defaultOutDir);
  await jsTestDir.create(recursive: true);
  final sodiumTestJs = jsTestDir.subFile(outFileName);
  final sodiumTestJsSink = sodiumTestJs.openWrite();
  try {
    sodiumTestJsSink.writeln('const sodiumJsSrc = r"""');
    await sodiumTestJsSink.addStream(sodiumJsFile.openRead());
    sodiumTestJsSink.writeln('""";');
  } finally {
    await sodiumTestJsSink.close();
  }
});
