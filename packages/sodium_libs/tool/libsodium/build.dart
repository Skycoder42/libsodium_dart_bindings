import 'dart:io';

import 'common.dart';

Future<void> main(List<String> args) async {
  final platform = CiPlatform.values.byName(args.first);

  final CreateArtifactCb createArtifact;
  switch (platform) {
    case CiPlatform.android_arm64_v8a:
    case CiPlatform.android_armeabi_v7a:
    case CiPlatform.android_x86_64:
    case CiPlatform.android_x86:
      createArtifact = _createAndroidArtifact;
      break;
    case CiPlatform.ios:
    case CiPlatform.ios_simulator_arm64:
    case CiPlatform.ios_simulator_x86_64:
    case CiPlatform.macos_arm64:
    case CiPlatform.macos_x86_64:
      createArtifact = _createDarwinArtifact;
      break;
    case CiPlatform.windows:
      createArtifact = _createWindowsArtifact;
      break;
  }

  await buildArtifact(platform, createArtifact);
}

Future<void> _createAndroidArtifact(
  CiPlatform platform,
  Directory extractDir,
  String lastModifiedHeader,
  Directory artifactDir,
) async {
  final buildDir = extractDir.subDir('libsodium-stable');
  await run(
    './dist-build/android-${platform.buildTarget}.sh',
    const [],
    workingDirectory: buildDir,
    environment: const {
      'LIBSODIUM_FULL_BUILD': '1',
    },
  );

  final source = buildDir
      .subDir('libsodium-android-${platform.installTarget}')
      .subDir('lib')
      .subFile('libsodium.so');
  final target =
      artifactDir.subDir(platform.architecture).subFile('libsodium.so');
  await target.parent.create(recursive: true);
  await source.rename(target.path);
}

Future<void> _createDarwinArtifact(
  CiPlatform platform,
  Directory extractDir,
  String lastModifiedHeader,
  Directory artifactDir,
) async {
  final buildDir = extractDir.subDir('libsodium-stable');
  final prefixDir = buildDir.subDir('libsodium-${platform.name}');

  final xcodeDir = Directory('xcode-select -p');
  final baseDir = xcodeDir
      .subDir('Platforms')
      .subDir('${platform.sdk}.platform')
      .subDir('Developer');
  final binDir = baseDir.subDir('usr').subDir('bin');
  final sbinDir = baseDir.subDir('usr').subDir('sbin');

  final baseFlagsBuilder = StringBuffer('-arch ${platform.architecture}');

  Directory? sysrootDir;
  if (platform.hasSysroot) {
    sysrootDir = baseDir.subDir('SDKs').subDir('${platform.sdk}.sdk');
    baseFlagsBuilder.write(" -isysroot '${sysrootDir.path}'");
  }

  if (platform.extraFlags != null) {
    baseFlagsBuilder.write(' ${platform.extraFlags}');
  }

  final baseFlags = baseFlagsBuilder.toString();
  final environment = {
    'LIBSODIUM_FULL_BUILD': '1',
    'PATH': '${binDir.path}:${sbinDir.path}:${Platform.environment['PATH']}',
    if (sysrootDir != null) 'SDK:': sysrootDir.path,
    'CFLAGS': '-O2 $baseFlags',
    'LDFLAGS': baseFlags,
  };
  await run(
    './configure',
    [
      '--host=${platform.buildTarget}',
      '--prefix=${prefixDir.path}',
    ],
    workingDirectory: buildDir,
    environment: environment,
  );
  await run(
    'make',
    [
      '-j${Platform.numberOfProcessors}',
      'install',
    ],
    workingDirectory: buildDir,
    environment: environment,
  );

  final source = File(
    await prefixDir
        .subDir('lib')
        .subFile('libsodium.dylib')
        .resolveSymbolicLinks(),
  );
  final target = artifactDir.subFile('libsodium.dylib');
  await target.parent.create(recursive: true);
  await source.rename(target.path);
}

Future<void> _createWindowsArtifact(
  CiPlatform platform,
  Directory extractDir,
  String lastModifiedHeader,
  Directory artifactDir,
) async {
  const arch = 'x64';
  const libraryType = 'dynamic';
  const msvcVersions = ['v142', 'v143'];
  const releaseFiles = ['libsodium.dll'];
  const debugFiles = [...releaseFiles, 'libsodium.pdb'];
  const configurations = {
    'Debug': debugFiles,
    'Release': releaseFiles,
  };

  for (final configEntry in configurations.entries) {
    final config = configEntry.key;
    final configFiles = configEntry.value;
    for (final msvcVersion in msvcVersions) {
      for (final file in configFiles) {
        final source = extractDir
            .subDir('libsodium')
            .subDir(arch)
            .subDir(config)
            .subDir(msvcVersion)
            .subDir(libraryType)
            .subFile(file);
        final target =
            artifactDir.subDir(config).subDir(msvcVersion).subFile(file);
        await target.parent.create(recursive: true);
        await source.rename(target.path);
      }
    }
  }
}
