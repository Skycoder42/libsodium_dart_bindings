import 'dart:io';

import 'package:dart_test_tools/tools.dart';
import 'package:sodium/src/hooks/constants.dart';

Future<void> main() => Github.runZoned(() async {
  await downloadLibsodium();
  await Github.env.setOutput(
    HookConstants.skipBuildHooksEnvVarName,
    '0',
    asEnv: true,
  );
});

Future<Uri> downloadLibsodium() async {
  await Github.logGroupAsync(
    'Ensure minisign is installed',
    Minisign.ensureInstalled,
  );

  return await Github.logGroupAsync(
    'Download and verify libsodium v${HookConstants.libsodiumVersion.ffi}',
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
      HookConstants.libsodiumSrcDownloadUri,
    );
    await Minisign.verify(archive, HookConstants.libsodiumSigningKey);
    return archive.uri;
  } catch (_) {
    await downloadDir.delete(recursive: true);
    rethrow;
  } finally {
    httpClient.close();
  }
}
