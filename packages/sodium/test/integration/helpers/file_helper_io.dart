import 'dart:async';
import 'dart:io';

import 'package:test/test.dart';

class FileHelper {
  final Directory _dir;

  FileHelper._(this._dir);

  static Future<FileHelper> instance() async {
    final dir = await Directory.systemTemp.createTemp();
    addTearDown(() => dir.delete(recursive: true));
    return FileHelper._(dir);
  }

  Future<void> writeBytes(String name, List<int> bytes) =>
      _file(name).writeAsBytes(
        bytes,
        flush: true,
      );

  Future<List<int>> readBytes(String name) => _file(name).readAsBytes();

  Stream<List<int>> read(String name) => _file(name).openRead();

  StreamConsumer<List<int>> write(String name) => _file(name).openWrite();

  int length(String name) => _file(name).lengthSync();

  File _file(String name) => File.fromUri(_dir.uri.resolve(name));
}
