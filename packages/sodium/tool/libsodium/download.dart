import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dart_test_tools/tools.dart';

import '../../hook/build.dart';
import 'constants.dart';

Future<void> main(List<String> args) => Github.runZoned(() async {
  await Github.logGroupAsync(
    'Ensure minisign is installed',
    Minisign.ensureInstalled,
  );

  await Github.logGroupAsync(
    'Download, verify and extract libsodium sources',
    _downloadLibsodium,
  );

  await Github.env.setOutput(skipBuildHooksVariableName, '0', asEnv: true);
});

Future<void> _downloadLibsodium() async {
  final downloadDir = Directory('3rdparty').absolute;

  if (downloadDir.existsSync()) {
    await downloadDir.delete(recursive: true);
  }
  await downloadDir.create(recursive: true);

  final httpClient = HttpClient();
  try {
    final archive = await httpClient.download(
      downloadDir,
      libsodiumSrcDownloadUri,
    );
    await Minisign.verify(archive, libsodiumSigningKey);

    Github.logInfo('Merging license files');
    await _mergeLicenses(archive);
  } catch (e) {
    await downloadDir.delete(recursive: true);
    rethrow;
  } finally {
    httpClient.close();
  }
}

final _commentRegExp = RegExp(r'^(?:\/\*|\s*\*|\s*\*\/)(?:\s|$)');

Future<void> _mergeLicenses(File archive) async {
  final repoLicenseFile = File('../../LICENSE');
  final sodiumLicense = await repoLicenseFile.readAsString();

  final libsodiumLicenseLines = _extractFile(
    archive.path,
    'libsodium-stable/LICENSE',
  ).cast<List<int>>().transform(utf8.decoder).transform(const LineSplitter());

  final packageLicenseSink = File('LICENSE').openWrite();
  try {
    Github.logInfo('> Adding LICENSE for sodium');
    packageLicenseSink
      ..writeln('sodium')
      ..writeln()
      ..write(sodiumLicense) // already ends with newline
      ..writeln()
      ..writeln('-' * 80)
      ..writeln()
      ..writeln('libsodium')
      ..writeln();

    Github.logInfo('> Adding LICENSE for libsodium');
    await for (final line in libsodiumLicenseLines) {
      final cleanLine = line.replaceFirst(_commentRegExp, '');
      packageLicenseSink.writeln(cleanLine);
    }
  } finally {
    await packageLicenseSink.close();
  }
}

Stream<Uint8List> _extractFile(
  String archivePath,
  String fileInArchive,
) async* {
  final tarGzInStream = InputFileStream(archivePath);
  final tarOutStream = OutputMemoryStream();
  try {
    final ok = const GZipDecoder().decodeStream(
      tarGzInStream,
      tarOutStream,
      verify: true,
    );
    if (!ok) {
      throw Exception(
        'Failed to decode gzip stream from archive: $archivePath',
      );
    }

    final archive = TarDecoder().decodeBytes(
      tarOutStream.getBytes(),
      verify: true,
    );

    final archiveFile = archive.files.firstWhere(
      (file) => file.isFile && file.name == fileInArchive,
      orElse: () => throw Exception(
        'File "$fileInArchive" not found in archive: $archivePath',
      ),
    );

    yield archiveFile.content;
    await archive.clear();
  } finally {
    await tarGzInStream.close();
    await tarOutStream.close();
  }
}
