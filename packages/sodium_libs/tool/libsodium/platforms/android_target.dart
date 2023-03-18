import 'dart:io';

import '../../../../../tool/util.dart';
import '../github/github_logger.dart';
import 'plugin_target.dart';

class AndroidTarget extends PluginTarget {
  final String _architecture;
  final String _buildTarget;
  final String _installTarget;

  const AndroidTarget({
    required String architecture,
    String? buildTarget,
    String? installTarget,
  })  : _architecture = architecture,
        _buildTarget = buildTarget ?? architecture,
        _installTarget = installTarget ?? buildTarget ?? architecture;

  @override
  String get name => 'android_$_architecture';

  @override
  String get suffix => '.tar.gz';

  @override
  Future<void> build({
    required Directory extractDir,
    required Directory artifactDir,
  }) async {
    final buildDir = extractDir.subDir('libsodium-stable');
    await run(
      './dist-build/android-$_buildTarget.sh',
      const [],
      workingDirectory: buildDir,
      environment: const {
        'LIBSODIUM_FULL_BUILD': '1',
      },
    );

    final source = buildDir
        .subDir('libsodium-android-$_installTarget')
        .subDir('lib')
        .subFile('libsodium.so');
    final target = artifactDir.subDir(_architecture).subFile('libsodium.so');

    GithubLogger.logInfo('Installing ${target.path}');
    await target.parent.create(recursive: true);
    await source.rename(target.path);
  }
}
