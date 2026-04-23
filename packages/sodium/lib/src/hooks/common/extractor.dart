import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:code_assets/code_assets.dart';
import 'package:meta/meta.dart';
import 'package:path/path.dart' as path;
import 'package:posix/posix.dart' as posix;

@internal
class FileNotExtractedException implements Exception {
  final String message;

  FileNotExtractedException(this.message);

  @override
  String toString() => 'FileNotExtractedException: $message';
}

@internal
sealed class Extractor {
  static Archive extractArchive(Uri archiveUri) {
    final tarGzInStream = InputFileStream(archiveUri.toFilePath());
    try {
      final tarOutStream = OutputMemoryStream();
      final ok = const GZipDecoder().decodeStream(
        tarGzInStream,
        tarOutStream,
        verify: true,
      );
      if (!ok) {
        throw Exception(
          'Failed to decode gzip stream from archive: $archiveUri',
        );
      }

      return TarDecoder().decodeBytes(tarOutStream.getBytes(), verify: true);
    } finally {
      tarGzInStream.closeSync();
    }
  }

  static Future<void> extractToDisk(
    Uri archiveUri,
    Uri outDirUri, [
    void Function(String)? logFileExtracted,
  ]) async {
    final outDir = Directory.fromUri(outDirUri);
    if (!outDir.existsSync()) {
      await outDir.create(recursive: true);
    }

    final archive = extractArchive(archiveUri);
    try {
      if (OS.current == .windows) {
        // MAX_PATH includes the trailing NUL, so the usable path budget
        // before cl.exe's ANSI APIs reject it is MAX_PATH - 1 = 259.
        const maxPath = 260;
        final base = path.absolute(outDir.path);
        for (final entry in archive) {
          final resolvedLength = path.join(base, entry.name).length;
          if (resolvedLength >= maxPath) {
            throw FileNotExtractedException(
              'Extracting "${entry.name}" to a $resolvedLength-character path '
              'would exceed Windows MAX_PATH ($maxPath). MSVC cl.exe cannot '
              'open paths longer than this via its legacy ANSI APIs.',
            );
          }
        }
      }

      for (final entry in archive) {
        final filePath = path.normalize(path.join(outDir.path, entry.name));

        if (!_isWithinOutputPath(outDir.path, filePath)) {
          throw Exception(
            'The libsodium archive contains an entry with a path that is '
            'outside the output directory: "${entry.name}". Extraction has '
            'been aborted for security reasons.',
          );
        }

        if (entry.isSymbolicLink) {
          throw Exception(
            'The libsodium archive should not contain symbolic links, but '
            'found one pointing to "${entry.symbolicLink}" in file '
            '${entry.name}. Extraction has been aborted for security reasons.',
          );
        }

        if (entry.isDirectory) {
          await Directory(filePath).create(recursive: true);
          continue;
        }

        if (!entry.isFile) {
          throw Exception(
            'The libsodium archive contains an entry that is not a file, '
            'directory, or symbolic link: "${entry.name}". Extraction has been '
            'aborted for security reasons.',
          );
        }

        final output = OutputFileStream(filePath);
        try {
          entry.writeContent(output);
          output.flush();
          await output.close();

          if (OS.current case .linux || .macOS) {
            posix.chmodWithMode(filePath, entry.mode);
          }

          logFileExtracted?.call(path.relative(filePath, from: outDir.path));
        } finally {
          if (output.isOpen) {
            await output.close();
          }
        }
      }
    } finally {
      await archive.clear();
    }
  }

  static bool _isWithinOutputPath(String outputDir, String filePath) =>
      path.isWithin(path.canonicalize(outputDir), path.canonicalize(filePath));
}

@internal
extension ArchiveX on Archive {
  Iterable<String> readAsLines(String path) {
    final file = find(path);
    if (file == null) {
      throw Exception('File not found: $path');
    }
    if (!file.isFile) {
      throw Exception('Archive entry is not a file: $path');
    }
    final content = file.getContent();
    if (content == null) {
      throw Exception('File has no content: $path');
    }

    try {
      return LineSplitter.split(content.readString());
    } finally {
      content.closeSync();
    }
  }
}
