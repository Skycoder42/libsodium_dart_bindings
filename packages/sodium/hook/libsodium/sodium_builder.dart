import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:crypto/crypto.dart';
import 'package:hooks/hooks.dart';
import 'package:meta/meta.dart';

import 'android_builder.dart';
import 'ios_builder.dart';
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
        .android => AndroidBuilder(config),
        .iOS => IosBuilder(config),
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
      final configSrcDir = await _recursiveCopy(sourceDir, srcDirUri);
      return await buildCached(
        input: input,
        sourceDir: configSrcDir,
        installDir: installDirUri,
      );
    } catch (e) {
      final configDir = Directory.fromUri(configUri);
      if (configDir.existsSync()) {
        await configDir.delete(recursive: true);
      }
      rethrow;
    }
  }

  @visibleForOverriding
  Future<CodeAsset> buildCached({
    required BuildInput input,
    required Directory sourceDir,
    required Uri installDir,
  });

  @protected
  @mustCallSuper
  Stream<Object> get configHash => Stream.fromIterable([
    config.targetOS,
    config.targetArchitecture,
    config.linkModePreference,
  ]);

  @protected
  @nonVirtual
  CodeAsset createCodeAsset(Uri installDir, [LinkMode? linkMode]) {
    final actualLinkMode =
        linkMode ??
        (isStaticLinking ? StaticLinking() : DynamicLoadingBundled());
    final libName = config.targetOS.libraryFileName('sodium', actualLinkMode);
    return CodeAsset(
      package: 'sodium',
      name: 'libsodium',
      linkMode: actualLinkMode,
      file: installDir.resolve(libName),
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
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory?.path,
      environment: environment,
      runInShell: runInShell,
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
