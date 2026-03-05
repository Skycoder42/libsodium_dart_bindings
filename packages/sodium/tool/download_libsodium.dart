import 'dart:io';

import 'package:dart_test_tools/tools.dart';

import '../../sodium_libs/libsodium_version.dart';
import '../hook/build.dart';

final _libsodiumDownloadUri = Uri.https(
  'download.libsodium.org',
  '/libsodium/releases/libsodium-${libsodium_version.ffi}-stable.tar.gz',
);

Future<void> main(List<String> args) => Github.runZoned(() async {
  await Github.logGroupAsync(
    'Ensure minisign is installed',
    Minisign.ensureInstalled,
  );

  await Github.logGroupAsync(
    'Download, verify and extract libsodium sources',
    downloadLibsodium,
  );

  await Github.env.setOutput(skipBuildHooksVariableName, '0', asEnv: true);
});

Future<void> downloadLibsodium() async {
  final downloadDir = Directory.fromUri(
    Directory.current.uri.resolve('3rdparty/'),
  );

  if (downloadDir.existsSync()) {
    await downloadDir.delete(recursive: true);
  }
  await downloadDir.create(recursive: true);

  final httpClient = HttpClient();
  try {
    final archive = await httpClient.download(
      downloadDir,
      _libsodiumDownloadUri,
    );
    await Minisign.verify(archive, libsodiumSigningKey);
    await Archive.extract(archive: archive, outDir: downloadDir);
  } catch (e) {
    await downloadDir.delete(recursive: true);
    rethrow;
  } finally {
    httpClient.close();
  }
}
