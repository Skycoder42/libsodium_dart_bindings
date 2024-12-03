import 'dart:convert';
import 'dart:io';

import 'package:dart_test_tools/tools.dart';

import 'platforms/plugin_targets.dart';

Future<void> main(List<String> args) async {
  final targetHashsums = _getHashSums(args[0]);
  final releaseAssets = _getReleaseAssets(args[1]);

  for (final MapEntry(key: target, value: digest) in targetHashsums.entries) {
    final targetDir = await Directory.current
        .subDir(target.name)
        .subDir('libsodium')
        .create(recursive: true);
    await targetDir
        .subFile('${target.artifactName}.sha512')
        .writeAsString('$digest  ${target.artifactName}');

    final url = releaseAssets
        .where((a) => a['name'] == target.artifactName)
        .map((a) => a['browser_download_url'] as String)
        .single;
    await targetDir.subFile('${target.artifactName}.url').writeAsString(url);
  }
}

Map<PluginTargetGroup, String> _getHashSums(String arg) =>
    (json.decode(arg) as Map)
        .cast<String, String>()
        .map((k, v) => MapEntry(PluginTargets.groupFromName(k), v));

List<Map<String, dynamic>> _getReleaseAssets(String arg) =>
    (json.decode(arg) as List).cast<Map<String, dynamic>>();
