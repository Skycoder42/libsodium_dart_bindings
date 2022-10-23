import 'dart:io';

import 'package:args/args.dart';
import 'package:html/parser.dart' show parse;

import '../libsodium_version.dart' show libsodium_version;

const _sumoArg = 'sumo';
const _editIndexArg = 'edit-index';
const _targetDirectoryArg = 'target-directory';
const _helpArg = 'help';

Future<void> main(List<String> rawArguments) async {
  final parser = ArgParser(
    allowTrailingOptions: false,
    usageLineLength: stdout.hasTerminal ? stdout.terminalColumns : null,
  )
    ..addFlag(
      _sumoArg,
      help: 'Download the sumo variant of sodium.js.',
    )
    ..addFlag(
      _editIndexArg,
      defaultsTo: true,
      help: 'Update index.html to automatically load sodium.js.',
    )
    ..addOption(
      _targetDirectoryArg,
      abbr: 'd',
      defaultsTo: 'web',
      help: 'The directory to download the binaries to.',
    )
    ..addFlag(
      _helpArg,
      abbr: 'h',
      negatable: false,
      help: 'Show this help.',
    );

  try {
    final arguments = parser.parse(rawArguments);
    if (arguments[_helpArg] as bool) {
      stdout.writeln(parser.usage);
      return;
    }

    final isSumo = arguments[_sumoArg] as bool;
    final editIndex = arguments[_editIndexArg] as bool;
    final targetDir = Directory(arguments[_targetDirectoryArg] as String);

    exitCode = await _runUpdateWeb(isSumo, editIndex, targetDir);
  } on ArgParserException catch (e) {
    stderr
      ..writeln(e.message)
      ..writeln()
      ..writeln('Usage:')
      ..writeln(parser.usage);
    exitCode = 127;
  }
}

Future<int> _runUpdateWeb(
  bool isSumo,
  bool editIndex,
  Directory targetDir,
) async {
  if (!targetDir.existsSync()) {
    stderr.writeln(
      'Directory ${targetDir.path} does not exists - '
      'cannot download web binaries!',
    );
    return 1;
  }

  if (!await _copySodiumJs(targetDir, isSumo)) {
    return 1;
  }

  if (editIndex) {
    await _writeScriptElement(targetDir);
  }

  stdout.writeln('> Done');
  return 0;
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
