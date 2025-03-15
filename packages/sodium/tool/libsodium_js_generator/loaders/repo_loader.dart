import 'dart:io';

import 'package:dart_test_tools/tools.dart';

class RepoLoader {
  Future<Directory> downloadRepo(String tag) async {
    final downloadUri = Uri.https(
      'github.com',
      '/jedisct1/libsodium.js/archive/refs/tags/$tag.tar.gz',
    );

    final client = HttpClient();
    try {
      final archive = await client.download(
        Github.env.runnerTemp,
        downloadUri,
        withSignature: false,
      );
      await Archive.extract(archive: archive, outDir: Github.env.runnerTemp);
      return Github.env.runnerTemp
          .subDir('libsodium.js-$tag')
          .subDir('wrapper');
    } finally {
      client.close();
    }
  }
}
