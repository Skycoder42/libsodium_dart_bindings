import 'dart:io';

mixin FetchCommon {
  static const libsodiumSigningKey =
      'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3';

  Future<Directory> downloadRelease(
    String version, {
    String? platform,
    bool isZip = false,
  }) async {
    final baseUri = Uri.https('download.libsodium.org', '/libsodium/releases/');
    final platformStr = platform != null ? '-$platform' : '';
    final suffixStr = isZip ? 'zip' : 'tar.gz';
    final fileName = 'libsodium-$version-stable$platformStr.$suffixStr';

    final httpClient = HttpClient();
    final tmpDir = await Directory.systemTemp.createTemp();
    try {
      // download files
      final archiveFile = await httpClient.download(
        tmpDir,
        baseUri.resolve(fileName),
      );
      await httpClient.download(
        tmpDir,
        baseUri.resolve('$fileName.minisig'),
      );

      // verify signature
      stdout.writeln('Checking signature...');
      await runSubProcess('minisign', [
        '-P',
        libsodiumSigningKey,
        '-Vm',
        archiveFile.path,
      ]);

      // unpack
      stdout.writeln('Unpacking...');
      if (isZip) {
        await runSubProcess('7z', [
          'x',
          '-y',
          '-o${tmpDir.path}',
          archiveFile.path,
        ]);
      } else {
        await runSubProcess(
          'tar',
          ['xzf', archiveFile.path],
          tmpDir,
        );
      }

      return tmpDir;
    } catch (e) {
      await tmpDir.delete(recursive: true);
      rethrow;
    } finally {
      httpClient.close();
    }
  }

  Stream<List<int>> streamSubProcess(
    String executable,
    List<String> arguments, [
    Directory? pwd,
  ]) async* {
    final result = await Process.start(
      executable,
      arguments,
      workingDirectory: pwd?.path,
    );
    // ignore: unawaited_futures
    stderr.addStream(result.stderr);
    yield* result.stdout;
    final exitCode = await result.exitCode;
    if (exitCode != 0) {
      throw Exception('Failed to run $executable with exit code: $exitCode');
    }
  }

  Future<void> runSubProcess(
    String executable,
    List<String> arguments, [
    Directory? pwd,
  ]) =>
      streamSubProcess(executable, arguments, pwd).drain();
}

extension DirectoryX on Directory {
  Directory subDir(String path) => Directory.fromUri(uri.resolve(path));

  File subFile(String path) => File.fromUri(uri.resolve(path));
}

extension _HttpClientX on HttpClient {
  Future<File> download(Directory targetDir, Uri uri) async {
    final request = await getUrl(uri);
    final response = await request.close();
    final outFile = File.fromUri(targetDir.uri.resolve(uri.pathSegments.last));
    final outSink = outFile.openWrite();
    try {
      stdout.writeln('Downloading $uri...');
      await response.pipe(outSink);
      return outFile;
    } catch (e) {
      await outSink.close();
      rethrow;
    }
  }
}

extension FileSystemEntityX on FileSystemEntity {
  Future<void> assertExists() async {
    if (!await exists()) {
      throw Exception('File $path does not exists');
    }
  }
}
