import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import 'sodium_builder.dart';

@internal
abstract base class AutomakeBuilder extends SodiumBuilder {
  AutomakeBuilder(super.config, super.logger);

  @override
  @nonVirtual
  @protected
  Future<Uri> buildCached({
    required BuildInput input,
    required Directory sourceDir,
  }) async {
    final installDir = sourceDir.uri.resolve('install/');

    logger.debug('Configuring...');
    final env = environment;
    await _configure(sourceDir, installDir, env);

    logger.debug('Building...');
    await _make(sourceDir, env);

    return installDir;
  }

  @override
  @protected
  @mustCallSuper
  Iterable<Object?> get configHash sync* {
    yield* super.configHash;
    if (config.cCompiler case final cc?) {
      yield cc.compiler;
      yield cc.archiver;
      yield cc.linker;
    }
  }

  @protected
  @mustCallSuper
  Map<String, String> get environment {
    if (config.cCompiler case final cc?) {
      logger
        ..debug('Detected custom compiler: ${cc.compiler.toFilePath()}')
        ..debug('Detected custom archiver: ${cc.archiver.toFilePath()}')
        ..debug('Detected custom linker: ${cc.linker.toFilePath()}');
      return {
        'CC': cc.compiler.toFilePath(),
        'AR': cc.archiver.toFilePath(),
        'LD': cc.linker.toFilePath(),
      };
    } else {
      return const {};
    }
  }

  @protected
  @mustCallSuper
  Iterable<String> get configureArgs sync* {
    yield '--disable-soname-versions';
    if (isStaticLinking) {
      logger.debug('Configuring for static linking');
      yield '--enable-static=yes';
      yield '--enable-shared=no';
    } else {
      logger.debug('Configuring for dynamic linking');
      yield '--enable-static=no';
      yield '--enable-shared=yes';
    }
  }

  Future<void> _configure(
    Directory sourceDir,
    Uri installDirUri,
    Map<String, String> env,
  ) async {
    var buildCommand = './configure';
    var buildArguments = [
      ...configureArgs,
      '--prefix=${installDirUri.toFilePath()}',
    ];

    if (OS.current == .windows) {
      buildArguments = [buildCommand, ...buildArguments];
      buildCommand = await _findWindowsBash();
    }

    try {
      await exec(
        buildCommand,
        buildArguments,
        workingDirectory: sourceDir,
        environment: env,
      );
    } catch (_) {
      final configLogFile = File.fromUri(sourceDir.uri.resolve('config.log'));
      if (configLogFile.existsSync()) {
        logger.warning('##### config.log #####');
        await configLogFile.openRead().pipe(stderr);
        logger.warning('##### config.log #####');
      }
      rethrow;
    }
  }

  Future<void> _make(Directory sourceDir, Map<String, String> env) async =>
      await exec(
        'make',
        ['-j${Platform.numberOfProcessors}', 'install'],
        workingDirectory: sourceDir,
        environment: env,
      );

  Future<String> _findWindowsBash() async {
    final candidates =
        await execStream(
              'where',
              const ['bash'],
              runInShell: true,
              expectExitCode: null,
            )
            .transform(utf8.decoder)
            .transform(const LineSplitter())
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .map(path.normalize)
            .toList();

    for (final candidate in candidates) {
      final lower = candidate.toLowerCase();

      if (path.basename(lower) != 'bash.exe') continue;

      // Skip WSL launcher
      if (path.equals(lower, r'c:\windows\system32\bash.exe')) continue;

      // Skip Windows app execution aliases
      final parts = path.split(lower);
      if (parts.contains('windowsapps')) continue;

      return candidate;
    }

    throw Exception(
      'No usable bash.exe found on Windows. Install Git for Windows '
      '(preferred), MSYS2, or Cygwin. Found only unsupported bash launchers '
      'such as WSL or Windows App aliases.',
    );
  }
}
