import 'dart:io';

import 'package:dart_test_tools/tools.dart';
import 'package:hooks/hooks.dart';

import '../../../sodium_libs/libsodium_version.dart';

final baseUri = Uri.https(
  'download.libsodium.org',
  '/libsodium/releases/libsodium-${libsodium_version.ffi}-stable.tar.gz',
);

Future<Directory> downloadLibsodium(BuildInput input) async {
  final cacheDirUri = input.outputDirectoryShared.resolve(
    'src/${libsodium_version.ffi}/',
  );
  final extractedDirUri = cacheDirUri.resolve('libsodium-stable/');

  final extractedDir = Directory.fromUri(extractedDirUri);
  if (extractedDir.existsSync()) {
    return extractedDir;
  }

  final cacheDir = Directory.fromUri(cacheDirUri);
  if (cacheDir.existsSync()) {
    cacheDir.deleteSync(recursive: true);
  }
  await cacheDir.create(recursive: true);

  final httpClient = HttpClient();
  try {
    final archive = await httpClient.download(cacheDir, baseUri);
    // await Minisign.verify(archive, libsodiumSigningKey);
    await Archive.extract(archive: archive, outDir: cacheDir);
  } catch (e) {
    if (extractedDir.existsSync()) {
      await extractedDir.delete(recursive: true);
    }
    rethrow;
  } finally {
    httpClient.close();
  }

  return extractedDir;
}
