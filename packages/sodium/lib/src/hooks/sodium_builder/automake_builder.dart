import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import '../common/extensions.dart';
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

    Uri? windowsBash;
    if (OS.current == .windows) {
      logger.debug('Detecting bash...');
      windowsBash = await _findWindowsBash();
    }

    logger.debug('Configuring...');
    final env = environment;
    await _configure(sourceDir, installDir, env, windowsBash);

    logger.debug('Building...');
    await _make(sourceDir, env, windowsBash);

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
        ..debug('Detected custom compiler: ${cc.compiler}')
        ..debug('Detected custom archiver: ${cc.archiver}')
        ..debug('Detected custom linker: ${cc.linker}');
      return {
        'CC': cc.compiler.toBashSafePath(),
        'AR': cc.archiver.toBashSafePath(),
        'LD': cc.linker.toBashSafePath(),
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
    Uri? windowsBash,
  ) async {
    var buildCommand = './configure';
    var buildArguments = [
      ...configureArgs,
      '--prefix=${installDirUri.toBashSafePath()}',
    ];

    if (windowsBash != null) {
      buildArguments = [buildCommand, ...buildArguments];
      buildCommand = windowsBash.toFilePath();
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

  Future<void> _make(
    Directory sourceDir,
    Map<String, String> env,
    Uri? windowsBash,
  ) async {
    var buildCommand = 'make';
    var buildArguments = ['-j${Platform.numberOfProcessors}', 'install'];

    if (windowsBash != null) {
      logger.warning(Platform.environment.toString());

      buildArguments = [
        '-lc',
        [
          buildCommand,
          ...buildArguments,
          'V=1',
          'AM_V_GEN=',
          'AM_V_at=',
          'SHELL=${windowsBash.pathSegments.last}',
          'CONFIG_SHELL=${windowsBash.pathSegments.last}',
          'MAKESHELL=${windowsBash.pathSegments.last}',
        ].join(' '),
      ];
      buildCommand = windowsBash.toFilePath();
    }

    await exec(
      buildCommand,
      buildArguments,
      workingDirectory: sourceDir,
      environment: env,
    );
  }

  Future<Uri> _findWindowsBash() async {
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

    logger.debug("Found bash candidates: ${candidates.join(', ')}");

    for (final candidate in candidates) {
      final lower = candidate.toLowerCase();

      if (path.basename(lower) != 'bash.exe') continue;

      // Skip WSL launcher
      if (path.equals(lower, r'c:\windows\system32\bash.exe')) continue;

      // Skip Windows app execution aliases
      final parts = path.split(lower);
      if (parts.contains('windowsapps')) continue;

      return Uri.file(candidate);
    }

    throw Exception(
      'No usable bash.exe found on Windows. Install Git for Windows '
      '(preferred), MSYS2, or Cygwin. Found only unsupported bash launchers '
      'such as WSL or Windows App aliases.',
    );
  }
}
