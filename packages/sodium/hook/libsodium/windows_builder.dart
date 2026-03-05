// ignore_for_file: avoid_print for debug logging

import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import 'sodium_builder.dart';

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

  WindowsBuilder(super.config);

  @override
  Future<void> prepare() async {
    _commandPrompt =
        config.cCompiler?.windows.developerCommandPrompt ??
        await _findVcDevCmd();
  }

  @override
  Iterable<Object?> get configHash sync* {
    yield* super.configHash;
    yield _commandPrompt.script;
    yield _commandPrompt.arguments;
  }

  @override
  Future<CodeAsset> buildCached({
    required BuildInput input,
    required Directory sourceDir,
    required Uri installDir,
  }) async {
    final scriptFile = await _createBuildScript(sourceDir);
    await exec('cmd.exe', [
      '/c',
      scriptFile.toFilePath(windows: true),
    ], workingDirectory: sourceDir);

    return await _createAsset(sourceDir);
  }

  Future<CodeAsset> _createAsset(Directory sourceDir) async {
    final outFile = File.fromUri(sourceDir.uri.resolve(_targetOutputFileName));
    final targetPath = await outFile.readAsString();
    return createCodeAsset(
      Uri.file(path.canonicalize(targetPath.trim())),
      isFullPath: true,
    );
  }

  Future<Uri> _createBuildScript(Directory sourceDir) async {
    final scriptFile = File.fromUri(sourceDir.uri.resolve('dart-build.bat'));
    if (scriptFile.existsSync()) {
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

      _writeMsBuildCommonArgs(scriptFileSink);
      scriptFileSink
        ..writeln(' /m /v:n')
        ..writeln('exit /b %errorlevel%');

      await scriptFileSink.flush();
    } finally {
      await scriptFileSink.close();
    }

    return scriptFile.uri;
  }

  void _writeMsBuildCommonArgs(StringSink scriptBuilder) {
    scriptBuilder
      ..write(
        'msbuild "builds/msvc/%__SODIUM_VS_NAME%/libsodium/libsodium.vcxproj"',
      )
      ..write(' /p:Configuration=')
      ..write(isStaticLinking ? 'ReleaseLIB' : 'ReleaseDLL')
      ..write(' /p:Platform=')
      ..write(_mapPlatform(config.targetArchitecture))
      ..write(' /p:RuntimeLibrary=MultiThreadedDLL');
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
        print('Installation directory not found: $installationPath');
        continue;
      }

      final vsDevCmd = File(
        path.join(installationPath, 'Common7', 'Tools', 'VsDevCmd.bat'),
      );
      if (vsDevCmd.existsSync()) {
        print('Found VsDevCmd.bat at: ${vsDevCmd.path}');
        DeveloperCommandPrompt(
          script: vsDevCmd.uri,
          arguments: [
            '-arch=${_mapVcDevCmdPlatform(config.targetArchitecture)}',
            '-host_arch=${_mapVcDevCmdPlatform(Architecture.current)}',
          ],
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
        print('Found vcvarsall.bat at: ${vcvarsall.path}');
        return DeveloperCommandPrompt(
          script: vcvarsall.uri,
          arguments: [
            _mapVcVarsallPlatform(
              config.targetArchitecture,
              Architecture.current,
            ),
          ],
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
        print('vswhere.exe not found at $vsWherePath');
        continue;
      }

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
