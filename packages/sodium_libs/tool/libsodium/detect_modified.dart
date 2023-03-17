import 'dart:io';

import '../../libsodium_version.dart';
import 'common.dart';
import 'platforms/plugin_targets.dart';

Future<void> main() => GithubEnv.run(() async {
      final downloadUrls =
          PluginTargets.values.map((t) => t.downloadUrl).toSet();

      final lastModifiedMap = <Uri, String>{};
      final httpClient = HttpClient();
      try {
        for (final downloadUrl in downloadUrls) {
          GithubEnv.logNotice('Getting last modified header for: $downloadUrl');
          final lastModifiedHeader = await httpClient.getHeader(
            downloadUrl,
            HttpHeaders.lastModifiedHeader,
          );

          lastModifiedMap[downloadUrl] = lastModifiedHeader;
        }
      } finally {
        httpClient.close(force: true);
      }

      final newLastModified = _buildLastModifiedFile(lastModifiedMap);
      final oldLastModified = await getLastModifiedFile().readAsString();

      if (newLastModified != oldLastModified) {
        GithubEnv.logNotice('At least one upstream archive has been modified!');
        await GithubEnv.setOutput('modified', true);
        await GithubEnv.setOutput('version', libsodium_version.ffi);
        await GithubEnv.setOutput(
          'last-modified-content',
          newLastModified,
          multiline: true,
        );
      } else {
        GithubEnv.logNotice('All upstream archives are unchanged');
      }
    });

String _buildLastModifiedFile(Map<Uri, String> lastModifiedMap) {
  final lines = lastModifiedMap.entries
      .map((e) => '${e.key} - ${e.value}\n')
      .toList()
    ..sort();
  return lines.join();
}

extension _HttpClientX on HttpClient {
  Future<String> getHeader(Uri url, String headerName) async {
    final headRequest = await headUrl(url);
    final headResponse = await headRequest.close();
    headResponse.drain<void>().ignore();
    if (headResponse.statusCode >= 300) {
      throw StatusCodeException(headResponse.statusCode);
    }

    final header = headResponse.headers[headerName];
    if (header == null || header.isEmpty) {
      throw Exception(
        'Unable to get header $header from $url: Header is not set',
      );
    }

    return header.first;
  }
}
