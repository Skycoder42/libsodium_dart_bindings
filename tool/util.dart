import 'dart:io';

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
  final pwdMsg = workingDirectory != null ? ' (in $workingDirectory)' : '';
  stdout.writeln('> Running $executable ${arguments.join(' ')}$pwdMsg');
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

extension DirectoryX on Directory {
  Directory subDir(String path) => Directory.fromUri(uri.resolve(path));

  File subFile(String path) => File.fromUri(uri.resolve(path));
}

extension HttpClientX on HttpClient {
  Future<File> download(Directory targetDir, Uri uri) async {
    final request = await getUrl(uri);
    final response = await request.close();
    if (response.statusCode >= 300) {
      throw StatusCodeException(response.statusCode);
    }

    final outFile = targetDir.subFile(uri.pathSegments.last);
    final outSink = outFile.openWrite();
    stdout.writeln('Downloading $uri...');
    await response.pipe(outSink);
    return outFile;
  }
}
