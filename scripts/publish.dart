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
      final file = File(rmFile);
      if (await file.exists()) {
        print('rm $file');
        await file.delete();
      }
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
