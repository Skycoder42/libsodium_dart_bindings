import 'dart:io';

import 'package:args/args.dart';
import 'package:html/parser.dart' show parse;

import 'package:sodium/src/hooks/constants.dart';
import 'package:sodium/src/js/update_web/js_library_loader.dart';

const _sumoArg = 'sumo';
const _editIndexArg = 'edit-index';
const _targetDirectoryArg = 'target-directory';
const _helpArg = 'help';

Future<void> main(List<String> rawArguments) async {
  final parser =
      ArgParser(
          allowTrailingOptions: false,
          usageLineLength: stdout.hasTerminal ? stdout.terminalColumns : null,
        )
        ..addFlag(_sumoArg, help: 'Download the sumo variant of sodium.js.')
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
  try {
    final distRef = isSumo ? HookConstants.jsSumoDist : HookConstants.jsDist;
    final targetFile = File.fromUri(targetDir.uri.resolve('sodium.js'));
    stdout.writeln(
      '> Downloading ${distRef.path} '
      'version ${HookConstants.libsodiumVersion.js} '
      '(${HookConstants.libsodiumVersion.jsRef}) to ${targetFile.path}',
    );

    const repoLoader = JsLibraryLoader();
    await repoLoader.downloadTo(distRef, targetFile);
    return true;
  } on Exception catch (e) {
    stderr.writeln('> Failed to download sodium.js: $e');
    return false;
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
      ..attributes['async'] = 'true';
    head.append(sodiumScript);

    await indexHtmlFile.writeAsString(document.outerHtml);
  } else {
    stdout.writeln('> sodium.js script already exists. Skipping update');
  }
}
