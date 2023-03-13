// ignore_for_file: avoid_print

import 'dart:io';

import '../../libsodium_version.dart';
import 'common.dart';

Future<void> main(List<String> args) async {
  final platform = CiPlatform.values.byName(args.first);

  if (!platform.lastModifiedFile.existsSync()) {
    await _setOutputs();
    return;
  }

  final lastModifiedContent = await platform.lastModifiedFile.readAsString();
  final httpClient = HttpClient();
  try {
    final lastModifiedHeader = await httpClient.getHeader(
      platform.downloadUrl,
      HttpHeaders.lastModifiedHeader,
    );

    if (lastModifiedHeader != lastModifiedContent) {
      await _setOutputs();
    }
  } finally {
    httpClient.close(force: true);
  }
}

Future<void> _setOutputs() async {
  await GithubEnv.setOutput('modified', true);
  await GithubEnv.setOutput('version', libsodium_version.ffi);
}

extension _HttpClientX on HttpClient {
  Future<String> getHeader(Uri url, String header) async {
    final headRequest = await headUrl(url);
    final headResponse = await headRequest.close();
    headResponse.drain<void>().ignore();
    if (headResponse.statusCode >= 300) {
      throw StatusCodeException(headResponse.statusCode);
    }

    final header = headResponse.headers[HttpHeaders.lastModifiedHeader];
    if (header == null || header.isEmpty) {
      throw Exception(
        'Unable to get header $header from $url: Header is not set',
      );
    }

    return header.first;
  }
}
