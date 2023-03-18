import 'dart:async';
import 'dart:io';

import '../../../../tool/util.dart';
import 'github/github_env.dart';
import 'github/github_logger.dart';
import 'platforms/plugin_target.dart';
import 'platforms/plugin_targets.dart';

Future<void> main(List<String> args) => GithubLogger.runZoned(() async {
      final platform = PluginTargets.fromName(args.first);

      final tmpDir = await GithubEnv.runnerTemp.createTemp();
      try {
        await _getArchive(tmpDir, platform.downloadUrl);
        await _build(platform, tmpDir);
      } finally {
        await tmpDir.delete(recursive: true);
      }
    });

Future<void> _build(PluginTarget platform, Directory tmpDir) =>
    GithubLogger.logGroupAsync(
      'Build libsodium-${platform.name} artifact',
      () async {
        final artifactDir = await GithubEnv.runnerTemp
            .subDir('libsodium-${platform.name}')
            .create();

        await platform.build(
          extractDir: tmpDir,
          artifactDir: artifactDir,
        );
      },
    );

Future<void> _getArchive(
  Directory downloadDir,
  Uri downloadUrl,
) =>
    GithubLogger.logGroupAsync(
      'Download, verify and extract $downloadUrl',
      () async {
        final httpClient = HttpClient();
        try {
          final archive = await httpClient.download(
            downloadDir,
            downloadUrl,
            withSignature: true,
          );
          await verify(archive);
          await extract(archive: archive, outDir: downloadDir);
        } finally {
          httpClient.close(force: true);
        }
      },
    );

// Future<void> _createAndroidArtifact(
//   CiPlatform platform,
//   Directory extractDir,
//   String lastModifiedHeader,
//   Directory artifactDir,
// ) async {
//   final buildDir = extractDir.subDir('libsodium-stable');
//   await run(
//     './dist-build/android-${platform.buildTarget}.sh',
//     const [],
//     workingDirectory: buildDir,
//     environment: const {
//       'LIBSODIUM_FULL_BUILD': '1',
//     },
//   );

//   final source = buildDir
//       .subDir('libsodium-android-${platform.installTarget}')
//       .subDir('lib')
//       .subFile('libsodium.so');
//   final target =
//       artifactDir.subDir(platform.architecture).subFile('libsodium.so');
//   await target.parent.create(recursive: true);
//   await source.rename(target.path);
// }

// Future<void> _createDarwinArtifact(
//   CiPlatform platform,
//   Directory extractDir,
//   String lastModifiedHeader,
//   Directory artifactDir,
// ) async {
//   final buildDir = extractDir.subDir('libsodium-stable');
//   final prefixDir = buildDir.subDir('libsodium-${platform.name}');

//   final xcodeDir = Directory(await _invoke('xcode-select', const ['-p']));
//   final baseDir = xcodeDir
//       .subDir('Platforms')
//       .subDir('${platform.sdk}.platform')
//       .subDir('Developer');
//   final binDir = baseDir.subDir('usr').subDir('bin');
//   final sbinDir = baseDir.subDir('usr').subDir('sbin');

//   final baseFlagsBuilder = StringBuffer('-arch ${platform.architecture}');

//   if (platform.hasSysroot) {
//     final sysrootDir = baseDir.subDir('SDKs').subDir('${platform.sdk}.sdk');
//     baseFlagsBuilder.write(' -isysroot ${sysrootDir.path}');
//   }

//   if (platform.extraFlags != null) {
//     baseFlagsBuilder.write(' ${platform.extraFlags}');
//   }

//   final baseFlags = baseFlagsBuilder.toString();
//   final environment = {
//     'LIBSODIUM_FULL_BUILD': '1',
//     'PATH': '${binDir.path}:${sbinDir.path}:${Platform.environment['PATH']}',
//     'CFLAGS': '-Ofast $baseFlags',
//     'LDFLAGS': baseFlags,
//   };
//   await run(
//     './configure',
//     [
//       '--host=${platform.buildTarget}',
//       '--prefix=${prefixDir.path}',
//     ],
//     workingDirectory: buildDir,
//     environment: environment,
//   );
//   await run(
//     'make',
//     [
//       '-j${Platform.numberOfProcessors}',
//       'install',
//     ],
//     workingDirectory: buildDir,
//     environment: environment,
//   );

//   final source = File(
//     await prefixDir
//         .subDir('lib')
//         .subFile('libsodium.dylib')
//         .resolveSymbolicLinks(),
//   );
//   final target = artifactDir.subFile('libsodium.dylib');
//   await target.parent.create(recursive: true);
//   await source.rename(target.path);
// }


// Future<String> _invoke(String executable, List<String> arguments) async {
//   final processResult = await Process.run(executable, arguments);
//   if (processResult.exitCode != 0) {
//     throw ChildErrorException(exitCode);
//   }
//   return (processResult.stdout as String).trimRight();
// }
