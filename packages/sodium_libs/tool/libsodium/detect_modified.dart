import 'dart:io';

import 'package:dart_test_tools/tools.dart';

import '../../libsodium_version.dart';
import 'platforms/plugin_targets.dart';

class StatusCodeException implements Exception {
  final int statusCode;

  StatusCodeException(this.statusCode);

  @override
  String toString() => 'Request failed with status code $statusCode';
}

Future<void> main() => Github.runZoned(() async {
      final downloadUrls =
          PluginTargets.allTargets.map((t) => t.downloadUrl).toSet();

      final lastModifiedMap = <Uri, String>{};
      final httpClient = HttpClient();
      try {
        for (final downloadUrl in downloadUrls) {
          Github.logInfo(
            'Getting last modified header for: $downloadUrl',
          );
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
      final lastModifiedFile = _getLastModifiedFile();
      if (lastModifiedFile.existsSync()) {
        final oldLastModified = await _getLastModifiedFile().readAsString();
        if (newLastModified == oldLastModified) {
          Github.logNotice('All upstream archives are unchanged');
          await _githubSetOutput('modified', false);
          return;
        }
      }

      Github.logNotice(
        'At least one upstream archive has been modified!',
      );
      await _githubSetOutput('modified', true);
      await _githubSetOutput('version', libsodium_version.ffi);
      await _githubSetOutput(
        'last-modified-content',
        newLastModified,
        multiline: true,
      );
    });

String _buildLastModifiedFile(Map<Uri, String> lastModifiedMap) {
  final lines = lastModifiedMap.entries
      .map((e) => '${e.key} - ${e.value}\n')
      .toList()
    ..sort();
  return lines.join();
}

File _getLastModifiedFile() => File('tool/libsodium/.last-modified.txt');

// TODO extract
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

Future<void> _githubSetOutput(
  String name,
  Object? value, {
  bool multiline = false,
}) async {
  final githubOutput = Platform.environment['GITHUB_OUTPUT'];
  if (githubOutput == null) {
    throw Exception('Cannot set output! GITHUB_OUTPUT env var is not set');
  }

  final githubOutputFile = File(githubOutput);
  if (multiline) {
    await githubOutputFile.writeAsString(
      '$name<<EOF\n${value}EOF\n',
      mode: FileMode.append,
    );
  } else {
    await githubOutputFile.writeAsString(
      '$name=$value\n',
      mode: FileMode.append,
    );
  }
}
