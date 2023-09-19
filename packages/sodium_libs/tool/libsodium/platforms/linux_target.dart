import 'dart:convert';
import 'dart:io';

import 'package:dart_test_tools/tools.dart';

import 'plugin_target.dart';

class LinuxTarget extends PluginTarget {
  static const _zigPublicKey = 'RWSGOq2NVecA2UPNdBUZykf1CCb147pkmdtYxgb3Ti';

  final String _architecture;

  const LinuxTarget({
    required String architecture,
  }) : _architecture = architecture;

  @override
  String get name => 'linux_$_architecture';

  @override
  String get suffix => '.tar.gz';

  @override
  Future<void> build({
    required Directory extractDir,
    required Directory artifactDir,
  }) async {
    final zigPath = await _installZig();

    final buildDir = extractDir.subDir('libsodium-stable');

    await Github.exec(
      zigPath,
      [
        'build',
        '-Doptimize=ReleaseFast',
        '-Dtarget=$_architecture-linux',
        '-Dstatic=false',
        '-Dtests=false',
      ],
      workingDirectory: buildDir,
    );

    final source =
        buildDir.subDir('zig-out').subDir('lib').subFile('libsodium.so');
    final target = artifactDir.subDir(_architecture).subFile('libsodium.so');

    Github.logInfo('Installing ${target.path}');
    await target.parent.create(recursive: true);
    await source.rename(target.path);
  }

  Future<String> _installZig() async {
    final tmpDir = await Github.env.runnerTemp.createTemp();
    final zigDir = await Github.env.runnerTemp.subDir('zig').create();
    final client = HttpClient();
    try {
      final zigIndexRequest = await client
          .getUrl(Uri.parse('https://ziglang.org/download/index.json'));
      final zigIndexResponse = await zigIndexRequest.close();
      final zigTarball = await zigIndexResponse
          .transform(utf8.decoder)
          .transform(json.decoder)
          .cast<Map>()
          .map((map) => map.entries.skip(1).first.value as Map)
          .map((map) => map['x86_64-linux'] as Map)
          .map((map) => map['tarball'] as String)
          .single;

      final zig = await client.download(tmpDir, Uri.parse(zigTarball));
      await Minisign.verify(zig, _zigPublicKey);
      await Archive.extract(archive: zig, outDir: zigDir);

      return zigDir.subFile('zig').path;
    } finally {
      client.close();
      await tmpDir.delete(recursive: true);
    }
  }
}
