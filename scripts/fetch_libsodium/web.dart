import 'dart:io';

import 'common.dart';
import 'fetch.dart';

class FetchWeb with FetchCommon implements Fetch {
  static const defaultOutDir = 'packages/sodium/test/integration/binaries/js';

  final bool sumo;

  FetchWeb({required this.sumo});

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

      final sodiumJsFile = File.fromUri(
        tmpDir.uri.resolve(
          'dist/${sumo ? 'browsers-sumo' : 'browsers'}/sodium.js',
        ),
      );
      await sodiumJsFile.assertExists();

      // copy to sodium integration tests
      final jsTestDir = Directory(outDir);
      await jsTestDir.create(recursive: true);
      final sodiumTestJs =
          File.fromUri(jsTestDir.uri.resolve('sodium.js.dart'));
      final sodiumTestJsSink = sodiumTestJs.openWrite();
      try {
        sodiumTestJsSink.writeln('const sodiumJsSrc = r"""');
        await sodiumTestJsSink.addStream(sodiumJsFile.openRead());
        sodiumTestJsSink.writeln('""";');
      } finally {
        await sodiumTestJsSink.close();
      }
    } finally {
      await tmpDir.delete(recursive: true);
    }
  }
}
