import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:code_assets/code_assets.dart';
import 'package:crypto/crypto.dart';
import 'package:hooks/hooks.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:posix/posix.dart' as posix;

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
    required Uri sourceArchive,
  }) async {
    logger.debug('Running prepare step...');
    await prepare();
    logger.debug('Prepare step completed!');

    final shortHash = _calculateHash();
    final configUri = input.outputDirectoryShared.resolve('$shortHash/');
    final srcDirUri = configUri.resolve('libsodium-stable/');
    final installDirUri = configUri.resolve('install/');
    logger
      ..debug('Calculated config hash: $shortHash')
      ..debug('Source directory URI: $srcDirUri')
      ..debug('Install directory URI: $installDirUri');

    try {
      final srcDir = Directory.fromUri(srcDirUri);
      if (srcDir.existsSync()) {
        logger.debug('Source directory already exists, skipping extraction.');
      } else {
        logger.info('Extracting source files to config-specific directory...');
        await _extract(sourceArchive, configUri);
        logger.debug('Source files extracted successfully!');
      }

      logger.info('Starting build process...');
      final asset = await buildCached(
        input: input,
        sourceDir: srcDir,
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

  Future<void> _extract(Uri sourceArchive, Uri destinationDir) async {
    final tarGzInStream = InputFileStream(sourceArchive.toFilePath());
    final tarOutStream = OutputMemoryStream();
    Archive? archive;
    try {
      final ok = const GZipDecoder().decodeStream(
        tarGzInStream,
        tarOutStream,
        verify: true,
      );
      if (!ok) {
        throw Exception(
          'Failed to decode gzip stream from archive: $sourceArchive',
        );
      }

      archive = TarDecoder().decodeBytes(tarOutStream.getBytes(), verify: true);
      await _extractToDisk(archive, destinationDir);
    } finally {
      await archive?.clear();
      await tarOutStream.close();
      await tarGzInStream.close();
    }
  }

  Future<void> _extractToDisk(Archive archive, Uri destinationDir) async {
    final outDir = Directory.fromUri(destinationDir);
    if (!outDir.existsSync()) {
      await outDir.create(recursive: true);
    }

    for (final entry in archive) {
      final filePath = path.normalize(path.join(outDir.path, entry.name));

      if (!_isWithinOutputPath(outDir.path, filePath)) {
        throw Exception(
          'The libsodium archive contains an entry with a path that is outside '
          'the output directory: "${entry.name}". Extraction has been aborted '
          'for security reasons.',
        );
      }

      if (entry.isSymbolicLink) {
        throw Exception(
          'The libsodium archive should not contain symbolic links, but found '
          'one pointing to "${entry.symbolicLink}" in file "${entry.name}". '
          'Extraction has been aborted for security reasons.',
        );
      }

      if (entry.isDirectory) {
        await Directory(filePath).create(recursive: true);
        continue;
      }

      if (!entry.isFile) {
        throw Exception(
          'The libsodium archive contains an entry that is not a file, '
          'directory, or symbolic link: "${entry.name}". Extraction has been '
          'aborted for security reasons.',
        );
      }

      final output = OutputFileStream(filePath);
      try {
        entry.writeContent(output);
        output.flush();
        await output.close();

        if (posix.isPosixSupported) {
          posix.chmodWithMode(filePath, entry.mode);
          entry.unixPermissions;
        }

        logger.debug(
          'Extracted: ${path.relative(filePath, from: outDir.path)}',
        );
      } finally {
        if (output.isOpen) {
          await output.close();
        }
      }
    }
  }

  bool _isWithinOutputPath(String outputDir, String filePath) =>
      path.isWithin(path.canonicalize(outputDir), path.canonicalize(filePath));
}
