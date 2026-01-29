import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:crypto/crypto.dart';
import 'package:hooks/hooks.dart';
import 'package:meta/meta.dart';

import 'linux_builder.dart';
import 'macos_builder.dart';

abstract base class SodiumBuilder {
  @protected
  final CodeConfig config;

  const SodiumBuilder(this.config);

  factory SodiumBuilder.forConfig(CodeConfig config) =>
      switch (config.targetOS) {
        .linux => LinuxBuilder(config),
        .macOS => MacosBuilder(config),
        _ => throw UnsupportedError('Unsupported OS: ${config.targetOS}'),
      };

  @protected
  bool get isStaticLinking => switch (config.linkModePreference) {
    .static || .preferStatic => true,
    .dynamic || .preferDynamic => false,
    _ => false,
  };

  Future<CodeAsset> build({
    required BuildInput input,
    required Directory sourceDir,
  }) async {
    final hashValue = await configHash
        .map((v) => v.toString())
        .transform(utf8.encoder)
        .transform(sha256)
        .map((h) => h.toString().substring(0, 10))
        .single;

    final configUri = input.outputDirectoryShared.resolve('$hashValue/');
    final srcDirUri = configUri.resolve('s/');
    final installDirUri = configUri.resolve('i/');

    try {
      final env = await environment;
      final configSrcDir = await _recursiveCopy(sourceDir, srcDirUri);
      await _configure(configSrcDir, installDirUri, env);
      await _make(configSrcDir, env);
      return await _createAsset(installDirUri);
    } catch (e) {
      final configDir = Directory.fromUri(configUri);
      if (configDir.existsSync()) {
        await configDir.delete(recursive: true);
      }
      rethrow;
    }
  }

  @protected
  @mustCallSuper
  Stream<Object> get configHash => Stream.fromIterable([
    config.targetOS,
    config.targetArchitecture,
    config.linkModePreference,
    ?config.cCompiler?.compiler,
    ?config.cCompiler?.archiver,
    ?config.cCompiler?.linker,
  ]);

  @protected
  @mustCallSuper
  FutureOr<Map<String, String>> get environment => {
    if (config.cCompiler case final cc?) ...{
      'CC': cc.compiler.toFilePath(),
      'AR': cc.archiver.toFilePath(),
      'LD': cc.linker.toFilePath(),
    },
  };

  @protected
  @mustCallSuper
  FutureOr<List<String>> get configureArgs => isStaticLinking
      ? const ['--enable-shared=no', '--enable-static=yes']
      : const ['--enable-shared=yes', '--enable-static=no'];

  @protected
  @nonVirtual
  Future<int> exec(
    String executable,
    List<String> arguments, {
    Directory? workingDirectory,
    Map<String, String>? environment,
    int? expectExitCode = 0,
  }) async {
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory?.path,
      environment: environment,
      mode: .inheritStdio,
    );

    final exitCode = await process.exitCode;
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
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory?.path,
      environment: environment,
    );

    process.stderr.listen(stderr.add);

    yield* process.stdout;

    final exitCode = await process.exitCode;
    if (expectExitCode != null && exitCode != expectExitCode) {
      throw Exception(
        'Process $executable exited with code $exitCode, '
        'expected $expectExitCode.',
      );
    }
  }

  Future<void> _configure(
    Directory sourceDir,
    Uri installDirUri,
    Map<String, String> env,
  ) async {
    await exec(
      './configure',
      [...await configureArgs, '--prefix=${installDirUri.toFilePath()}'],
      workingDirectory: sourceDir,
      environment: env,
    );
  }

  Future<void> _make(Directory sourceDir, Map<String, String> env) async =>
      await exec(
        'make',
        ['-j${Platform.numberOfProcessors}', 'install'],
        workingDirectory: sourceDir,
        environment: env,
      );

  Future<CodeAsset> _createAsset(Uri installDir) async {
    final linkMode = isStaticLinking
        ? StaticLinking()
        : DynamicLoadingBundled();
    final libName = config.targetOS.libraryFileName('sodium', linkMode);
    final libFile = File(installDir.resolve('lib/$libName').toFilePath());
    final resolvedUri = Uri.file(await libFile.resolveSymbolicLinks());

    return CodeAsset(
      package: 'sodium',
      name: 'libsodium',
      linkMode: linkMode,
      file: resolvedUri,
    );
  }

  Future<Directory> _recursiveCopy(Directory source, Uri destinationUri) async {
    final destination = await Directory.fromUri(
      destinationUri,
    ).create(recursive: true);
    await for (final entity in source.list(followLinks: false)) {
      final name = entity.uri.path.endsWith('/')
          ? entity.uri.pathSegments.reversed.skip(1).first
          : entity.uri.pathSegments.last;
      final newUri = destination.uri.resolve(name);
      switch (entity) {
        case File():
          await entity.copy(newUri.toFilePath());
        case Directory():
          await _recursiveCopy(entity, newUri);
        default:
          throw UnsupportedError(
            'Cannot copy entity of type ${entity.runtimeType}: ${entity.uri}',
          );
      }
    }
    return destination;
  }
}
