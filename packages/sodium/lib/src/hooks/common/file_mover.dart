import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;

import 'hook_logger.dart';

@internal
typedef RenameFn = Future<FileSystemEntity> Function(
  FileSystemEntity entity,
  String newPath,
);

@internal
final class FileMover(final HookLogger _logger) {
  Future<File> moveFile(File source, String destination) async {
    try {
      return await source.rename(destination);
    } on FileSystemException catch (e) {
      _logRenameFailed(source, destination, e);
      final copy = await source.copy(destination);
      await source.delete();
      return copy;
    }
  }

  Future<Directory> moveDirectory(Directory source, String destination) async {
    try {
      return await source.rename(destination);
    } on FileSystemException catch (e) {
      _logRenameFailed(source, destination, e);
      final copy = Directory(destination);
      await _copyDirectory(source, copy);
      await source.delete(recursive: true);
      return copy;
    }
  }

  Future<void> _copyDirectory(Directory source, Directory destination) async {
    await destination.create();
    await for (final entity in source.list(followLinks: false)) {
      final target = path.join(destination.path, path.basename(entity.path));
      switch (entity) {
        case Link():
          await Link(target).create(await entity.target());
        case Directory():
          await _copyDirectory(entity, Directory(target));
        case File():
          await entity.copy(target);
      }
    }
  }

  void _logRenameFailed(
    FileSystemEntity source,
    String destination,
    FileSystemException error,
  ) => _logger
    ..debug('Failed to rename ${source.path} to $destination: $error')
    ..debug('Copying and deleting the source instead.');
}
