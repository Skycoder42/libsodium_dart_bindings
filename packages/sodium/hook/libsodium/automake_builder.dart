import 'dart:async';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:meta/meta.dart';

import 'sodium_builder.dart';

abstract base class AutomakeBuilder extends SodiumBuilder {
  AutomakeBuilder(super.config, super.logger);

  @override
  @nonVirtual
  @protected
  Future<CodeAsset> buildCached({
    required BuildInput input,
    required Directory sourceDir,
    required Uri installDir,
  }) async {
    logger.debug('Configuring...');
    final env = environment;
    await _configure(sourceDir, installDir, env);
    logger.debug('Building...');
    await _make(sourceDir, env);

    return createCodeAsset(installDir.resolve('lib/'));
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
    await exec(
      './configure',
      [...configureArgs, '--prefix=${installDirUri.toFilePath()}'],
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
}
