import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:meta/meta.dart';

import 'automake_builder.dart';

@immutable
@internal
class AndroidArchConfig {
  final String host;
  final List<String> cFlags;
  final List<String> ldFlags;
  final Uri toolchainDir;

  const AndroidArchConfig({
    required this.host,
    required this.cFlags,
    required this.ldFlags,
    required this.toolchainDir,
  });

  Iterable<Object?> get _hashValues sync* {
    yield host;
    yield* cFlags;
    yield* ldFlags;
    yield toolchainDir;
  }
}

@internal
final class AndroidBuilder extends AutomakeBuilder {
  late final Uri _ndkPath;
  late final AndroidArchConfig _archConfig;

  AndroidBuilder(super.config, super.logger);

  @override
  Future<void> prepare() async {
    _ndkPath = await _getAndroidNdkPath();
    logger.info('Detected Android NDK path: ${_ndkPath.toFilePath()}');
    _archConfig = _mapArchConfig();
  }

  @override
  Iterable<Object?> get configHash sync* {
    yield* super.configHash;
    yield config.android.targetNdkApi;
    yield _ndkPath;
    yield _archConfig._hashValues;
  }

  @override
  // ignore: must_call_super as build hook args are not usable yet
  Map<String, String> get environment => {
    'CFLAGS': _archConfig.cFlags.join(' '),
    'LDFLAGS': _archConfig.ldFlags.join(' '),
    'PATH': [
      _archConfig.toolchainDir.resolve('bin').toFilePath(),
      ?Platform.environment['PATH'],
    ].join(OS.current == .windows ? ';' : ':'),
    'CC': '${_archConfig.host}${config.android.targetNdkApi}-clang',
  };

  @override
  Iterable<String> get configureArgs sync* {
    yield* super.configureArgs;
    yield '--host=${_archConfig.host}';
    yield '--with-sysroot='
        '${_archConfig.toolchainDir.resolve("sysroot").toFilePath()}';
  }

  AndroidArchConfig _mapArchConfig() => AndroidArchConfig(
    host: _mapHost(config.targetArchitecture),
    cFlags: [
      '-Os',
      ..._mapExtraCFlags(config.targetArchitecture),
      '-march=${_mapTargetArch(config.targetArchitecture)}',
    ],
    ldFlags: const ['-Wl,-z,max-page-size=16384'],
    toolchainDir: _ndkPath.resolve(
      'toolchains/llvm/prebuilt/${_mapHostPlatform()}-x86_64/',
    ),
  );

  String _mapTargetArch(Architecture arch) => switch (arch) {
    .arm64 => 'armv8-a+crypto',
    .arm => 'armv7-a',
    .x64 => 'westmere',
    .ia32 => 'i686',
    _ => throw UnsupportedError('Unsupported android architecture: $arch'),
  };

  String _mapHost(Architecture arch) => switch (arch) {
    .arm64 => 'aarch64-linux-android',
    .arm => 'armv7a-linux-androideabi',
    .x64 => 'x86_64-linux-android',
    .ia32 => 'i686-linux-android',
    _ => throw UnsupportedError('Unsupported android architecture: $arch'),
  };

  String _mapHostPlatform() => switch (OS.current) {
    .windows => 'windows',
    .linux => 'linux',
    .macOS => 'darwin',
    _ => throw UnsupportedError('Unsupported host platform: ${OS.current}'),
  };

  Iterable<String> _mapExtraCFlags(Architecture arch) => switch (arch) {
    .arm => const ['-mfloat-abi=softfp', '-mfpu=vfpv3-d16', '-mthumb', '-marm'],
    _ => const [],
  };

  Future<Uri> _getAndroidNdkPath() async {
    // TODO find alternative for non flutter builds
    final flutterConfig =
        await execStream('flutter', const [
              'config',
              '--machine',
            ], runInShell: OS.current == .windows)
            .transform(utf8.decoder)
            .transform(json.decoder)
            .cast<Map<String, dynamic>>()
            .single;
    final androidSdk = flutterConfig['android-sdk'] as String?;
    if (androidSdk == null) {
      throw Exception('Android SDK path not found in flutter config');
    }
    logger.debug('Detected android SDK path from flutter config: $androidSdk');

    final sdkUri = Uri.directory(androidSdk);
    final ndkCandidates = await Directory.fromUri(sdkUri.resolve('ndk/'))
        .list(followLinks: false)
        .where((e) => e is Directory)
        .cast<Directory>()
        .map((d) => d.absolute.uri)
        .toList();
    logger.debug('Found ${ndkCandidates.length} NDK candidates:');
    for (final candidate in ndkCandidates) {
      logger.debug('  > ${candidate.toFilePath()}');
    }

    final bestCandidate = (ndkCandidates..sort(_compareFileName)).lastOrNull;
    if (bestCandidate == null) {
      throw Exception('No Android NDK found in $androidSdk/ndk/');
    }

    return bestCandidate;
  }

  int _compareFileName(Uri a, Uri b) =>
      a.pathSegments.last.compareTo(b.pathSegments.last);
}
