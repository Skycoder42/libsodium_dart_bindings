import 'dart:async';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:meta/meta.dart';

import 'sodium_builder.dart';

abstract base class AutomakeBuilder extends SodiumBuilder {
  const AutomakeBuilder(super.config);

  @override
  @nonVirtual
  @protected
  Future<CodeAsset> buildCached({
    required BuildInput input,
    required Directory sourceDir,
    required Uri installDir,
  }) async {
    final env = environment;
    await _configure(sourceDir, installDir, env);
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
  Map<String, String> get environment => {
    if (config.cCompiler case final cc?) ...{
      'CC': cc.compiler.toFilePath(),
      'AR': cc.archiver.toFilePath(),
      'LD': cc.linker.toFilePath(),
    },
  };

  @protected
  @mustCallSuper
  Iterable<String> get configureArgs => [
    '--disable-soname-versions',
    if (isStaticLinking) '--enable-static=yes' else '--enable-static=no',
    if (!isStaticLinking) '--enable-shared=yes' else '--enable-shared=no',
  ];

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
