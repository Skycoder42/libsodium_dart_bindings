import 'dart:convert';
import 'dart:io';

import 'package:dart_test_tools/tools.dart';

import '../../hook/common/extractor.dart';
import 'download.dart';

final _commentRegExp = RegExp(r'^(?:\/\*|\s*\*|\s*\*\/)(?:\s|$)');

Future<void> main(List<String> args) => Github.runZoned(() async {
  final archive = await downloadLibsodium();

  await Github.logGroupAsync(
    'Generate merged license file',
    () => _mergeLicenses(archive),
  );
});

Future<void> _mergeLicenses(Uri archive) async {
  final repoLicenseFile = File('../../LICENSE');
  final sodiumLicense = await repoLicenseFile.readAsString();

  final libsodiumLicenseLines = Extractor.extractSingleFile(
    archive,
    'libsodium-stable/LICENSE',
  ).transform(utf8.decoder).transform(const LineSplitter());

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
    await for (final line in libsodiumLicenseLines) {
      final cleanLine = line.replaceFirst(_commentRegExp, '');
      packageLicenseSink.writeln(cleanLine);
    }

    await packageLicenseSink.flush();
  } finally {
    await packageLicenseSink.close();
  }
}
