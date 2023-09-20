import 'dart:io';

import 'package:dart_test_tools/tools.dart';

import 'plugin_target.dart';

enum DarwinPlatform {
  ios('iPhoneOS', true, '-mios-version-min=11.0', 'a'),
  // ignore: constant_identifier_names
  ios_simulator(
    'iPhoneSimulator',
    true,
    '-mios-simulator-version-min=11.0',
    'a',
  ),
  macos('MacOSX', false, '-mmacosx-version-min=10.14', 'dylib');

  final String sdk;
  final bool hasSysroot;
  final String versionParameter;
  final String librarySuffix;

  const DarwinPlatform(
    this.sdk,
    // ignore: avoid_positional_boolean_parameters
    this.hasSysroot,
    this.versionParameter,
    this.librarySuffix,
  );
}

class DarwinTarget extends PluginTarget {
  static const _appleXcframeworScriptHash =
      // ignore: lines_longer_than_80_chars
      '8d612118531ed84c8cbcaccc5be4833eaa55bbe582f63df438f015edf47e1b82592bff433371052b25f723998940197f57b2205350af6ffe522f3d6a2bed289e';

  final DarwinPlatform platform;
  final String architecture;
  final String buildTarget;

  const DarwinTarget({
    required this.platform,
    required this.architecture,
    required this.buildTarget,
  });

  @override
  String get name => '${platform.name}_$architecture';

  @override
  String get suffix => '.tar.gz';

  @override
  Future<void> build({
    required Directory extractDir,
    required Directory artifactDir,
  }) async {
    final buildDir = extractDir.subDir('libsodium-stable');
    await _validateBuildScriptHasNotChanged(buildDir);

    final prefixDir = buildDir.subDir('build');

    final environment = await _createBuildEnvironment();

    await Github.exec(
      './configure',
      [
        '--host=$buildTarget',
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

  Future<void> _validateBuildScriptHasNotChanged(Directory buildDir) async {
    final scriptFile =
        buildDir.subDir('dist-build').subFile('apple-xcframework.sh');

    final tmpDir = await Github.env.runnerTemp.createTemp();
    try {
      final checksumFile = tmpDir.subFile('checksums.txt');
      await checksumFile
          .writeAsString('$_appleXcframeworScriptHash  ${scriptFile.path}');

      await Github.exec(
        'b2sum',
        ['-c', checksumFile.path],
      );
    } finally {
      await tmpDir.delete(recursive: true);
    }
  }

  Future<Map<String, String>> _createBuildEnvironment() async {
    // path
    final xcodeDir = Directory(
      await Github.execLines('xcode-select', const ['-p'])
          .map((l) => l.trim())
          .single,
    );
    final baseDir = xcodeDir
        .subDir('Platforms')
        .subDir('${platform.sdk}.platform')
        .subDir('Developer');
    final binDir = baseDir.subDir('usr').subDir('bin');
    final sbinDir = baseDir.subDir('usr').subDir('sbin');
    final path = [
      binDir.path,
      sbinDir.path,
      Platform.environment['PATH'],
    ];

    // compiler flags
    final ldFlags = [
      '-arch',
      architecture,
      if (platform.hasSysroot) ...[
        '-isysroot',
        baseDir.subDir('SDKs').subDir('${platform.sdk}.sdk').path,
      ],
      platform.versionParameter,
    ];
    final cFlags = ['-Ofast', ...ldFlags];

    // environment
    return {
      'LIBSODIUM_FULL_BUILD': '1',
      'PATH': path.join(':'),
      'CFLAGS': cFlags.join(' '),
      'LDFLAGS': ldFlags.join(' '),
    };
  }

  Future<void> _installLibrary(
    Directory prefixDir,
    Directory artifactDir,
  ) async {
    final source = File(
      await prefixDir
          .subDir('lib')
          .subFile('libsodium.${platform.librarySuffix}')
          .resolveSymbolicLinks(),
    );
    final target = artifactDir.subFile('libsodium.${platform.librarySuffix}');

    Github.logInfo('Installing ${target.path}');
    await target.parent.create(recursive: true);
    await source.rename(target.path);
  }
}
