import 'dart:io';

import '../../../tool/util.dart' as util;
import '../libsodium_version.dart' show libsodium_version;

Future<void> main() async {
  final outDir = Directory('android/src/main/jniLibs');
  await outDir.create(recursive: true);

  final downloadUri = Uri.https(
    'github.com',
    '/Skycoder42/libsodium_dart_bindings/releases/download/libsodium-binaries%2Fandroid%2Fv${libsodium_version.ffi}/libsodium-android.tar.xz',
  );

  final httpClient = HttpClient();
  final tmpDir = await Directory.systemTemp.createTemp();
  try {
    final outFile = await httpClient.download(tmpDir, downloadUri);

    await util.run(
      'tar',
      ['-xvf', outFile.path],
      workingDirectory: outDir,
    );
  } finally {
    httpClient.close();
    await tmpDir.delete(recursive: true);
  }
}
