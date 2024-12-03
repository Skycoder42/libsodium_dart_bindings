import 'dart:io';

import '../../libsodium_version.dart';

Future<void> main(List<String> args) async {
  final [platform, outPath] = args;
  final suffix = platform == 'windows' ? '.zip' : '.tar.xz';
  final name = 'libsodium-${libsodium_version.ffi}-$platform$suffix';
  final outDir = Directory(outPath);

  Directory.current = 'libsodium';
  final archiveFile = File(name);
  final urlFile = File('$name.url');
  final hashFile = File('$name.sha512');

  final client = HttpClient();
  try {
    if (hashFile.existsSync()) {
      if (await _sha512sum(hashFile)) {
        return;
      }
      await archiveFile.delete();
    }

    final urlLines = await urlFile.readAsLines();
    await _download(Uri.parse(urlLines.first), archiveFile);
    if (!await _sha512sum(hashFile)) {
      throw Exception('SHA512 validation for ${archiveFile.path} failed!');
    }

    await outDir.delete(recursive: true);
    await outDir.create(recursive: true);
    await _extract(archiveFile, outDir);
  } on Exception {
    await archiveFile.delete();
    rethrow;
  } finally {
    client.close(force: true);
  }
}

Future<void> _download(Uri uri, File file) async {
  final client = HttpClient();
  final outSink = file.openWrite();
  try {
    final request = await client.getUrl(uri);
    final response = await request.close();
    if (response.statusCode != HttpStatus.ok) {
      throw Exception(
        'Request failed with status code: ${response.statusCode}',
      );
    }

    await outSink.addStream(response);
    await outSink.flush();
  } finally {
    client.close(force: true);
    await outSink.close();
  }
}

Future<bool> _sha512sum(File file) async {
  if (Platform.isMacOS) {
    return await _exec(['shasum', '-a512', '-c', file.path]) == 0;
  } else if (Platform.isWindows) {
    return await _exec(['certutil', '-hashfile', file.path, 'SHA512']) == 0;
  } else {
    return await _exec(['sha512sum', '-c', file.path]) == 0;
  }
}

Future<void> _extract(File archive, Directory outDir) async {
  if (archive.path.endsWith('.zip')) {
    if (Platform.isWindows) {
      await _run([
        'powershell',
        '-command',
        'Expand-Archive "${archive.path}" "${outDir.path}',
      ]);
    } else {
      await _run(['unzip', archive.path, '-d', outDir.path]);
    }
  } else {
    await _run(['tar', '-xvf', archive.path, '-C', outDir.path]);
  }
}

Future<void> _run(List<String> command) async {
  final result = await _exec(command);
  if (result != 0) {
    throw Exception('$command failed with exit code: $exitCode');
  }
}

Future<int> _exec(List<String> command) async {
  final process = await Process.start(
    command.first,
    command.skip(1).toList(),
    mode: ProcessStartMode.inheritStdio,
  );

  return await process.exitCode;
}
