import 'dart:io';

import 'package:dart_test_tools/tools.dart';
import 'package:sodium/src/hooks/constants.dart';

class RepoLoader {
  Future<Directory> downloadRepo(LibsodiumVersion version) async {
    final downloadUri = Uri.https(
      'github.com',
      '/jedisct1/libsodium.js/archive/${version.jsRef}.tar.gz',
    );

    final client = HttpClient();
    try {
      final archive = await client.download(
        Github.env.runnerTemp,
        downloadUri,
        withSignature: false,
      );
      await Archive.extract(archive: archive, outDir: Github.env.runnerTemp);

      final nameSegment = version.jsRef.split('/').last;
      return Github.env.runnerTemp.subDir('libsodium.js-$nameSegment');
    } finally {
      client.close();
    }
  }
}
