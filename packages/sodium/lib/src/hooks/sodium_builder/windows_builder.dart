import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import '../constants.dart';
import 'sodium_builder.dart';

/// Windows builder for libsodium.
///
/// PATCHED: works around Windows MAX_PATH (260 char) limitation.
/// The Dart archive extractor (`package:archive`) silently fails to create
/// files whose full path exceeds 260 characters. The hook's extraction
/// directory (`.dart_tool/hooks_runner/shared/sodium/build/HASH/`) is deep
/// enough that some libsodium source files (e.g.
/// `crypto_pwhash/scryptsalsa208sha256/nosse/pwhash_scryptsalsa208sha256_nosse.c`)
/// exceed the limit and are silently skipped, causing msbuild to fail.
///
/// Fix: re-extract the archive to a short temp path using the system `tar`
/// command (which supports long paths on Windows 10+), build there using the
/// original vcvarsall + msbuild approach, then copy the DLL back.
///
/// See: https://github.com/Skycoder42/libsodium_dart_bindings/issues/192
@internal
final class WindowsBuilder extends SodiumBuilder {
  static const _targetOutputFileName = 'target.txt';
  static const _vsVersionDetectionScript = '''
IF "%VSCMD_VER%"=="" (
  SET "__SODIUM_VS_VERSION=%VisualStudioVersion%"
) ELSE (
  SET "__SODIUM_VS_VERSION=%VSCMD_VER%"
)
FOR /f "tokens=1 delims=." %%i IN ("%__SODIUM_VS_VERSION%") DO SET "__SODIUM_VS_VERSION_MAJOR=%%i"
SET "__SODIUM_VS_NAME=vs2026"
IF "%__SODIUM_VS_VERSION_MAJOR%"=="18" SET "__SODIUM_VS_NAME=vs2026"
IF "%__SODIUM_VS_VERSION_MAJOR%"=="17" SET "__SODIUM_VS_NAME=vs2022"
IF "%__SODIUM_VS_VERSION_MAJOR%"=="16" SET "__SODIUM_VS_NAME=vs2019"
IF "%__SODIUM_VS_VERSION_MAJOR%"=="15" SET "__SODIUM_VS_NAME=vs2017"
''';

  late final DeveloperCommandPrompt _commandPrompt;

  WindowsBuilder(super.config, super.logger);

  @override
  Future<void> prepare() async {
    _commandPrompt =
        config.cCompiler?.windows.developerCommandPrompt ??
        await _findVcDevCmd();
    logger
      ..debug(
        'Detected Developer Command Prompt: '
        '${_commandPrompt.script.toFilePath()}',
      )
      ..debug("With arguments: ${_commandPrompt.arguments.join(' ')}");
  }

  @override
  Iterable<Object?> get configHash sync* {
    yield* super.configHash;
    yield _commandPrompt.script;
    yield _commandPrompt.arguments;
  }

  @override
  Future<Uri> buildCached({
    required BuildInput input,
    required Directory sourceDir,
  }) async {
    // --- MAX_PATH workaround: build in a short temp directory ---
    //
    // The parent class extracted the archive to sourceDir, but some files
    // are missing due to MAX_PATH. We re-extract to a short path using
    // the system tar.exe, build there, then copy the result back.

    final systemDrive = Platform.environment['SYSTEMDRIVE'] ?? r'C:';
    final shortBuildDir = Directory('$systemDrive\\tmp\\sodium-build');
    final shortSrcDir = Directory(
      path.join(shortBuildDir.path, 'libsodium-stable'),
    );

    // Re-extract if needed (system tar handles long filenames)
    if (!shortSrcDir.existsSync()) {
      final archivePath = input.packageRoot
          .resolveUri(HookConstants.libsodiumArchive)
          .toFilePath();
      logger.info(
        'Re-extracting to short path to avoid MAX_PATH issues: '
        '${shortBuildDir.path}',
      );
      await shortBuildDir.create(recursive: true);
      await exec('tar', ['xzf', archivePath],
          workingDirectory: shortBuildDir);
    } else {
      logger.info('Short path source already exists, skipping extraction.');
    }

    // Build using the original vcvarsall + msbuild .bat approach,
    // but in the short directory where all source files are present.
    final scriptFile = await _createBuildScript(shortSrcDir);
    logger.info('Building libsodium in short path...');
    await exec('cmd.exe', [
      '/c',
      scriptFile.toFilePath(windows: true),
    ], workingDirectory: shortSrcDir);

    // Find the built DLL (path varies by toolset version)
    final builtDll = await _findFile(shortSrcDir, 'libsodium.dll');
    if (builtDll == null) {
      throw Exception(
        'msbuild succeeded but libsodium.dll not found under '
        '${shortSrcDir.path}',
      );
    }
    logger.info('Found built DLL: ${builtDll.path}');

    // Copy to sourceDir (where the rest of the hook expects it)
    final relativePath = path.relative(builtDll.path, from: shortSrcDir.path);
    final targetDll = File(path.join(sourceDir.path, relativePath));
    await targetDll.parent.create(recursive: true);
    await builtDll.copy(targetDll.path);
    logger.info('Copied DLL to: ${targetDll.path}');

    // Write target.txt for _findInstallUri
    final targetFile = File.fromUri(
      sourceDir.uri.resolve(_targetOutputFileName),
    );
    await targetFile.writeAsString(targetDll.path);

    return await _findInstallUri(sourceDir);
  }

