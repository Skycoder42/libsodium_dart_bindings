import 'dart:convert';
import 'dart:io';

import 'package:dart_test_tools/tools.dart';

import 'platforms/plugin_targets.dart';

Future<void> main(List<String> args) async {
  final targetHashsums = (json.decode(args.single) as Map)
      .cast<String, String>()
      .map((k, v) => MapEntry(PluginTargets.groupFromName(k), v));

  for (final MapEntry(key: target, value: digest) in targetHashsums.entries) {
    final targetDir = await Directory.current
        .subDir(target.name)
        .subDir(target.binaryDir)
        .create(recursive: true);
    final hashPath = targetDir.subFile('${target.artifactName}.sha512');
    await hashPath.writeAsString('$digest  ${target.artifactName}');
  }
}
