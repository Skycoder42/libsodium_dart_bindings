import 'dart:io';

import 'package:html/parser.dart' show parse;

import '../libsodium_version.dart' show libsodium_version;

const _sumoArg = '--sumo';
const _noEditIndexArg = '--no-edit-index';
const _helpArgs = ['-h', '--help', 'help'];

Future<void> main(List<String> arguments) async {
  if (arguments.any((arg) => _helpArgs.contains(arg))) {
    _printHelp();
    return;
  }

  final isSumo = arguments.contains(_sumoArg);
  final noEditIndex = arguments.contains(_noEditIndexArg);
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

  if (!await _copySodiumJs(targetDir, isSumo)) {
    exitCode = 1;
    return;
  }

  if (!noEditIndex) {
    await _writeScriptElement(targetDir);
  }

  stdout.writeln('> Done');
}

Future<bool> _copySodiumJs(Directory targetDir, bool isSumo) async {
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
      return false;
    }

    stdout.writeln('> Copying sodium.js to ${targetDir.path}');
    final sodiumJsFile = File.fromUri(
      tmpDir.uri.resolve(
        'dist/${isSumo ? 'browsers-sumo' : 'browsers'}/sodium.js',
      ),
    );
    if (!sodiumJsFile.existsSync()) {
      stderr.writeln('Broken git repository - unable to find sodium.js');
      return false;
    }
    await sodiumJsFile.copy(
      File.fromUri(targetDir.uri.resolve('sodium.js')).path,
    );
    return true;
  } finally {
    await tmpDir.delete(recursive: true);
  }
}

Future<void> _writeScriptElement(Directory targetDir) async {
  final indexHtmlFile = File.fromUri(targetDir.uri.resolve('index.html'));
  stdout.writeln('> Adding sodium.js to ${indexHtmlFile.path}');

  if (!indexHtmlFile.existsSync()) {
    stderr.writeln(
      'WARN: index.html does not exist! Skipping update of the file',
    );
    return;
  }

  final indexHtmlContent = await indexHtmlFile.readAsString();
  final document = parse(
    indexHtmlContent,
    sourceUrl: indexHtmlFile.uri.toString(),
  );

  final head = document.head ?? document.createElement('head');
  if (document.head == null) {
    document.append(head);
  }

  final hasScript = head.children.any(
    (element) =>
        element.localName == 'script' &&
        (element.attributes['src'] == 'sodium.js'),
  );
  if (!hasScript) {
    stdout.writeln('> Appending sodium.js script to document head');
    final sodiumScript = document.createElement('script')
      ..attributes['type'] = 'text/javascript'
      ..attributes['src'] = 'sodium.js'
      ..attributes['async'] = true.toString();
    head.append(sodiumScript);

    await indexHtmlFile.writeAsString(document.outerHtml);
  } else {
    stdout.writeln('> sodium.js script already exists. Skipping update');
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
    stdout.writeln('> Git failed with exit code $gitExitCode');
    exitCode = gitExitCode;
    return false;
  }

  return true;
}

void _printHelp() {
  stdout
    ..writeln(
      'Usage: dart run sodium_libs:update_web '
      '[$_sumoArg] [$_noEditIndexArg] [<target_directory>]',
    )
    ..writeln()
    ..writeln('$_sumoArg:           Download the sumo variant of sodium.js.')
    ..writeln(
      '$_noEditIndexArg:  Do not update index.html '
      'to automatically load sodium.js.',
    )
    ..writeln(
      'target_directory: The directory to download the binaries to. '
      'By default, the "web" directory is used.',
    );
}
