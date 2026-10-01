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
// ignore: public_member_api_docs false positive
abstract base class AutomakeBuilder(super.config, super.logger)
    extends SodiumBuilder {
  @override
  bool get allowSpaceInPath => false;

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
    // On a macOS build host, libtool's max-command-length probe in libsodium's
    // configure runs `/usr/sbin/sysctl -n kern.argmax` by absolute path. Inside
    // a sandbox (macOS Seatbelt, e.g. an AI coding agent's or a CI sandbox) that
    // sysctl is denied, the value comes back empty, `expr` fails and libtool
    // splits every link, which breaks the darwin link with
    // "ld: -pie can only be used when linking a main executable".
    // configure accepts a preset `lt_cv_sys_max_cmd_len` as a cached answer and
    // skips the probe. The value must exceed the link command's length (a small
    // one breaks the build the same way); 786432 is libtool's own darwin formula
    // (kern.argmax / 4 * 3) for the default kern.argmax of 1048576, i.e. what an
    // unsandboxed configure computes. Gated on the build HOST, not the target:
    // the probe is keyed on `$build_os`, and every other host keeps its
    // environment unchanged.
    final libtoolPreset = Platform.isMacOS
        ? const {'lt_cv_sys_max_cmd_len': '786432'}
        : const <String, String>{};
    if (config.cCompiler case final cc?) {
      logger
        ..debug('Detected custom compiler: ${cc.compiler}')
        ..debug('Detected custom archiver: ${cc.archiver}')
        ..debug('Detected custom linker: ${cc.linker}');
      return {
        ...libtoolPreset,
        'CC': cc.compiler.toBashSafePath(),
        'AR': cc.archiver.toBashSafePath(),
        'LD': cc.linker.toBashSafePath(),
      };
    } else {
      return libtoolPreset;
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
      buildArguments = [
        '-c',
        [
          buildCommand,
          ...buildArguments,
          // overwrite the default "$(SHELL) ..." invocation as it will break
          // on windows. Leaving out "$(SHELL)" still works, as a SHELL is
          // set by automake.
          r"LIBTOOL='$(top_builddir)/libtool'",
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
