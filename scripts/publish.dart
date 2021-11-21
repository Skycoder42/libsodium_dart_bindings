import 'dart:io';

import 'run.dart';

Future<void> publish(
  List<String> args, {
  List<String> clearFiles = const [],
  List<String> rmFiles = const [],
  bool flutter = false,
}) async {
  const pubIgnorePath = '.pubignore';

  final rootGitIgnore = File('../../.gitignore');
  File? pubIgnore;

  try {
    pubIgnore = await rootGitIgnore.copy(pubIgnorePath);
    for (final clearFile in clearFiles) {
      await run('git', ['rm', clearFile]);
    }

    for (final rmFile in rmFiles) {
      final fse = await _fseFromPath(rmFile);
      print('rm $fse');
      await fse?.delete();
    }

    await run(
      flutter ? 'flutter' : 'dart',
      ['pub', 'publish', ...args],
      runInShell: flutter && Platform.isWindows,
    );
  } on ChildErrorException catch (e) {
    exitCode = e.exitCode;
  } finally {
    await pubIgnore?.delete();
    for (final clearFile in clearFiles) {
      await run('git', ['checkout', 'HEAD', clearFile]);
    }
  }
}

Future<FileSystemEntity?> _fseFromPath(String path) async {
  switch (await FileSystemEntity.type(path)) {
    case FileSystemEntityType.file:
      return File(path);
    case FileSystemEntityType.directory:
      return Directory(path);
    case FileSystemEntityType.link:
      return Link(path);
    case FileSystemEntityType.notFound:
      return null;
    default:
      throw StateError('Unreachable code was reached');
  }
}
