import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:crypto/crypto.dart';
import 'package:hooks/hooks.dart';
import 'package:meta/meta.dart';

import 'build_macos.dart';

abstract base class BuildCommon {
  BuildCommon();

  factory BuildCommon.forOs(OS os) => switch (os) {
    .macOS => BuildMacos(),
    _ => throw UnsupportedError('Unsupported OS: $os'),
  };

  Future<Uri> build({
    required BuildInput input,
    required Directory sourceDir,
  }) async {
    final configHash = utf8.encoder
        .fuse(sha256)
        .convert((await hashValues(input.config.code)).join('|'))
        .toString()
        .substring(0, 10);

    final configUri = input.outputDirectoryShared.resolve('build/$configHash/');
    final srcDirUri = configUri.resolve('src/');
    final installDirUri = configUri.resolve('install/');

    try {
      final configSrcDir = await _recursiveCopy(sourceDir, srcDirUri);
      await _configure(input.config.code, configSrcDir, installDirUri);
      await _make(input.config.code, configSrcDir);
    } catch (e) {
      final configDir = Directory.fromUri(configUri);
      if (configDir.existsSync()) {
        await configDir.delete(recursive: true);
      }
      rethrow;
    }

    return installDirUri;
  }

  @protected
  @mustCallSuper
  FutureOr<List<Object>> hashValues(CodeConfig config) => [
    config.targetArchitecture,
    config.linkModePreference,
    ?config.cCompiler?.compiler,
    ?config.cCompiler?.archiver,
    ?config.cCompiler?.linker,
  ];

  @protected
  @mustCallSuper
  FutureOr<Map<String, String>> createEnvironment(CodeConfig config) => {
    if (config.cCompiler case final cc?) ...{
      'CC': cc.compiler.toFilePath(),
      'AR': cc.archiver.toFilePath(),
      'LD': cc.linker.toFilePath(),
    },
  };

  @protected
  @mustCallSuper
  FutureOr<List<String>> createConfigureArguments(CodeConfig config) {
    final linkStatic = switch (config.linkModePreference) {
      .static || .preferStatic => true,
      .dynamic || .preferDynamic => false,
      _ => false,
    };

    return linkStatic
        ? const ['--enable-shared=no', '--enable-static=yes']
        : const ['--enable-shared=yes', '--enable-static=no'];
  }

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
    CodeConfig config,
    Directory sourceDir,
    Uri installDirUri,
  ) async {
    final environment = await createEnvironment(config);
    await exec(
      './configure',
      [
        ...await createConfigureArguments(config),
        '--prefix=${installDirUri.toFilePath()}',
      ],
      workingDirectory: sourceDir,
      environment: environment,
    );
  }

  Future<void> _make(CodeConfig config, Directory sourceDir) async =>
      await exec(
        'make',
        ['-j${Platform.numberOfProcessors}', 'install'],
        workingDirectory: sourceDir,
        environment: await createEnvironment(config),
      );

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
