import 'dart:async';
import 'dart:io';

import 'package:dart_test_tools/tools.dart';
import 'package:sodium/src/hooks/constants.dart';

import 'package:sodium/src/js/update_web/js_library_loader.dart';

const _defaultOutDir = 'test/integration/binaries/js';

Future<void> main() => Github.runZoned(() async {
  final tmpDir = await Directory.systemTemp.createTemp();
  try {
    await _createJsSrc(
      distRef: HookConstants.jsDist,
      outFileName: 'sodium.js.dart',
    );
    await _createJsSrc(
      distRef: HookConstants.jsSumoDist,
      outFileName: 'sodium_sumo.js.dart',
    );
  } finally {
    Github.logInfo('Cleaning up');
    await tmpDir.delete(recursive: true);
  }
});

Future<void> _createJsSrc({
  required JsDistRef distRef,
  required String outFileName,
}) => Github.logGroupAsync(
  'Downloading ${distRef.path} to $outFileName',
  () async {
    const repoLoader = JsLibraryLoader();

    final jsTestDir = Directory(_defaultOutDir);
    await jsTestDir.create(recursive: true);
    final sodiumTestJs = jsTestDir.subFile(outFileName);
    final sodiumTestJsSink = sodiumTestJs.openWrite();
    try {
      sodiumTestJsSink.writeln('const sodiumJsSrc = r"""');
      await repoLoader.downloadInto(distRef, sodiumTestJsSink);
      sodiumTestJsSink.writeln('""";');
    } finally {
      await sodiumTestJsSink.close();
    }
  },
);
