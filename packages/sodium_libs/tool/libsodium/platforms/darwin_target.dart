import 'dart:io';

import 'package:dart_test_tools/tools.dart';

import '../../../libsodium_version.dart' show libsodium_version;
import 'plugin_target.dart';
import 'plugin_targets.dart';

enum DarwinPlatform {
  ios('iPhoneOS', true, '-mios-version-min=12.0'),
  // ignore: constant_identifier_names
  ios_simulator('iPhoneSimulator', true, '-mios-simulator-version-min=12.0'),
  macos('MacOSX', false, '-mmacosx-version-min=10.14', 'A');

  final String sdk;
  final bool hasSysroot;
  final String versionParameter;
  final String? frameworkVersion;

  const DarwinPlatform(
    this.sdk,
    // ignore: avoid_positional_boolean_parameters
    this.hasSysroot,
    this.versionParameter, [
    this.frameworkVersion,
  ]);
}

class DarwinTarget extends PluginTarget {
  // ignore: constant_identifier_names
  static const ios_arm64 = DarwinTarget(
    platform: DarwinPlatform.ios,
    architecture: 'arm64',
    buildTarget: 'aarch64-apple-darwin23',
  );
  // ignore: constant_identifier_names
  static const ios_arm64e = DarwinTarget(
    platform: DarwinPlatform.ios,
    architecture: 'arm64e',
    buildTarget: 'aarch64-apple-darwin23',
  );
  // ignore: constant_identifier_names
  static const ios_simulator_arm64 = DarwinTarget(
    platform: DarwinPlatform.ios_simulator,
    architecture: 'arm64',
    buildTarget: 'aarch64-apple-darwin23',
  );
  // ignore: constant_identifier_names
  static const ios_simulator_arm64e = DarwinTarget(
    platform: DarwinPlatform.ios_simulator,
    architecture: 'arm64e',
    buildTarget: 'aarch64-apple-darwin23',
  );
  // ignore: constant_identifier_names
  static const ios_simulator_x86_64 = DarwinTarget(
    platform: DarwinPlatform.ios_simulator,
    architecture: 'x86_64',
    buildTarget: 'x86_64-apple-darwin23',
  );
  // ignore: constant_identifier_names
  static const macos_arm64 = DarwinTarget(
    platform: DarwinPlatform.macos,
    architecture: 'arm64',
    buildTarget: 'aarch64-apple-darwin23',
  );
  // ignore: constant_identifier_names
  static const macos_arm64e = DarwinTarget(
    platform: DarwinPlatform.macos,
    architecture: 'arm64e',
    buildTarget: 'aarch64-apple-darwin23',
  );
  // ignore: constant_identifier_names
  static const macos_x86_64 = DarwinTarget(
    platform: DarwinPlatform.macos,
    architecture: 'x86_64',
    buildTarget: 'x86_64-apple-darwin23',
  );
  static const iosValues = [
    ios_arm64,
    ios_arm64e,
    ios_simulator_arm64,
    ios_simulator_arm64e,
    ios_simulator_x86_64,
  ];
  static const macosValues = [macos_arm64, macos_arm64e, macos_x86_64];
  static const values = [...iosValues, ...macosValues];

  // get hash: curl -sSL https://raw.githubusercontent.com/jedisct1/libsodium/refs/heads/master/dist-build/apple-xcframework.sh | b2sum
  // last update: 2024-12-31
  static const _appleXcframeworkScriptHash =
      // ignore: lines_longer_than_80_chars
      '5aa4efd30f914f85da881e4cb4eeeeb8cc65864c0ecfaba854e96326e790e6151ee53f962c25532548c1f2ecbc2d9c514a4238750e74ee57c5eaee0e603bbe38';

