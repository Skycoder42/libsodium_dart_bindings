import 'dart:convert';
import 'dart:io';

import 'package:dart_test_tools/tools.dart';

import 'platforms/plugin_platform.dart';

Future<void> main(List<String> args) async {
  final targetHashSums = _getHashSums(args[0]);
  final releaseAssets = _getReleaseAssets(args[1]);

  for (final (target, digest, isExtra) in targetHashSums) {
    final url = releaseAssets
        .where((a) => a['name'] == target.artifactName)
        .map((a) => a['browser_download_url'] as String)
        .single;

    if (isExtra) {
      switch (target) {
        case PluginPlatform.darwin:
          await _updateSwiftPackage(url, digest);
        // ignore: no_default_cases
        default:
          throw UnsupportedError('Unexpected extra for $target');
      }
    } else {
      final targetDir = await Directory.current
          .subDir(target.name)
          .subDir('libsodium')
          .create(recursive: true);
      await targetDir
          .subFile(target.hashFilePath)
          .writeAsString('$digest  ${target.artifactName}');

      await targetDir.subFile(target.urlFilePath).writeAsString(url);
    }
  }
}

Iterable<(PluginPlatform, String, bool)> _getHashSums(String arg) =>
    (json.decode(arg) as Map<String, dynamic>)
        .entries
        .map((e) => (PluginPlatform.values.byName(e.key), e.value))
        .expand((pair) sync* {
      switch (pair.$2) {
        case final String single:
          yield (pair.$1, single, false);
        case [final String first, final String second]:
          yield (pair.$1, first, false);
          yield (pair.$1, second, true);
        default:
          throw UnsupportedError('Unexpected map entry: $pair');
      }
    });

List<Map<String, dynamic>> _getReleaseAssets(String arg) =>
    (json.decode(arg) as List).cast<Map<String, dynamic>>();

Future<void> _updateSwiftPackage(String url, String digest) async {
  final pluginName = Directory.current.uri.pathSegments.last;
  final packageFile =
      Directory.current.subDir(pluginName).subFile('Package.swift');

  var packageContents = await packageFile.readAsString();
  packageContents = packageContents
      .replaceFirst(RegExp('url: ".*"'), 'url: "$url"')
      .replaceFirst(RegExp('checksum: ".*"'), 'checksum: "$digest"');
  await packageFile.writeAsString(packageContents, flush: true);
}
