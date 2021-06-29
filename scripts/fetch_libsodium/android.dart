import 'dart:convert';
import 'dart:io';

import 'common.dart';
import 'fetch.dart';

class FetchAndroid with FetchCommon implements Fetch {
  static const defaultOutDir = 'packages/sodium_libs/android/src/main/jniLibs';
  static const defaultPlatforms = ['arm64-v8a', 'armeabi-v7a', 'x86_64', 'x86'];

  Future<void> call({
    required SodiumVersion version,
    String outDir = defaultOutDir,
    List<String> platforms = defaultPlatforms,
  }) async {
    final dlDir = await downloadRelease(version.ffiVersion);
    try {
      final srcDir = dlDir.subDir('libsodium-stable');
      for (final platform in platforms) {
        final installDir = await _buildPlatform(srcDir, platform);
        final libFile = installDir.subFile('lib/libsodium.so');
        await libFile.assertExists();

        final resultDir = Directory(outDir).subDir(platform);
        final resultFileCopy = File.fromUri(
          resultDir.uri.resolve(libFile.uri.pathSegments.last),
        );

        await resultDir.create(recursive: true);
        await libFile.copy(resultFileCopy.path);
        await resultFileCopy.assertExists();
      }
    } finally {
      await dlDir.delete(recursive: true);
    }
  }

  Future<Directory> _buildPlatform(Directory srcDir, String platform) async {
    final lineRegExp = RegExp(r'^libsodium has been installed into (.*)$');

    late Directory installDir;
    await streamSubProcess(
      './dist-build/android-${_buildName(platform)}.sh',
      const [],
      srcDir,
    ).transform(utf8.decoder).transform(const LineSplitter()).map(
      (line) {
        final lineMatch = lineRegExp.firstMatch(line);
        if (lineMatch != null) {
          installDir = Directory(lineMatch[1]!);
        }
        stdout.writeln(line);
      },
    ).drain();

    return installDir;
  }

  String _buildName(String platform) {
    switch (platform) {
      case 'arm64-v8a':
        return 'armv8-a';
      case 'armeabi-v7a':
        return 'armv7-a';
      default:
        return platform;
    }
  }
}
