import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:crypto/crypto.dart';
import 'package:hooks/hooks.dart';
import 'package:meta/meta.dart';

import '../common/hook_logger.dart';
import 'android_builder.dart';
import 'ios_builder.dart';
import 'linux_builder.dart';
import 'macos_builder.dart';
import 'windows_builder.dart';

abstract base class SodiumBuilder {
  @protected
  final CodeConfig config;
  @protected
  final HookLogger logger;

  SodiumBuilder(this.config, this.logger);

  factory SodiumBuilder.forConfig(CodeConfig config, HookLogger logger) =>
      switch (config.targetOS) {
        .android => AndroidBuilder(config, logger),
        .iOS => IosBuilder(config, logger),
        .linux => LinuxBuilder(config, logger),
        .macOS => MacosBuilder(config, logger),
        .windows => WindowsBuilder(config, logger),
        _ => throw UnsupportedError('Unsupported OS: ${config.targetOS}'),
      };

  @protected
  bool get isStaticLinking => switch (config.linkModePreference) {
    .static || .preferStatic => true,
    .dynamic || .preferDynamic => false,
    _ => false,
  };

  @nonVirtual
  Future<CodeAsset> build({
    required BuildInput input,
    required Directory sourceDir,
  }) async {
    logger.debug('Running prepare step...');
    await prepare();
    logger.debug('Prepare step completed!');

    final shortHash = _calculateHash();
    final configUri = input.outputDirectoryShared.resolve('$shortHash/');
    final srcDirUri = configUri.resolve('s/');
    final installDirUri = configUri.resolve('i/');
    logger
      ..debug('Calculated config hash: $shortHash')
      ..debug('Source directory URI: $srcDirUri')
      ..debug('Install directory URI: $installDirUri');

    try {
      final configSrcDir = Directory.fromUri(srcDirUri);
      if (configSrcDir.existsSync()) {
        logger.debug('Source directory already exists, skipping copy.');
      } else {
        logger.info('Copying source files to config-specific directory...');
        await _recursiveCopy(sourceDir, configSrcDir);
        logger.debug('Source files copied successfully!');
      }

      logger.info('Starting build process...');
      final asset = await buildCached(
        input: input,
        sourceDir: configSrcDir,
        installDir: installDirUri,
      );
      logger.debug('Successfully built code asset: ${asset.id}');
      return asset;
    } catch (e) {
      final configDir = Directory.fromUri(configUri);
      if (configDir.existsSync()) {
        logger.debug('Build failed, cleaning up config directory...');
        await configDir.delete(recursive: true);
      }
      rethrow;
    }
  }

  String _calculateHash() {
    late final Digest digest;
    final sink = utf8.encoder
        .fuse(sha256)
        .startChunkedConversion(
          ChunkedConversionSink.withCallback(
            (chunks) => digest = chunks.single,
          ),
        );

    try {
      configHash.map((v) => v.toString()).forEach(sink.add);
    } finally {
      sink.close();
    }

    return digest.toString().substring(0, 10);
  }

  @visibleForOverriding
  Future<void> prepare() => Future.value();

  @visibleForOverriding
  Future<CodeAsset> buildCached({
    required BuildInput input,
    required Directory sourceDir,
    required Uri installDir,
  });

  @protected
  @mustCallSuper
  Iterable<Object?> get configHash => [
    config.targetOS,
    config.targetArchitecture,
    isStaticLinking,
  ];

  @protected
  @nonVirtual
  CodeAsset createCodeAsset(Uri installDir, {bool isFullPath = false}) =>
      CodeAsset(
        package: 'sodium',
        name: 'libsodium',
        linkMode: isStaticLinking ? StaticLinking() : DynamicLoadingBundled(),
        file: isFullPath
            ? installDir
            : installDir.resolve(
                config.targetOS.libraryFileName(
                  'sodium',
                  (isStaticLinking ? StaticLinking() : DynamicLoadingBundled()),
                ),
              ),
      );

  @protected
  @nonVirtual
  Future<int> exec(
    String executable,
    List<String> arguments, {
    Directory? workingDirectory,
    Map<String, String>? environment,
    bool runInShell = false,
    int? expectExitCode = 0,
  }) async {
    logger.debug("Executing command: $executable ${arguments.join(' ')}");
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory?.path,
      environment: environment,
      runInShell: runInShell,
    );

    process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(logger.warning);
    process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(logger.debug);

    final exitCode = await process.exitCode;
    logger.debug('Command exited with code: $exitCode');
    if (expectExitCode != null && exitCode != expectExitCode) {
      throw Exception('$executable failed with exit code $exitCode.');
    }

    return exitCode;
  }

  @protected
  @nonVirtual
  Stream<List<int>> execStream(
    String executable,
    List<String> arguments, {
    Directory? workingDirectory,
    Map<String, String>? environment,
    int? expectExitCode = 0,
  }) async* {
    logger.debug("Streaming command: $executable ${arguments.join(' ')}");
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory?.path,
      environment: environment,
    );

    process.stderr
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen(logger.warning);

    yield* process.stdout;

    final exitCode = await process.exitCode;
    logger.debug('Command exited with code: $exitCode');
    if (expectExitCode != null && exitCode != expectExitCode) {
      throw Exception(
        'Process $executable exited with code $exitCode, '
        'expected $expectExitCode.',
      );
    }
  }

  Future<void> _recursiveCopy(Directory source, Directory destination) async {
    await destination.create(recursive: true);
    await for (final entity in source.list(followLinks: false)) {
      final name = entity.uri.path.endsWith('/')
          ? entity.uri.pathSegments.reversed.skip(1).first
          : entity.uri.pathSegments.last;
      final newUri = destination.uri.resolve(name);
      switch (entity) {
        case File():
          await entity.copy(newUri.toFilePath());
        case Directory():
          await _recursiveCopy(entity, Directory.fromUri(newUri));
        default:
          logger.warning(
            'Cannot copy entity of type ${entity.runtimeType}: ${entity.uri}',
          );
      }
    }
  }
}
