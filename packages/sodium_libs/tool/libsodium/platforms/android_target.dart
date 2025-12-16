import 'dart:io';

import 'package:dart_test_tools/tools.dart';

import 'plugin_target.dart';

class AndroidTarget extends PluginTarget {
  // ignore: constant_identifier_names for consistent naming
  static const arm64_v8a = AndroidTarget(
    architecture: 'arm64-v8a',
    buildTarget: 'armv8-a',
    installTarget: 'armv8-a+crypto',
  );
  // ignore: constant_identifier_names for consistent naming
  static const armeabi_v7a = AndroidTarget(
    architecture: 'armeabi-v7a',
    buildTarget: 'armv7-a',
  );
  static const x86_64 = AndroidTarget(
    architecture: 'x86_64',
    installTarget: 'westmere',
  );
  static const x86 = AndroidTarget(architecture: 'x86', installTarget: 'i686');
  static const values = [arm64_v8a, armeabi_v7a, x86_64, x86];

  final String _architecture;
  final String _buildTarget;
  final String _installTarget;

  const AndroidTarget({
    required String architecture,
    String? buildTarget,
    String? installTarget,
  }) : _architecture = architecture,
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
    await Github.exec(
      './dist-build/android-$_buildTarget.sh',
      const [],
      workingDirectory: buildDir,
      environment: const {
        'NDK_PLATFORM': 'android-21',
        'LIBSODIUM_FULL_BUILD': '1',
      },
    );

    final source = buildDir
        .subDir('libsodium-android-$_installTarget')
        .subDir('lib')
        .subFile('libsodium.so');
    final target = artifactDir.subDir(_architecture).subFile('libsodium.so');

    Github.logInfo('Installing ${target.path}');
    await target.parent.create(recursive: true);
    await source.rename(target.path);
  }
}
