import 'dart:io';

class ChildErrorException implements Exception {
  final int exitCode;

  ChildErrorException(this.exitCode);

  @override
  String toString() => 'Subprocess failed with exit code $exitCode';
}

Future<void> run(
  String executable,
  List<String> arguments, {
  bool runInShell = false,
  Directory? workingDirectory,
}) async {
  stdout.writeln('> Running $executable ${arguments.join(' ')}');
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
    final outFile = targetDir.subFile(uri.pathSegments.last);
    final outSink = outFile.openWrite();
    stdout.writeln('Downloading $uri...');
    await response.pipe(outSink);
    return outFile;
  }
}
