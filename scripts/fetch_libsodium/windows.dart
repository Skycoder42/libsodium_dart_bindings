import 'dart:io';

import 'common.dart';
import 'fetch.dart';

class FetchWindows with FetchCommon implements Fetch {
  static const defaultOutDir = 'packages/sodium/test/integration/binaries/win';
  static const defaultArch = 'x64';
  static const defaultMode = 'Release';
  static const defaultVsVersion = 'v142';

  Future<void> call({
    required SodiumVersion version,
    String outDir = defaultOutDir,
    String arch = defaultArch,
    String mode = defaultMode,
    String vsVersion = defaultVsVersion,
  }) async {
    final releaseDir = await downloadRelease(
      version.ffiVersion,
      platform: 'msvc',
      isZip: true,
    );
    try {
      final libsodiumDll = File.fromUri(
        releaseDir.uri
            .resolve('libsodium/$arch/$mode/$vsVersion/dynamic/libsodium.dll'),
      );
      await libsodiumDll.assertExists();

      // copy to sodium integration testfelixf
      final winTestDir = Directory(outDir);
      await winTestDir.create(recursive: true);
      await libsodiumDll.copy(
        winTestDir.uri.resolve('libsodium.dll').toFilePath(),
      );
    } finally {
      await releaseDir.delete(recursive: true);
    }
  }
}