  Future<Uri> _findInstallUri(Directory sourceDir) async {
    final outFile = File.fromUri(sourceDir.uri.resolve(_targetOutputFileName));
    final targetPath = await outFile.readAsString();
    logger.debug('Read target path from build script output: $targetPath');
    return Uri.file(path.canonicalize(targetPath.trim()));
  }

  @override
  Uri getIncludesPath(Uri sourceDir, Uri installDir) =>
      sourceDir.resolve('src/libsodium/include/');

  @override
  CodeAsset createCodeAsset(Uri installUri, {bool isFullPath = false}) =>
      super.createCodeAsset(installUri, isFullPath: true);

  // -- Build script generation (unchanged from original) ----------------------

  Future<Uri> _createBuildScript(Directory sourceDir) async {
    final scriptFile = File.fromUri(sourceDir.uri.resolve('dart-build.bat'));
    if (scriptFile.existsSync()) {
      logger.debug('Build script already exists at: ${scriptFile.path}');
      return scriptFile.uri;
    }

    final scriptFileSink = scriptFile.openWrite();
    try {
      scriptFileSink
        ..writeln('@ECHO ON')
        ..write('CALL "')
        ..write(_commandPrompt.script.toFilePath(windows: true))
        ..write('"');
      for (final arg in _commandPrompt.arguments) {
        scriptFileSink
          ..write(' ')
          ..write(arg);
      }

      scriptFileSink
        ..writeln()
        ..writeln(_vsVersionDetectionScript);

      _writeMsBuildCommonArgs(scriptFileSink);
      scriptFileSink
        ..write(' /v:q /getProperty:TargetPath > ')
        ..writeln(_targetOutputFileName);

      _writeMsBuildCommonArgs(scriptFileSink, withLogging: false);
      scriptFileSink
        ..writeln(' /m /v:n')
        ..writeln('exit /b %errorlevel%');

      await scriptFileSink.flush();
    } finally {
      await scriptFileSink.close();
    }

    logger.debug('Created build script at: ${scriptFile.path}');
    return scriptFile.uri;
  }

  void _writeMsBuildCommonArgs(
    StringSink scriptBuilder, {
    bool withLogging = true,
  }) {
    final platform = _mapPlatform(config.targetArchitecture);

    if (withLogging) {
      logger.debug('Detected platform: $platform');
      if (isStaticLinking) {
        logger.debug('Using static linking');
      } else {
        logger.debug('Using dynamic linking');
      }
    }

    scriptBuilder
      ..write(
        'msbuild "builds/msvc/%__SODIUM_VS_NAME%/libsodium/libsodium.vcxproj"',
      )
      ..write(' /p:Configuration=')
      ..write(isStaticLinking ? 'ReleaseLIB' : 'ReleaseDLL')
      ..write(' /p:Platform=')
      ..write(platform)
      ..write(' /p:RuntimeLibrary=MultiThreadedDLL');
  }

  // -- Helpers ----------------------------------------------------------------

