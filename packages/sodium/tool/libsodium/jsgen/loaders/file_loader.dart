import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:path/path.dart';

class FileLoader {
  final Directory directory;

  new(this.directory);

  static Directory get scriptDir => File.fromUri(Platform.script).parent;

  Future<String> loadFile(String subPath) =>
      _resolveFile(subPath).readAsString();

  Future<Digest> calculateHash(String path) async =>
      await _resolveFile(path).openRead().transform(sha512).single;

  Future<TData> loadFileJson<TData, TJson>(
    String subPath,
    TData Function(TJson) fromJson,
  ) async {
    final jsonData = json.decode(await loadFile(subPath));
    return fromJson(jsonData as TJson);
  }

  Future<List<File>> listFilesSorted(
    String subDir,
    bool Function(File file) filter,
  ) async {
    final dir = Directory(join(directory.path, subDir));
    final files = await dir
        .list()
        .where((entry) => entry is File)
        .cast<File>()
        .where(filter)
        .toList();
    return files..sort((lhs, rhs) => lhs.path.compareTo(rhs.path));
  }

  Stream<TData> loadFilesJson<TData, TJson>(
    String subDir,
    bool Function(File file) filter,
    TData Function(TJson) fromJson,
  ) async* {
    final files = await listFilesSorted(subDir, filter);
    for (final file in files) {
      final jsonData = json.decode(await file.readAsString());
      yield fromJson(jsonData as TJson);
    }
  }

  File _resolveFile(String subPath) => File(join(directory.path, subPath));
}
