import 'dart:io';

import 'run.dart';

Future<void> publish(
  List<String> args, {
  List<String> clearFiles = const [],
}) async {
  const pubIgnorePath = '.pubignore';

  final rootGitIgnore = File('../../.gitignore');
  File? pubIgnore;

  try {
    pubIgnore = await rootGitIgnore.copy(pubIgnorePath);
    for (final clearFile in clearFiles) {
      await run('git', ['rm', clearFile]);
    }

    await run('dart', ['pub', 'publish', ...args]);
  } on ChildErrorException catch (e) {
    exitCode = e.exitCode;
  } finally {
    await pubIgnore?.delete();
    for (final clearFile in clearFiles) {
      await run('git', ['checkout', 'HEAD', clearFile]);
    }
  }
}