  /// Recursively search for a file by name under a directory.
  Future<File?> _findFile(Directory dir, String fileName) async {
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File && path.basename(entity.path) == fileName) {
        return entity;
      }
    }
    return null;
  }

  String _mapPlatform(Architecture arch) => switch (arch) {
    .arm64 => 'ARM64',
    .x64 => 'x64',
    .ia32 => 'Win32',
    _ => throw UnsupportedError('Unsupported Windows architecture: $arch'),
  };

  Future<DeveloperCommandPrompt> _findVcDevCmd() async {
    await for (final _VsWhereResult(:installationPath) in _vsWhere()) {
      if (!Directory(installationPath).existsSync()) {
        logger.warning(
          'Detected Visual Studio does not exist: $installationPath',
        );
        continue;
      }
      logger.info('Found Visual Studio installation: $installationPath');

      final vsDevCmd = File(
        path.join(installationPath, 'Common7', 'Tools', 'VsDevCmd.bat'),
      );
      if (vsDevCmd.existsSync()) {
        logger.debug('Found VsDevCmd.bat at: ${vsDevCmd.path}');
        final buildArch = _mapVcDevCmdPlatform(config.targetArchitecture);
        final hostArch = _mapVcDevCmdPlatform(Architecture.current);
        logger
          ..debug('Detected build architecture: $buildArch')
          ..debug('Detected host architecture: $hostArch');
        DeveloperCommandPrompt(
          script: vsDevCmd.uri,
          arguments: ['-arch=$buildArch', '-host_arch=$hostArch'],
        );
      }

      final vcvarsall = File(
        path.join(
          installationPath,
          'VC',
          'Auxiliary',
          'Build',
          'vcvarsall.bat',
        ),
      );
      if (vcvarsall.existsSync()) {
        logger.debug('Found vcvarsall.bat at: ${vcvarsall.path}');
        final mapVcVarsallPlatform = _mapVcVarsallPlatform(
          config.targetArchitecture,
          Architecture.current,
        );
        logger.debug('Detected vcvarsall platform: $mapVcVarsallPlatform');
        return DeveloperCommandPrompt(
          script: vcvarsall.uri,
          arguments: [mapVcVarsallPlatform],
        );
      }
    }

    throw Exception(
      'Could not find Visual Studio Developer Command Prompt script',
    );
  }

  String _mapVcDevCmdPlatform(Architecture arch) => switch (arch) {
    .arm64 => 'arm64',
    .arm => 'arm',
    .x64 => 'amd64',
    .ia32 => 'x86',
    _ => throw UnsupportedError('Unsupported Windows architecture: $arch'),
  };

  String _mapVcVarsallPlatform(
    Architecture targetArch,
    Architecture hostArch,
  ) => switch ((targetArch, hostArch)) {
    (.x64, .x64) => 'amd64',
    (.x64, .ia32) => 'x86_amd64',
    (.ia32, .ia32 || .x64) => 'x86',
    (.arm64, .x64) => 'amd64_arm64',
    (.arm64, .ia32) => 'x86_arm64',
    (.arm, .x64) => 'amd64_arm',
    (.arm, .ia32) => 'x86_arm',
    _ => throw UnsupportedError(
      'Unsupported Windows architecture combination: '
      'Target=$targetArch, Host=$hostArch',
    ),
  };

  // See https://devblogs.microsoft.com/cppblog/finding-the-visual-c-compiler-tools-in-visual-studio-2017/
  Stream<_VsWhereResult> _vsWhere() async* {
    final vsWherePaths =
        {
          ?Platform.environment['PROGRAMFILES(X86)'],
          ?Platform.environment['PROGRAMFILES'],
          r'C:\Program Files (x86)',
          r'C:\Program Files',
        }.map(
          (b) => path.join(
            b,
            'Microsoft Visual Studio',
            'Installer',
            'vswhere.exe',
          ),
        );

    for (final vsWherePath in vsWherePaths) {
      if (!File(vsWherePath).existsSync()) {
        logger.debug('vswhere.exe not found at: $vsWherePath');
        continue;
      }

      logger.debug('Found vswhere.exe at: $vsWherePath');
      yield* execStream(vsWherePath, [
            '-latest',
            '-products',
            '*',
            '-requiresAny',
            '-requires',
            'Microsoft.VisualStudio.Workload.NativeDesktop',
            '-requires',
            'Microsoft.VisualStudio.Workload.VCTools',
            '-format',
            'json',
          ])
          .transform(utf8.decoder)
          .transform(json.decoder)
          .cast<List<dynamic>>()
          .expand(_VsWhereResult.fromJsonList);
    }

    throw Exception(
      'Unable to find vswhere in any of the following locations:\n'
      '${vsWherePaths.join('\n')}',
    );
  }
}

@immutable
class _VsWhereResult {
  final String installationPath;

  const _VsWhereResult({required this.installationPath});

  factory _VsWhereResult.fromJson(Map<String, dynamic> json) {
    if (json case {'installationPath': final String installationPath}) {
      return _VsWhereResult(installationPath: installationPath);
    } else {
      throw FormatException('Invalid vswhere result json format', json);
    }
  }

  static List<_VsWhereResult> fromJsonList(List<dynamic> json) =>
      json.cast<Map<String, dynamic>>().map(_VsWhereResult.fromJson).toList();
}
