// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import '../../../../tool/util.dart';
import '../../libsodium_version.dart';

export '../../../../tool/util.dart';

enum CiPlatform {
  // ignore: constant_identifier_names
  android_arm64_v8a(
    '.tar.gz',
    architecture: 'arm64_v8a',
    buildTarget: 'armv8-a',
    installTarget: 'armv8-a+crypto',
    installGroup: 'android',
  ),
  // ignore: constant_identifier_names
  android_armeabi_v7a(
    '.tar.gz',
    architecture: 'armeabi_v7a',
    buildTarget: 'armv7-a',
    installGroup: 'android',
  ),
  // ignore: constant_identifier_names
  android_x86_64(
    '.tar.gz',
    architecture: 'x86_64',
    installTarget: 'westmere',
    installGroup: 'android',
  ),
  // ignore: constant_identifier_names
  android_x86(
    '.tar.gz',
    architecture: 'x86',
    installTarget: 'i686',
    installGroup: 'android',
  ),
  ios(
    '.tar.gz',
    architecture: 'arm64',
    buildTarget: 'arm-apple-darwin10',
    sdk: 'iPhoneOS',
    hasSysroot: true,
    extraFlags: '-mios-version-min=9.0',
    installGroup: 'ios',
    useLipo: true,
  ),
  // ignore: constant_identifier_names
  ios_simulator_arm64(
    '.tar.gz',
    architecture: 'arm64',
    buildTarget: 'arm-apple-darwin20',
    sdk: 'iPhoneSimulator',
    hasSysroot: true,
    extraFlags: '-mios-simulator-version-min=9.0',
    installGroup: 'ios',
    useLipo: true,
  ),
  // ignore: constant_identifier_names
  ios_simulator_x86_64(
    '.tar.gz',
    architecture: 'x86_64',
    buildTarget: 'x86_64-apple-darwin10',
    sdk: 'iPhoneSimulator',
    hasSysroot: true,
    extraFlags: '-mios-simulator-version-min=9.0',
    installGroup: 'ios',
    useLipo: true,
  ),
  // ignore: constant_identifier_names
  macos_arm64(
    '.tar.gz',
    architecture: 'arm64',
    buildTarget: 'arm-apple-darwin20',
    sdk: 'MacOSX',
    extraFlags: '-mmacosx-version-min=10.11',
    installGroup: 'macos',
    useLipo: true,
  ),
  // ignore: constant_identifier_names
  macos_x86_64(
    '.tar.gz',
    architecture: 'x86_64',
    buildTarget: 'x86_64-apple-darwin10',
    sdk: 'MacOSX',
    extraFlags: '-mmacosx-version-min=10.11',
    installGroup: 'macos',
    useLipo: true,
  ),
  windows('-msvc.zip');

  final String _suffix;
  final String? _architecture;
  final String? _buildTarget;
  final String? _sdk;
  final bool hasSysroot;
  final String? extraFlags;
  final String? _installTarget;
  final String? _installGroup;
  final bool useLipo;

  const CiPlatform(
    this._suffix, {
    String? architecture,
    String? buildTarget,
    String? sdk,
    this.hasSysroot = false,
    this.extraFlags,
    String? installTarget,
    String? installGroup,
    this.useLipo = false,
  })  : _architecture = architecture,
        _buildTarget = buildTarget,
        _sdk = sdk,
        _installTarget = installTarget,
        _installGroup = installGroup;

  Uri get downloadUrl => Uri.https(
        'download.libsodium.org',
        '/libsodium/releases/libsodium-${libsodium_version.ffi}-stable$_suffix',
      );

  String get architecture => _architecture ?? name;

  String get buildTarget => _buildTarget ?? architecture;

  String get sdk => _sdk ?? name;

  String get installTarget => _installTarget ?? buildTarget;

  String get installGroup => _installGroup ?? name;
}

abstract class GithubEnv {
  GithubEnv._();

  static Directory get runnerTemp {
    final runnerTemp = Platform.environment['RUNNER_TEMP'];
    return runnerTemp != null ? Directory(runnerTemp) : Directory.systemTemp;
  }

  static Directory get githubWorkspace {
    final githubWorkspace = Platform.environment['GITHUB_WORKSPACE'];
    return githubWorkspace != null
        ? Directory(githubWorkspace)
        : Directory.current.subDir('../..');
  }

  static void logNotice(String message) => print('::notice::$message');

  static Future<void> setOutput(
    String name,
    Object? value, {
    bool multiline = false,
  }) async {
    final githubOutput = Platform.environment['GITHUB_OUTPUT'];
    if (githubOutput == null) {
      throw Exception('Cannot set output! GITHUB_OUTPUT env var is not set');
    }

    final githubOutputFile = File(githubOutput);
    if (multiline) {
      await githubOutputFile.writeAsString(
        '$name<<EOF\n$value\nEOF\n',
        mode: FileMode.append,
      );
    } else {
      await githubOutputFile.writeAsString(
        '$name=$value\n',
        mode: FileMode.append,
      );
    }
  }

  static Future<void> run(FutureOr<void> Function() main) async {
    try {
      await main();
      // ignore: avoid_catches_without_on_clauses
    } catch (error, stackTrace) {
      print('::error::$error');
      print('::group::Stack-Trace');
      print(stackTrace);
      print('::endgroup::');
      exitCode = 1;
    }
  }
}

typedef CreateArtifactCb = FutureOr<void> Function(
  CiPlatform platform,
  Directory extractDir,
  String lastModifiedHeader,
  Directory artifactDir,
);

Future<void> buildArtifact(
  CiPlatform platform,
  CreateArtifactCb createArtifact,
) async {
  final httpClient = HttpClient();
  final tmpDir = await GithubEnv.runnerTemp.createTemp();
  try {
    const lastModifiedHeader = '';

    final archive = await httpClient.download(
      tmpDir,
      platform.downloadUrl,
      withSignature: true,
    );
    await verify(archive);
    await extract(archive: archive, outDir: tmpDir);

    final artifactDir = await GithubEnv.runnerTemp
        .subDir('libsodium-${platform.name}')
        .create();
    await createArtifact(
      platform,
      tmpDir,
      lastModifiedHeader,
      artifactDir,
    );
    await artifactDir
        .subFile('last-modified.txt')
        .writeAsString(lastModifiedHeader);
  } finally {
    await tmpDir.delete(recursive: true);
    httpClient.close(force: true);
  }
}

File getLastModifiedFile() => File('tool/libsodium/.last-modified.txt');
