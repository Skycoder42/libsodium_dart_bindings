import 'dart:io';

import 'package:dart_test_tools/tools.dart';

import '../../hook/build.dart';
import 'constants.dart';

Future<void> main() => Github.runZoned(() async {
  await downloadLibsodium();
  await Github.env.setOutput(skipBuildHooksVariableName, '0', asEnv: true);
});

Future<Uri> downloadLibsodium() async {
  await Github.logGroupAsync(
    'Ensure minisign is installed',
    Minisign.ensureInstalled,
  );

  return await Github.logGroupAsync(
    'Download and verify libsodium v${libsodiumVersion.ffi}',
    _downloadLibsodium,
  );
}

Future<Uri> _downloadLibsodium() async {
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

    return archive.uri;
  } catch (e) {
    await downloadDir.delete(recursive: true);
    rethrow;
  } finally {
    httpClient.close();
  }
}
