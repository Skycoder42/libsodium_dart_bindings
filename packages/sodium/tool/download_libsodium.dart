import 'dart:io';

import 'package:dart_test_tools/tools.dart';

import '../../sodium_libs/libsodium_version.dart';

final baseUri = Uri.https(
  'download.libsodium.org',
  '/libsodium/releases/libsodium-${libsodium_version.ffi}-stable.tar.gz',
);

Future<void> main(List<String> args) async {
  final downloadDir = Directory.fromUri(
    Directory.current.uri.resolve('3rdparty/'),
  );
  if (downloadDir.existsSync()) {
    await downloadDir.delete(recursive: true);
  }
  await downloadDir.create(recursive: true);

  final httpClient = HttpClient();
  try {
    final archive = await httpClient.download(downloadDir, baseUri);
    await Minisign.verify(archive, libsodiumSigningKey);
    await Archive.extract(archive: archive, outDir: downloadDir);
  } catch (e) {
    await downloadDir.delete(recursive: true);
    rethrow;
  } finally {
    httpClient.close();
  }
}
