import 'dart:io';

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
    await Archive.extract(archive: archive, outDir: downloadDir);
  } catch (e) {
    await downloadDir.delete(recursive: true);
    rethrow;
  } finally {
    httpClient.close();
  }

  Github.logInfo('Merging license files');
  await _mergeLicenses();
}

final _commentRegExp = RegExp(r'^(?:\/\*|\s*\*|\s*\*\/)(?:\s|$)');

Future<void> _mergeLicenses() async {
  final licenseFile = File('LICENSE');

  final sodiumLicense = await licenseFile.readAsString();
  final libsodiumLicenseFile = File('3rdparty/libsodium-stable/LICENSE');
  final libsodiumLicenseLines = await libsodiumLicenseFile.readAsLines();

  final combinedLicenseSink = licenseFile.openWrite();
  try {
    Github.logInfo('Adding ${licenseFile.path} for sodium');
    combinedLicenseSink
      ..writeln('sodium')
      ..writeln()
      ..write(sodiumLicense) // already ends with newline
      ..writeln()
      ..writeln('-' * 80)
      ..writeln()
      ..writeln('libsodium')
      ..writeln();

    Github.logInfo('Adding ${libsodiumLicenseFile.path} for libsodium');
    for (final line in libsodiumLicenseLines) {
      final cleanLine = line.replaceFirst(_commentRegExp, '');
      combinedLicenseSink.writeln(cleanLine);
    }
  } finally {
    await combinedLicenseSink.close();
  }
}
