import 'dart:io';

import '../../libsodium_version.dart';

Future<void> main(List<String> args) async {
  final [platform, outDir] = args;
  // TODO from group ?
  final suffix = platform == 'windows' ? '.zip' : '.tar.xz';
  final name = 'libsodium-${libsodium_version.ffi}-$platform$suffix';

  Directory.current = 'libsodium';
  final archiveFile = File(name);
  final urlFile = File('$name.url');
  final hashFile = File('$name.sha512');
  try {} on Exception {
    await archiveFile.delete();
    rethrow;
  }
}

Future<int> _exec(List<String> command) async {
  final process = await Process.start(
    command.first,
    command.skip(1).toList(),
    mode: ProcessStartMode.inheritStdio,
  );

  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    throw Exception('$command failed with exit code: $exitCode');
  }
  return exitCode;
}
