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
    final prefixDir = buildDir.subDir('build');

    final environment = await _createBuildEnvironment();

    await Github.exec(
      './configure',
      [
        '--enable-shared=yes',
        '--host=$_architecture-unknown-linux-gnu',
        '--prefix=${prefixDir.path}',
      ],
      workingDirectory: buildDir,
      environment: environment,
    );

    await Github.exec(
      'make',
      [
        '-j${Platform.numberOfProcessors}',
        'install',
      ],
      workingDirectory: buildDir,
      environment: environment,
    );

    await _installLibrary(prefixDir, artifactDir);
  }

  Future<Map<String, String>> _createBuildEnvironment() async {
    // compiler flags
    final cFlags = ['-Os'];

    // environment
    return {
      'CFLAGS': cFlags.join(' '),
      'CC': '$_architecture-linux-gnu-gcc',
    };
  }

  Future<void> _installLibrary(
    Directory prefixDir,
    Directory artifactDir,
  ) async {
    final source = File(
      await prefixDir
          .subDir('lib')
          .subFile('libsodium.so')
          .resolveSymbolicLinks(),
    );
    final target = artifactDir.subDir(_architecture).subFile('libsodium.so');

    await Github.exec('patchelf', [
      '--set-soname',
      'libsodium.so',
      source.path,
    ]);

    Github.logInfo('Installing ${target.path}');
    await target.parent.create(recursive: true);
    await source.rename(target.path);
  }
}