  static final _frameworkInfoPlist =
      '''
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>libsodium</string>
  <key>CFBundleIdentifier</key>
  <string>org.libsodium.libsodium</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>libsodium</string>
  <key>CFBundlePackageType</key>
  <string>FMWK</string>
  <key>CFBundleShortVersionString</key>
  <string>${libsodium_version.ffi}</string>
  <key>CFBundleSignature</key>
  <string>????</string>
  <key>CFBundleVersion</key>
  <string>${libsodium_version.ffi}</string>
  <key>MinimumOSVersion</key>
  <string>12.0</string>
</dict>
</plist>
''';

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
      ['--host=$buildTarget', '--prefix=${prefixDir.path}'],
      workingDirectory: buildDir,
      environment: environment,
    );

    await Github.exec(
      'make',
      ['-j${Platform.numberOfProcessors}', 'install'],
      workingDirectory: buildDir,
      environment: environment,
    );

    await _installLibraryWithHeaders(prefixDir, artifactDir);
  }

  Future<void> _validateBuildScriptHasNotChanged(Directory buildDir) async {
    final scriptFile = buildDir
        .subDir('dist-build')
        .subFile('apple-xcframework.sh');

    final tmpDir = await Github.env.runnerTemp.createTemp();
    try {
      final checksumFile = tmpDir.subFile('checksums.txt');
      await checksumFile.writeAsString(
        '$_appleXcframeworkScriptHash  ${scriptFile.path}',
      );

      await Github.exec('b2sum', ['-c', checksumFile.path]);
    } finally {
      await tmpDir.delete(recursive: true);
    }
  }

  Future<Map<String, String>> _createBuildEnvironment() async {
    // path
    final xcodeDir = Directory(
      await Github.execLines('xcode-select', const [
        '-p',
      ]).map((l) => l.trim()).single,
    );
    final baseDir = xcodeDir
        .subDir('Platforms')
        .subDir('${platform.sdk}.platform')
        .subDir('Developer');
    final binDir = baseDir.subDir('usr').subDir('bin');
    final sbinDir = baseDir.subDir('usr').subDir('sbin');
    final path = [binDir.path, sbinDir.path, Platform.environment['PATH']];

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
    final cFlags = ['-O3', ...ldFlags];

    // environment
    return {
      'PATH': path.join(':'),
      'CFLAGS': cFlags.join(' '),
      'LDFLAGS': ldFlags.join(' '),
    };
  }

  Future<void> _installLibraryWithHeaders(
    Directory prefixDir,
    Directory artifactDir,
  ) async {
    final sourceIncludes = prefixDir.subDir('include');
    final targetIncludes = artifactDir.subDir('include');

    final sourceLib = File(
      await prefixDir
          .subDir('lib')
          .subFile('libsodium.dylib')
          .resolveSymbolicLinks(),
    );
    final targetLib = artifactDir.subFile('libsodium.dylib');

    await targetLib.parent.create(recursive: true);
    Github.logInfo('Installing ${targetIncludes.path}');
    await sourceIncludes.rename(targetIncludes.path);
    Github.logInfo('Installing ${targetLib.path}');
    await sourceLib.rename(targetLib.path);
  }

  static Future<void> createXcFramework({
    required PluginTargetGroup group,
    required Directory artifactsDir,
    required Directory archiveDir,
  }) => Github.logGroupAsync(
    'Creating combined xcframework for ${group.name}',
    () async {
      const frameworkName = 'libsodium';

      final platforms = <DarwinPlatform, List<DarwinTarget>>{};
      for (final target in group.targets.cast<DarwinTarget>()) {
        (platforms[target.platform] ??= []).add(target);
      }

      final tmpDir = await Github.env.runnerTemp.createTemp();
      try {
        // create frameworks
        final frameworks = <Directory>[];
        for (final MapEntry(key: platform, value: targets)
            in platforms.entries) {
          frameworks.add(
            await _createFramework(
              name: frameworkName,
              artifactsDir: artifactsDir,
              targets: targets,
              outDir: tmpDir.subDir(platform.name),
            ),
          );
        }

        // create xcframework
        await _createXcFramework(
          name: frameworkName,
          frameworks: frameworks,
          outDir: archiveDir,
        );
      } finally {
        await tmpDir.delete(recursive: true);
      }
    },
  );

  static Directory _dirForTarget(Directory artifactsDir, DarwinTarget target) =>
      artifactsDir.subDir('libsodium-${target.name}');

  static Future<File> _createLipoLibrary({
    required String name,
    required String rpath,
    required Directory artifactsDir,
    required List<DarwinTarget> targets,
    required Directory outDir,
  }) async {
    final library = outDir.subFile(name);
    await Github.exec('lipo', [
      '-create',
      ...targets.map(
        (target) =>
            _dirForTarget(artifactsDir, target).subFile('$name.dylib').path,
      ),
      '-output',
      library.path,
    ]);

    await Github.exec('install_name_tool', [
      '-id',
      '@rpath/$rpath',
      library.path,
    ]);

    return library;
  }

  static Future<Directory> _createFramework({
    required String name,
    required Directory artifactsDir,
    required List<DarwinTarget> targets,
    required Directory outDir,
  }) async {
    final framework = await outDir
        .subDir('$name.framework')
        .create(recursive: true);

    var addSymlinks = false;
    var dataDir = framework;
    var resourceDir = framework;
    if (targets.first.platform.frameworkVersion
        case final String frameworkVersion) {
      addSymlinks = true;
      final versions = await framework.subDir('Versions').create();
      final version = await versions.subDir(frameworkVersion).create();
      resourceDir = await version.subDir('Resources').create();
      await versions.createLink('Current', to: frameworkVersion);
      dataDir = version;
    }

    await resourceDir
        .subFile('Info.plist')
        .writeAsString(DarwinTarget._frameworkInfoPlist);

    final headersDir = _dirForTarget(
      artifactsDir,
      targets.first,
    ).subDir('include');
    await headersDir.rename(dataDir.subDir('Headers').path);

    await _createLipoLibrary(
      name: name,
      rpath: '$name.framework/$name',
      artifactsDir: artifactsDir,
      targets: targets,
      outDir: dataDir,
    );

    if (addSymlinks) {
      await framework.createLink(name, to: 'Versions/Current/$name');
      await framework.createLink('Headers', to: 'Versions/Current/Headers');
      await framework.createLink('Resources', to: 'Versions/Current/Resources');
    }

    return framework;
  }

  static Future<Directory> _createXcFramework({
    required String name,
    required Iterable<Directory> frameworks,
    required Directory outDir,
  }) async {
    final xcFramework = outDir.subDir('$name.xcframework');
    await Github.exec('xcodebuild', [
      '-create-xcframework',
      for (final framework in frameworks) ...['-framework', framework.path],
      '-output',
      xcFramework.path,
    ]);
    return xcFramework;
  }

  static Future<List<String>> computeHash(
    File archive,
    String originalHash,
  ) async {
    final archiveDir = archive.parent;
    final package = await archiveDir.subFile('Package.swift').create();
    final checksum = await Github.execLines('swift', [
      'package',
      'compute-checksum',
      archive.path,
    ], workingDirectory: archiveDir).single;
    await package.delete();
    return [originalHash, checksum];
  }
}

extension on Directory {
  Future<Link> createLink(String path, {required String to}) =>
      Link.fromUri(uri.resolve(path)).create(to);
}
