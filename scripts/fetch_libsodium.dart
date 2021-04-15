import 'dart:convert';
import 'dart:io';

const _libsodiumSigningKey =
    'RWQf6LRCGA9i53mlYecO4IzT51TGPpvWucNSCh1CBM0QTaLn73Y7GFO3';

Future<void> main(List<String> arguments) async {
  String? targetPlatform;
  if (arguments.isNotEmpty) {
    targetPlatform = arguments.first;
  }

  final versionFile = File.fromUri(
    Directory.current.uri.resolve('libsodium_version.json'),
  );
  await versionFile.assertExists();

  final jsonData = json.decode(await versionFile.readAsString());
  final ffiVersion = jsonData['ffi'] as String;
  final jsVersion = jsonData['js'] as String;

  if (targetPlatform == null || targetPlatform == 'windows') {
    await _downloadWinLibrary(ffiVersion);
  }
  if (targetPlatform == null || targetPlatform == 'web') {
    await _downloadJsLibrary(jsVersion);
  }
}

Future<void> _downloadWinLibrary(String version) async {
  final releaseDir = await _downloadRelease(
    version,
    platform: 'msvc',
    isZip: true,
  );
  try {
    final libsodiumDll = File.fromUri(
      releaseDir.uri
          .resolve('libsodium/x64/Release/v142/dynamic/libsodium.dll'),
    );
    await libsodiumDll.assertExists();

    // copy to sodium integration test
    final winTestDir = Directory.fromUri(
      Directory.current.uri
          .resolve('packages/sodium/test/integration/binaries/win'),
    );
    await winTestDir.create(recursive: true);
    await libsodiumDll.copy(
      winTestDir.uri.resolve('libsodium.dll').toFilePath(),
    );
  } finally {
    await releaseDir.delete(recursive: true);
  }
}

Future<void> _downloadJsLibrary(String version) async {
  final tmpDir = await Directory.systemTemp.createTemp();
  try {
    await _runSubProcess(
      'git',
      [
        'clone',
        '-b',
        version,
        '--depth',
        '1',
        'https://github.com/jedisct1/libsodium.js.git',
        '.',
      ],
      tmpDir,
    );

    final sodiumJsFile = File.fromUri(
      tmpDir.uri.resolve('dist/browsers/sodium.js'),
    );
    await sodiumJsFile.assertExists();

    // copy to sodium integration tests
    final jsTestDir = Directory.fromUri(
      Directory.current.uri
          .resolve('packages/sodium/test/integration/binaries/js'),
    );
    await jsTestDir.create(recursive: true);
    final sodiumTestJs = File.fromUri(jsTestDir.uri.resolve('sodium.js.dart'));
    final sodiumTestJsSink = sodiumTestJs.openWrite();
    try {
      sodiumTestJsSink.writeln('const sodiumJsSrc = r"""');
      await sodiumTestJsSink.addStream(sodiumJsFile.openRead());
      sodiumTestJsSink.writeln('""";');
    } finally {
      await sodiumTestJsSink.close();
    }
  } finally {
    await tmpDir.delete(recursive: true);
  }
}

Future<Directory> _downloadRelease(
  String version, {
  String? platform,
  bool isZip = false,
}) async {
  final baseUri = Uri.https('download.libsodium.org', '/libsodium/releases/');
  final fileName = 'libsodium-$version-stable'
      '${platform != null ? '-$platform' : ''}'
      '.${isZip ? 'zip' : 'tar.gz'}';

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
    await _runSubProcess('minisign', [
      '-P',
      _libsodiumSigningKey,
      '-Vm',
      archiveFile.path,
    ]);

    // unpack
    stdout.writeln('Unpacking...');
    await _runSubProcess('7z', [
      'x',
      '-y',
      '-o${tmpDir.path}',
      archiveFile.path,
    ]);

    return tmpDir;
  } catch (e) {
    await tmpDir.delete(recursive: true);
    rethrow;
  } finally {
    httpClient.close();
  }
}

Stream<List<int>> _streamSubProcess(
  String executable,
  List<String> arguments, [
  Directory? pwd,
]) async* {
  final result = await Process.start(
    executable,
    arguments,
    workingDirectory: pwd?.path,
  );
  stderr.addStream(result.stderr);
  yield* result.stdout;
  final exitCode = await result.exitCode;
  if (exitCode != 0) {
    throw Exception('Failed to run $executable with exit code: $exitCode');
  }
}

Future<void> _runSubProcess(
  String executable,
  List<String> arguments, [
  Directory? pwd,
]) =>
    _streamSubProcess(executable, arguments, pwd).drain();

extension FileSystemEntityX on FileSystemEntity {
  Future<void> assertExists() async {
    if (!await exists()) {
      throw Exception('File $path does not exists');
    }
  }
}

extension HttpClientX on HttpClient {
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
      outSink.close();
      rethrow;
    }
  }
}
