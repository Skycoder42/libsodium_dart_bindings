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
    final scriptFile = File.fromUri(sourceDir.uri.resolve('dart-build.bat'));
    if (scriptFile.existsSync()) {
      return scriptFile.uri;
    }

    final scriptBuilder = StringBuffer()..writeln('@ECHO OFF');

    if (config.cCompiler?.windows.developerCommandPrompt
        case final commandPrompt?) {
      scriptBuilder
        ..write('CALL "')
        ..write(commandPrompt.script.toFilePath(windows: true))
        ..write('"');
      for (final arg in commandPrompt.arguments) {
        scriptBuilder
          ..write(' ')
          ..write(arg);
      }
      scriptBuilder.writeln(' > nul 2>&1');
    }

    scriptBuilder
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
    .ia32 => 'Win32',
    _ => throw UnsupportedError('Unsupported Windows architecture: $arch'),
  };
}
