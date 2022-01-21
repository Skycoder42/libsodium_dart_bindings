import 'dart:io';

const _libsodiumSigningKey =
    'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3';

class ChildErrorException implements Exception {
  final int exitCode;

  ChildErrorException(this.exitCode);

  @override
  String toString() => 'Subprocess failed with exit code $exitCode';
}

class StatusCodeException implements Exception {
  final int statusCode;

  StatusCodeException(this.statusCode);

  @override
  String toString() => 'Request failed with status code $statusCode';
}

Future<void> run(
  String executable,
  List<String> arguments, {
  bool runInShell = false,
  Directory? workingDirectory,
}) async {
  final pwdMsg =
      workingDirectory != null ? ' (in ${workingDirectory.path})' : '';
  stdout.writeln('>> Running $executable ${arguments.join(' ')}$pwdMsg');
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory?.path,
    mode: ProcessStartMode.inheritStdio,
    runInShell: runInShell,
  );
  final exitCode = await process.exitCode;
  if (exitCode != 0) {
    throw ChildErrorException(exitCode);
  }
}

Future<void> verify(File file) async {
  stdout.writeln('> Checking signature of ${file.path}');
  await run('minisign', [
    '-P',
    _libsodiumSigningKey,
    '-Vm',
    file.path,
  ]);
}

Future<void> extract({
  required File archive,
  required Directory outDir,
}) async {
  stdout.writeln('> Unpacking ${archive.path} to ${outDir.path}');
  final useTar = archive.path.endsWith('.tar.gz');
  if (useTar) {
    await run(
      'tar',
      ['-xzvf', archive.path],
      workingDirectory: outDir,
    );
  } else {
    await run('7z', [
      'x',
      '-y',
      '-o${outDir.path}',
      archive.path,
    ]);
  }
}

extension FileSystemEntityX on FileSystemEntity {
  Future<void> assertExists() async {
    if (!await exists()) {
      throw Exception('File $path does not exists');
    }
  }
}

extension DirectoryX on Directory {
  Directory subDir(String path) => Directory.fromUri(uri.resolve(path));

  File subFile(String path) => File.fromUri(uri.resolve(path));
}

extension HttpClientX on HttpClient {
  Future<File> download(
    Directory targetDir,
    Uri uri, {
    bool withSignature = false,
  }) async {
    final request = await getUrl(uri);
    final response = await request.close();
    if (response.statusCode >= 300) {
      throw StatusCodeException(response.statusCode);
    }

    final outFile = targetDir.subFile(uri.pathSegments.last);
    final outSink = outFile.openWrite();
    stdout.writeln('> Downloading $uri to ${outFile.path}');
    await response.pipe(outSink);

    if (withSignature) {
      final sigUri = uri.replace(path: uri.path + ".minisig");
      await download(targetDir, sigUri);
    }

    return outFile;
  }
}
