import 'dart:io';

import 'package:dart_test_tools/tools.dart';

import 'plugin_target.dart';

class LinuxTarget extends PluginTarget {
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
    final buildDir = extractDir.subDir('libsodium-stable');

    await Github.exec(
      '/home/vscode/zig/zig',
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
}
