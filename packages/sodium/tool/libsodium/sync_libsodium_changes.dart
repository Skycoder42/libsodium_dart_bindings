import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:dart_test_tools/tools.dart' hide Archive;

import 'package:sodium/src/hooks/common/extractor.dart';
import 'download.dart';

final _commentRegExp = RegExp(r'^(?:\/\*|\s*\*|\s*\*\/)(?:\s|$)');

const _filesToHash = {
  'libsodium-stable/dist-build/android-armv7-a.sh',
  'libsodium-stable/dist-build/android-armv8-a.sh',
  'libsodium-stable/dist-build/android-build.sh',
  'libsodium-stable/dist-build/android-x86.sh',
  'libsodium-stable/dist-build/android-x86_64.sh',
  'libsodium-stable/dist-build/apple-xcframework.sh',
};

Future<void> main() => Github.runZoned(() async {
  final archiveUri = await downloadLibsodium();

  final archive = Github.logGroup(
    'Extracting libsodium archive',
    () => Extractor.extractArchive(archiveUri),
  );

  await Github.logGroupAsync(
    'Generate merged license file',
    () => _mergeLicenses(archive),
  );

  await Github.logGroupAsync(
    'Update file hashes',
    () => _updateHashes(archive),
  );

  await archive.clear();
});

Future<void> _mergeLicenses(Archive archive) async {
  final repoLicenseFile = File('../../LICENSE');
  final sodiumLicense = await repoLicenseFile.readAsString();

  final libsodiumLicenseLines = archive.readAsLines('libsodium-stable/LICENSE');

  final packageLicenseSink = File('LICENSE').openWrite();
  try {
    Github.logInfo('Adding sodium license: ${repoLicenseFile.uri}');
    packageLicenseSink
      ..writeln('sodium')
      ..writeln()
      ..write(sodiumLicense) // already ends with newline
      ..writeln()
      ..writeln('-' * 80)
      ..writeln()
      ..writeln('libsodium')
      ..writeln();

    Github.logInfo('Adding libsodium license from archive: $archive');
    for (final line in libsodiumLicenseLines) {
      final cleanLine = line.replaceFirst(_commentRegExp, '');
      packageLicenseSink.writeln(cleanLine);
    }

    await packageLicenseSink.flush();
  } finally {
    await packageLicenseSink.close();
  }
}

Future<void> _updateHashes(Archive archive) async {
  final hashesFile = File('tool/libsodium/.hashes.json');
  final expectedHashes = hashesFile.existsSync()
      ? json.decode(await hashesFile.readAsString()) as Map<String, dynamic>
      : null;

  final newHashes = <String, String>{};
  final modifiedFiles = <String>[];
  for (final path in _filesToHash) {
    final fileData = archive.find(path)?.readBytes();
    if (fileData == null) {
      throw Exception('File not found or has no data: $path');
    }
    final digest = sha512.convert(fileData).toString();
    newHashes[path] = digest;

    if (digest != expectedHashes?[path]) {
      Github.logNotice('Upstream file has been modified: $path');
      modifiedFiles.add(path);
    }
  }

  await hashesFile.writeAsString(json.encode(newHashes));
  await Github.env.setOutput(
    'modified-files',
    multiline: true,
    modifiedFiles.map((f) => '\n- $f').join(),
  );
}
