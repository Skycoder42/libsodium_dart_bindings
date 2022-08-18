import 'dart:io';

import '../libsodium_version.dart' show libsodium_version;

const _sumoArg = '--sumo';

Future<void> main(List<String> arguments) async {
  final isSumo = arguments.contains(_sumoArg);
  final targetDir = Directory(
    arguments.firstWhere(
      (arg) => arg != _sumoArg,
      orElse: () => 'web',
    ),
  );

  if (!targetDir.existsSync()) {
    stderr.writeln(
      'Directory ${targetDir.path} does not exists - '
      'cannot download web binaries!',
    );
    exitCode = 1;
    return;
  }

  stdout.writeln('> Fetching sodium.js repository');
  final tmpDir = await Directory.systemTemp.createTemp();
  try {
    if (!await _runGit(
      [
        'clone',
        '-b',
        libsodium_version.js,
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
      tmpDir.uri.resolve(
        'dist/${isSumo ? 'browsers-sumo' : 'browsers'}/sodium.js',
      ),
    );
    if (!sodiumJsFile.existsSync()) {
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
