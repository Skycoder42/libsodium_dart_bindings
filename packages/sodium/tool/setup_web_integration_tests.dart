import 'dart:io';

import '../../../scripts/fetch_libsodium/common.dart';
import '../../../scripts/fetch_libsodium/fetch.dart';

Future<void> main() async {
  const fetch = _FetchWeb();
  final version = await fetch.readVersion(
    '../sodium_libs/libsodium_version.json',
  );
  await fetch(version: version);
}

class _FetchWeb with FetchCommon implements Fetch {
  static const defaultOutDir = 'test/integration/binaries/js';

  const _FetchWeb();

  @override
  Future<void> call({
    required SodiumVersion version,
    String outDir = defaultOutDir,
  }) async {
    final tmpDir = await Directory.systemTemp.createTemp();
    try {
      await runSubProcess(
        'git',
        [
          'clone',
          '-b',
          version.jsVersion,
          '--depth',
          '1',
          'https://github.com/jedisct1/libsodium.js.git',
          '.',
        ],
        tmpDir,
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
      await tmpDir.delete(recursive: true);
    }
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
      sodiumTestJsSink.writeln('const sodiumJsSrc = r"""');
      await sodiumTestJsSink.addStream(sodiumJsFile.openRead());
      sodiumTestJsSink.writeln('""";');
    } finally {
      await sodiumTestJsSink.close();
    }
  }
}
