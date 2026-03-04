// ignore_for_file: avoid_print for debug logging

import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import 'sodium_builder.dart';

final class WindowsBuilder extends SodiumBuilder {
  static const _buildPropsFileName = 'buildProps.json';
  static const _vsFallbackVersion = 'vs2026';
  static const _vsVersionMap = {
    '18': _vsFallbackVersion,
    '17': 'vs2022',
    '16': 'vs2019',
    '15': 'vs2017',
    // older versions are not supported by this library
  };

  WindowsBuilder(super.config);

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
    final outFile = File.fromUri(sourceDir.uri.resolve(_buildPropsFileName));
    final buildPropsJson = await outFile.readAsString();
    stderr.writeln('Build properties JSON: $buildPropsJson');
    final buildProps = _VsBuildProps.fromJson(
      json.decode(buildPropsJson) as Map<String, dynamic>,
    );
    return createCodeAsset(
      Uri.file(path.canonicalize(buildProps.properties.targetPath)),
      isFullPath: true,
    );
  }

  Future<Uri> _createBuildScript(Directory sourceDir) async {
    final scriptFile = File.fromUri(sourceDir.uri.resolve('dart-build.bat'));
    if (scriptFile.existsSync()) {
      return scriptFile.uri;
    }

    final scriptBuilder = StringBuffer()..writeln('@ECHO ON');

    final (
      commandPrompt,
      vsVersion,
    ) = switch (config.cCompiler?.windows.developerCommandPrompt) {
      DeveloperCommandPrompt commandPrompt => (
        commandPrompt,
        await _findVsVersionFromPrompt(sourceDir, commandPrompt),
      ),
      _ => await _findVcDevCmd(),
    };
    stderr
      ..writeln('Using Visual Studion Configuration:')
      ..writeln('  >> Script: ${commandPrompt.script}')
      ..writeln('  >> Args: ${commandPrompt.arguments}')
      ..writeln('  >> Version: $vsVersion');

    _writeSetupEnv(scriptBuilder, commandPrompt);
    scriptBuilder.writeln();

    _writeMsBuildCommonArgs(scriptBuilder, vsVersion);
    scriptBuilder
      ..write(' /v:q /getProperty:TargetPath > ')
      ..writeln(_buildPropsFileName);

    _writeMsBuildCommonArgs(scriptBuilder, vsVersion);
    scriptBuilder
      ..writeln(' /m /v:n')
      ..writeln('exit /b %errorlevel%');

    await scriptFile.writeAsString(scriptBuilder.toString(), flush: true);
    return scriptFile.uri;
  }

  void _writeSetupEnv(
    StringBuffer scriptBuilder,
    DeveloperCommandPrompt commandPrompt,
  ) {
    scriptBuilder
      ..write('CALL "')
      ..write(commandPrompt.script.toFilePath(windows: true))
      ..write('"');
    for (final arg in commandPrompt.arguments) {
      scriptBuilder
        ..write(' ')
        ..write(arg);
    }
  }

  void _writeMsBuildCommonArgs(StringBuffer scriptBuilder, String vsVersion) {
    scriptBuilder
      ..write('msbuild builds/msvc/')
      ..write(vsVersion)
      ..write('/libsodium/libsodium.vcxproj /p:Configuration=')
      ..write(_configuration)
      ..write(' /p:Platform=')
      ..write(_mapPlatform(config.targetArchitecture))
      ..write(' /p:RuntimeLibrary=MultiThreadedDLL');
  }

  String get _configuration => isStaticLinking ? 'ReleaseLIB' : 'ReleaseDLL';

  String _mapPlatform(Architecture arch) => switch (arch) {
    .arm64 => 'ARM64',
    .x64 => 'x64',
    .ia32 => 'Win32',
    _ => throw UnsupportedError('Unsupported Windows architecture: $arch'),
  };

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

  Future<(DeveloperCommandPrompt, String)> _findVcDevCmd() async {
    await for (final _VsWhereResult(:installationPath, :installationVersion)
        in _vsWhere()) {
      final majorVersion = installationVersion.split('.').first;
      final vsVersion = _vsVersionMap[majorVersion] ?? _vsFallbackVersion;

      if (!Directory(installationPath).existsSync()) {
        print('Installation directory not found: $installationPath');
        continue;
      }

      final vsDevCmd = File(
        path.join(installationPath, 'Common7', 'Tools', 'VsDevCmd.bat'),
      );
      if (vsDevCmd.existsSync()) {
        print('Found VsDevCmd.bat at: ${vsDevCmd.path}');
        return (
          DeveloperCommandPrompt(
            script: vsDevCmd.uri,
            arguments: [
              '-arch=${_mapVcDevCmdPlatform(config.targetArchitecture)}',
              '-host_arch=${_mapVcDevCmdPlatform(Architecture.current)}',
            ],
          ),
          vsVersion,
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
        return (
          DeveloperCommandPrompt(
            script: vcvarsall.uri,
            arguments: [
              _mapVcVarsallPlatform(
                config.targetArchitecture,
                Architecture.current,
              ),
            ],
          ),
          vsVersion,
        );
      }
    }

    throw Exception(
      'Could not find Visual Studio Developer Command Prompt script',
    );
  }

  Future<String> _findVsVersionFromPrompt(
    Directory sourceDir,
    DeveloperCommandPrompt commandPrompt,
  ) async {
    final scriptBuilder = StringBuffer()..writeln('@ECHO OFF');

    _writeSetupEnv(scriptBuilder, commandPrompt);
    scriptBuilder
      ..writeln('> nul')
      ..writeln(
        'if "%VSCMD_VER%"=="" echo %VisualStudioVersion% else echo %VSCMD_VER%',
      );

    final scriptFile = File.fromUri(sourceDir.uri.resolve('dart-build.bat'));
    await scriptFile.writeAsString(scriptBuilder.toString(), flush: true);
    final result = await execStream('cmd.exe', [
      '/c',
      scriptFile.path,
    ], workingDirectory: sourceDir).transform(utf8.decoder).join();

    final majorVersion = result.trim().split('.').first;
    final vsVersion = _vsVersionMap[majorVersion] ?? _vsFallbackVersion;
    return vsVersion;
  }

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
  final String installationVersion;

  const _VsWhereResult({
    required this.installationPath,
    required this.installationVersion,
  });

  factory _VsWhereResult.fromJson(Map<String, dynamic> json) {
    if (json case {
      'installationPath': final String installationPath,
      'installationVersion': final String installationVersion,
    }) {
      return _VsWhereResult(
        installationPath: installationPath,
        installationVersion: installationVersion,
      );
    } else {
      throw FormatException('Invalid vswhere result json format', json);
    }
  }

  static List<_VsWhereResult> fromJsonList(List<dynamic> json) =>
      json.cast<Map<String, dynamic>>().map(_VsWhereResult.fromJson).toList();
}

@immutable
class _VsBuildProps {
  final _VsProperties properties;

  const _VsBuildProps(this.properties);

  factory _VsBuildProps.fromJson(Map<String, dynamic> json) {
    if (json case {'Properties': final Map<String, dynamic> propertiesJson}) {
      return _VsBuildProps(_VsProperties.fromJson(propertiesJson));
    } else {
      throw FormatException('Invalid build props json format', json);
    }
  }
}

@immutable
class _VsProperties {
  final String targetPath;

  const _VsProperties({required this.targetPath});

  factory _VsProperties.fromJson(Map<String, dynamic> json) {
    if (json case {'TargetPath': final String targetPath}) {
      return _VsProperties(targetPath: targetPath);
    } else {
      throw FormatException('Invalid build props json format', json);
    }
  }
}
