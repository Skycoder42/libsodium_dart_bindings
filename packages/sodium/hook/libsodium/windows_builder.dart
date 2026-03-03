// ignore_for_file: avoid_print for debugging

import 'dart:convert';
import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:path/path.dart' as path;

import 'sodium_builder.dart';

final class WindowsBuilder extends SodiumBuilder {
  static const _vsVersion = 'vs2026';
  static const _toolsetVersion = 'v143';

  WindowsBuilder(super.config);

  @override
  Future<CodeAsset> buildCached({
    required BuildInput input,
    required Directory sourceDir,
    required Uri installDir,
  }) async {
    final scriptFile = await _createBuildScript(sourceDir);
    await exec('cmd.exe', ['/c', scriptFile.toFilePath(windows: true)]);
    return createCodeAsset(sourceDir.uri.resolve(_assetPath));
  }

  String get _assetPath => path.posix.join(
    'bin',
    _mapPlatform(config.targetArchitecture),
    'Release',
    _toolsetVersion,
    isStaticLinking ? 'static' : 'dynamic',
  );

  Future<Uri> _createBuildScript(Directory sourceDir) async {
    stderr
      ..writeln('CC: ${config.cCompiler?.compiler}')
      ..writeln('AR: ${config.cCompiler?.archiver}')
      ..writeln('LD ${config.cCompiler?.linker}')
      ..writeln(
        'VSDEVCMD: ${config.cCompiler?.windows.developerCommandPrompt?.script}',
      )
      ..writeln(
        'ARGS: ${config.cCompiler?.windows.developerCommandPrompt?.arguments}',
      );

    final scriptFile = File.fromUri(sourceDir.uri.resolve('dart-build.bat'));
    if (scriptFile.existsSync()) {
      return scriptFile.uri;
    }

    final scriptBuilder = StringBuffer()..writeln('@ECHO ON');

    final commandPrompt =
        config.cCompiler?.windows.developerCommandPrompt ??
        await _findVcDevCmd();

    scriptBuilder
      ..write('CALL "')
      ..write(commandPrompt.script.toFilePath(windows: true))
      ..write('"');
    for (final arg in commandPrompt.arguments) {
      scriptBuilder
        ..write(' ')
        ..write(arg);
    }

    scriptBuilder
      ..writeln()
      ..write('msbuild builds/msvc/')
      ..write(_vsVersion)
      ..write('/libsodium.sln /m /v:n /MD /p:Configuration=')
      ..write(_configuration)
      ..write(' /p:Platform=')
      ..write(_mapPlatform(config.targetArchitecture))
      ..writeln(' /p:RuntimeLibrary=MultiThreadedDLL')
      ..writeln('exit /b %errorlevel%');

    await scriptFile.writeAsString(scriptBuilder.toString(), flush: true);
    return scriptFile.uri;
  }

  String get _configuration => isStaticLinking ? 'StaticRelease' : 'DynRelease';

  String _mapPlatform(Architecture arch) => switch (arch) {
    .arm64 => 'ARM64',
    .x64 => 'x64',
    .ia32 => 'x86',
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

  Future<DeveloperCommandPrompt> _findVcDevCmd() async {
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

      // See https://devblogs.microsoft.com/cppblog/finding-the-visual-c-compiler-tools-in-visual-studio-2017/
      final installDir = await execStream(vsWherePath, [
        '-latest',
        '-products',
        '*',
        '-requires',
        'Microsoft.VisualStudio.Workload.NativeDesktop',
        '-property',
        'installationPath',
      ]).transform(utf8.decoder).join();
      print('VSWHERE result: $installDir');

      final versionFile = File(
        path.join(
          installDir,
          'VC',
          'Auxiliary',
          'Build',
          'Microsoft.VCToolsVersion.default.txt',
        ),
      );
      final version = versionFile.existsSync()
          ? (await versionFile.readAsString()).trim()
          : _toolsetVersion;
      print('VC Tools version: $version');

      final vsDevCmd = File(
        path.join(installDir, 'Common7', 'Tools', 'VsDevCmd.bat'),
      );
      if (vsDevCmd.existsSync()) {
        print('Found VsDevCmd.bat at: ${vsDevCmd.path}');
        return DeveloperCommandPrompt(
          script: vsDevCmd.uri,
          arguments: [
            '-arch=${_mapVcDevCmdPlatform(config.targetArchitecture)}',
            '-host_arch=${_mapVcDevCmdPlatform(Architecture.current)}',
          ],
        );
      }

      final vcvarsall = File(
        path.join(installDir, 'VC', 'Auxiliary', 'Build', 'vcvarsall.bat'),
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
}
