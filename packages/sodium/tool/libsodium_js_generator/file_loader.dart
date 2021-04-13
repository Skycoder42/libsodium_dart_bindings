import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';

class FileLoader {
  final Directory wrapperDir;

  const FileLoader(this.wrapperDir);

  static Directory get scriptDir => File.fromUri(Platform.script).parent;

  Future<String> loadFile(String subPath) {
    final file = File(join(wrapperDir.path, subPath));
    return file.readAsString();
  }

  Future<dynamic> loadFileJson(String subPath) async =>
      json.decode(await loadFile(subPath));

  Future<List<File>> listFilesSorted(
    String subDir,
    bool Function(File file) filter,
  ) async {
    final symbolsDir = Directory(join(wrapperDir.path, subDir));
    final symbolFiles = await symbolsDir
        .list()
        .where((entry) => entry is File)
        .cast<File>()
        .where(filter)
        .toList();
    return symbolFiles..sort((lhs, rhs) => lhs.path.compareTo(rhs.path));
  }

  Stream<dynamic> loadFilesJson(
    String subDir,
    bool Function(File file) filter,
  ) async* {
    final files = await listFilesSorted(subDir, filter);
    for (final file in files) {
      yield json.decode(await file.readAsString());
    }
  }
}
