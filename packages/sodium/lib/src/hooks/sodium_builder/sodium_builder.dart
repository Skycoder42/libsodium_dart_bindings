import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:crypto/crypto.dart';
import 'package:hooks/hooks.dart';
import 'package:meta/meta.dart';

import '../common/extractor.dart';
import '../common/hook_logger.dart';
import 'android_builder.dart';
import 'ios_builder.dart';
import 'linux_builder.dart';
import 'macos_builder.dart';
import 'windows_builder.dart';

@internal
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
    required Uri sourceArchive,
    Uri? exportHeadersTo,
  }) async {
    logger.debug('Running prepare step...');
    await prepare();
    logger.debug('Prepare step completed!');

    final shortHash = _calculateHash();
    final configUri = input.outputDirectoryShared.resolve('$shortHash/');
    final srcDirUri = configUri.resolve('libsodium-stable/');
    logger
      ..debug('Calculated config hash: $shortHash')
      ..debug('Source directory URI: $srcDirUri');

    try {
      final srcDir = Directory.fromUri(srcDirUri);
      if (srcDir.existsSync()) {
        logger.debug('Source directory already exists, skipping extraction.');
      } else {
        logger.info('Extracting source files to config-specific directory...');
        await Extractor.extractToDisk(sourceArchive, configUri);
        logger.debug('Source files extracted successfully!');
      }

      logger.info('Starting build process...');
      final installDir = await buildCached(input: input, sourceDir: srcDir);
      logger.debug('Successfully built libsodium to: $installDir');

      if (exportHeadersTo != null) {
        logger.info('Exporting sodium headers install location');
        await File.fromUri(
          input.packageRoot.resolveUri(exportHeadersTo),
        ).writeAsString(getIncludesPath(srcDirUri, installDir).toString());
      }

      return createCodeAsset(installDir);
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
  Future<Uri> buildCached({
    required BuildInput input,
    required Directory sourceDir,
  });

  @protected
  @mustCallSuper
  Iterable<Object?> get configHash => [
    config.targetOS,
    config.targetArchitecture,
    isStaticLinking,
  ];

  @protected
  Uri getIncludesPath(Uri sourceDir, Uri installDir) =>
      installDir.resolve('include/');

  @protected
  CodeAsset createCodeAsset(Uri installUri, {bool isFullPath = false}) {
    final linkMode = isStaticLinking
        ? StaticLinking()
        : DynamicLoadingBundled();
    return CodeAsset(
      package: 'sodium',
      name: 'libsodium',
      linkMode: linkMode,
      file: isFullPath
          ? installUri
          : installUri.resolveUri(
              Uri(
                pathSegments: [
                  'lib',
                  config.targetOS.libraryFileName('sodium', linkMode),
                ],
              ),
            ),
    );
  }

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
    _logExec('Executing', executable, arguments, environment);

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
    bool runInShell = false,
    int? expectExitCode = 0,
  }) async* {
    _logExec('Streaming', executable, arguments, environment);

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

  void _logExec(
    String operation,
    String executable,
    List<String> arguments,
    Map<String, String>? environment,
  ) {
    logger.debug("$operation command: $executable ${arguments.join(' ')}");
    if (environment != null) {
      logger.debug('With environment:');
      for (final MapEntry(:key, :value) in environment.entries) {
        logger.debug('$key: $value');
      }
    }
  }
}
