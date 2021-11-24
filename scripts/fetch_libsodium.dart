import 'dart:convert';
import 'dart:io';

import 'fetch_libsodium/android.dart';
import 'fetch_libsodium/fetch.dart';

Future<void> main(List<String> arguments) async {
  String? targetPlatform;
  if (arguments.isNotEmpty) {
    targetPlatform = arguments.first;
  }

  final fetchTargets = <Fetch>[];
  if (targetPlatform == null || targetPlatform == 'android') {
    fetchTargets.add(FetchAndroid());
  }

  if (targetPlatform != null && fetchTargets.isEmpty) {
    stderr.writeln('WARNING: Unsupported platform: $targetPlatform');
    return;
  }

  final versionFile = File.fromUri(
    Directory.current.uri.resolve(
      'packages/sodium_libs/libsodium_version.json',
    ),
  );
  final version = SodiumVersion.fromJson(
    json.decode(await versionFile.readAsString()),
  );
  for (final fetchTarget in fetchTargets) {
    await fetchTarget(version: version);
  }
}
