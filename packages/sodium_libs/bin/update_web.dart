import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> arguments) async {
  final targetDir = Directory(
    arguments.firstWhere(
      (_) => true,
      orElse: () => 'web',
    ),
  );

  if (!await targetDir.exists()) {
    stderr.writeln(
      'Directory ${targetDir.path} does not exists - '
      'cannot download web binaries!',
    );
    exitCode = 1;
    return;
  }

  stdout.writeln('> Loading sodium.js version info');
  final scriptDir = File.fromUri(Platform.script).parent;
  final versionInfo = File.fromUri(
    scriptDir.uri.resolve('../libsodium_version.json'),
  );
  if (!await versionInfo.exists()) {
    stderr.writeln('Failed to find version info at path: ${versionInfo.path}');
    exitCode = 1;
    return;
  }
  final versionJson = json.decode(
    await versionInfo.readAsString(),
  ) as Map<String, dynamic>;

  stdout.writeln('> Fetching sodium.js repository');
  final tmpDir = await Directory.systemTemp.createTemp();
  try {
    if (!await _runGit(
      [
        'clone',
        '-b',
        versionJson['js'] as String,
        '--depth',
        '1',
        'https://github.com/jedisct1/libsodium.js.git',
        '.',
      ],
      tmpDir,
    )) {
      return;
    }

    stdout.writeln('> Copying sodium.js to ${targetDir.path}');
    final sodiumJsFile = File.fromUri(
      tmpDir.uri.resolve('dist/browsers/sodium.js'),
    );
    if (!await sodiumJsFile.exists()) {
      stderr.writeln('Broken git repository - unable to find sodium.js');
      exitCode = 1;
      return;
    }
    await sodiumJsFile.copy(
      File.fromUri(targetDir.uri.resolve('sodium.js')).path,
    );

    stdout.writeln('> Done');
  } finally {
    await tmpDir.delete(recursive: true);
  }
}

Future<bool> _runGit(List<String> arguments, Directory workingDir) async {
  stdout.writeln('> Running git ${arguments.join(' ')}');
  final proc = await Process.start(
    'git',
    arguments,
    workingDirectory: workingDir.path,
    mode: ProcessStartMode.inheritStdio,
  );

  final gitExitCode = await proc.exitCode;
  if (gitExitCode != 0) {
    stdout.writeln('Git failed with exit code $gitExitCode');
    exitCode = gitExitCode;
    return false;
  }

  return true;
}
