import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:meta/meta.dart';

import '../common/extensions.dart';
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
  late final AndroidArchConfig _archConfig;

  AndroidBuilder(super.config, super.logger);

  @override
  Future<void> prepare() async {
    Uri toolchainDir;

    if (config.cCompiler?.compiler case final compiler?) {
      logger.debug('Detecting toolchain from compiler: $compiler');
      toolchainDir = compiler.replace(
        pathSegments: compiler.pathSegments
            .take(compiler.pathSegments.length - 2)
            .followedBy(const ['']),
      );
    } else {
      logger.warning(
        'Build hooks did not configure an Android NDK toolchain. This can '
        'happen if the ANDROID_NDK_HOME environment variable is not set up '
        'correctly. Attempting to detect NDK via flutter tool.',
      );
      final ndkPath = await _findAndroidNdkPath();
      logger.debug('Detected Android NDK path: $ndkPath');
      toolchainDir = ndkPath.resolve(
        'toolchains/llvm/prebuilt/${_mapHostPlatform()}-x86_64/',
      );
    }

    logger.info('Detected Android toolchain: $toolchainDir');
    _archConfig = _mapArchConfig(toolchainDir);
  }

  @override
  Iterable<Object?> get configHash sync* {
    yield* super.configHash;
    yield config.android.targetNdkApi;
    yield _archConfig._hashValues;
  }

  @override
  Map<String, String> get environment {
    final compiler =
        config.cCompiler?.compiler ??
        _archConfig.toolchainDir.resolve('bin/clang');
    final archiver =
        config.cCompiler?.archiver ??
        _archConfig.toolchainDir.resolve('bin/llvm-ar');
    final linker =
        config.cCompiler?.linker ?? _archConfig.toolchainDir.resolve('bin/ld');
    final ranlib = _archConfig.toolchainDir.resolve('bin/llvm-ranlib');
    final strip = _archConfig.toolchainDir.resolve('bin/llvm-strip');
    final names = _archConfig.toolchainDir.resolve('bin/llvm-nm');

    final compilerWithTarget =
        '${compiler.toBashSafePath()} '
        '--target=${_archConfig.host}${config.android.targetNdkApi}';
    return {
      ...super.environment,
      'CC': compilerWithTarget,
      'AS': compilerWithTarget,
      'AR': archiver.toBashSafePath(),
      'LD': linker.toBashSafePath(),
      'RANLIB': ranlib.toBashSafePath(),
      'STRIP': strip.toBashSafePath(),
      'NM': names.toBashSafePath(),

      'CFLAGS': _archConfig.cFlags.join(' '),
      'LDFLAGS': _archConfig.ldFlags.join(' '),
      'PATH': [
        _archConfig.toolchainDir.resolve('bin').toFilePath(),
        ?Platform.environment['PATH'],
      ].join(OS.current == .windows ? ';' : ':'),
    };
  }

  @override
  Iterable<String> get configureArgs sync* {
    yield* super.configureArgs;
    yield '--host=${_archConfig.host}';
    // ignore: lines_longer_than_80_chars not avoidable
    yield '--with-sysroot=${_archConfig.toolchainDir.resolve("sysroot").toBashSafePath()}';
  }

  AndroidArchConfig _mapArchConfig(Uri toolchainDir) => AndroidArchConfig(
    host: _mapHost(config.targetArchitecture),
    cFlags: [
      '-Os',
      ..._mapExtraCFlags(config.targetArchitecture),
      '-march=${_mapTargetArch(config.targetArchitecture)}',
    ],
    ldFlags: const ['-Wl,-z,max-page-size=16384'],
    toolchainDir: toolchainDir,
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

  Future<Uri> _findAndroidNdkPath() async {
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
      logger.debug('  > $candidate');
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
