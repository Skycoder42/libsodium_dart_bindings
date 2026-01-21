import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:crypto/crypto.dart';
import 'package:hooks/hooks.dart';
import 'package:meta/meta.dart';

abstract class BuildCommon {
  Future<Uri> build({
    required BuildInput input,
    required Directory sourceDir,
  }) async {
    final configHash = utf8.encoder
        .fuse(sha256)
        .convert(hashValues(input.config.code).join('|'))
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
  List<Object> hashValues(CodeConfig config) => [
    config.targetArchitecture,
    config.linkModePreference,
    ?config.cCompiler?.compiler,
    ?config.cCompiler?.archiver,
    ?config.cCompiler?.linker,
  ];

  @protected
  @mustCallSuper
  Map<String, String> createEnvironment(CodeConfig config) => {
    if (config.cCompiler case final cc?) ...{
      'CC': cc.compiler.toFilePath(),
      'AR': cc.archiver.toFilePath(),
      'LD': cc.linker.toFilePath(),
    },
  };

  @protected
  @mustCallSuper
  List<String> createConfigureArguments(CodeConfig config) {
    final linkStatic = switch (config.linkModePreference) {
      .static || .preferStatic => true,
      .dynamic || .preferDynamic => false,
      _ => false,
    };

    return linkStatic
        ? const ['--enable-shared=no', '--enable-static=yes']
        : const ['--enable-shared=yes', '--enable-static=no'];
  }

  Future<void> _configure(
    CodeConfig config,
    Directory sourceDir,
    Uri installDirUri,
  ) async {
    final result = await _exec(
      './configure',
      [
        ...createConfigureArguments(config),
        '--prefix=${installDirUri.toFilePath()}',
      ],
      workingDirectory: sourceDir,
      environment: createEnvironment(config),
    );

    if (result != 0) {
      throw Exception('Configure failed with exit code: $result');
    }
  }

  Future<void> _make(CodeConfig config, Directory sourceDir) async {
    final result = await _exec(
      'make',
      ['-j${Platform.numberOfProcessors}', 'install'],
      workingDirectory: sourceDir,
      environment: createEnvironment(config),
    );

    if (result != 0) {
      throw Exception('Make failed with exit code: $result');
    }
  }

  Future<int> _exec(
    String executable,
    List<String> arguments, {
    Directory? workingDirectory,
    Map<String, String>? environment,
  }) async {
    final process = await Process.start(
      executable,
      arguments,
      workingDirectory: workingDirectory?.path,
      environment: environment,
      mode: ProcessStartMode.inheritStdio,
    );
    return await process.exitCode;
  }

  Future<Directory> _recursiveCopy(Directory source, Uri destinationUri) async {
    final destination = await Directory.fromUri(
      destinationUri,
    ).create(recursive: true);
    await for (final entity in source.list(followLinks: false)) {
      final newUri = destination.uri.resolve(entity.uri.pathSegments.last);
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
