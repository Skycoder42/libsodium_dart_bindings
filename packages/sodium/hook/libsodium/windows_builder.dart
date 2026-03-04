// ignore_for_file: avoid_print for debug logging

import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import 'sodium_builder.dart';

final class WindowsBuilder extends SodiumBuilder {
  static const _vsFallbackVersion = 'vs2026';
  static const _vsVersionMap = {
    '18': _vsFallbackVersion,
    '17': 'vs2022',
    '16': 'vs2019',
    '15': 'vs2017',
    // older versions are not supported by this library
  };
  static const _toolsetVersion = 'v143';

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

    final outFile = File.fromUri(sourceDir.uri.resolve('outdir.txt'));
    final outDirPath = outFile.existsSync()
        ? (await outFile.readAsString()).trim()
        : null;
    stderr.writeln('Build output directory: <<$outDirPath>>');

    return createCodeAsset(sourceDir.uri.resolve(_assetPath));
  }

  String get _assetPath => path.posix.join(
    'bin',
    _mapPlatform(config.targetArchitecture),
    'Release',
    _toolsetVersion,
    isStaticLinking ? 'static/' : 'dynamic/',
  );

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
        _vsFallbackVersion,
      ),
      _ => await _findVcDevCmd(),
    };
    stderr
      ..writeln('Using Visual Studion Configuration:')
      ..writeln('  >> Script: ${commandPrompt.script}')
      ..writeln('  >> Args: ${commandPrompt.arguments}')
      ..writeln('  >> Version: $vsVersion');

    scriptBuilder
      ..write('CALL "')
      ..write(commandPrompt.script.toFilePath(windows: true))
      ..write('"');
    for (final arg in commandPrompt.arguments) {
      scriptBuilder
        ..write(' ')
        ..write(arg);
    }

    scriptBuilder.writeln();
    _writeMsBuildCommonArgs(scriptBuilder, vsVersion);
    scriptBuilder
      ..writeln('-getProperty:OutDir,PlatformToolset > outdir.txt')
      ..writeln('type outdir.txt');

    _writeMsBuildCommonArgs(scriptBuilder, vsVersion);
    scriptBuilder
      ..writeln()
      ..writeln('exit /b %errorlevel%');

    await scriptFile.writeAsString(scriptBuilder.toString(), flush: true);
    return scriptFile.uri;
  }

  void _writeMsBuildCommonArgs(StringBuffer scriptBuilder, String vsVersion) {
    scriptBuilder
      ..write('msbuild builds/msvc/')
      ..write(vsVersion)
      ..write('/libsodium/libsodium.vcxproj /m /v:n /p:Configuration=')
      ..write(_configuration)
      ..write(' /p:Platform=')
      ..write(_mapPlatform(config.targetArchitecture))
      ..write(' /p:RuntimeLibrary=MultiThreadedDLL');
  }

  String get _configuration => isStaticLinking ? 'StaticRelease' : 'DynRelease';

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
    final vsWherePaths =
        [
          Platform.environment['PROGRAMFILES(X86)'],
          Platform.environment['PROGRAMFILES'],
          r'C:\Program Files (x86)',
          r'C:\Program Files',
        ].nonNulls.map(
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

      await for (final _VsWhereResult(:installationPath, :installationVersion)
          in _vsWhere(vsWherePath)) {
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
    }

    throw Exception(
      'Could not find Visual Studio Developer Command Prompt script',
    );
  }

  // See https://devblogs.microsoft.com/cppblog/finding-the-visual-c-compiler-tools-in-visual-studio-2017/
  Stream<_VsWhereResult> _vsWhere(String vsWherePath) =>
      execStream(vsWherePath, [
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
