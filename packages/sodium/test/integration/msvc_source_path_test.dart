@TestOn('dart-vm')
library;

import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sodium/src/hooks/common/extractor.dart';
import 'package:sodium/src/hooks/common/hook_logger.dart';
import 'package:sodium/src/hooks/constants.dart';
import 'package:sodium/src/hooks/sodium_builder/windows_builder.dart';
import 'package:test/test.dart';

class MockHookLogger extends Mock implements HookLogger {}

// CodeConfig is a final class, so it cannot be mocked. Building the input
// creates its output directories, hence the temp dir.
CodeConfig createCodeConfig() {
  final dir = Directory.systemTemp.createTempSync('sodium_hook_input_');
  addTearDown(() => dir.deleteSync(recursive: true));

  return (BuildInputBuilder()
        ..setupShared(
          packageName: 'sodium',
          packageRoot: dir.uri,
          outputFile: dir.uri.resolve('output.json'),
          outputDirectoryShared: dir.uri.resolve('shared/'),
        )
        ..config.setupBuild(linkingEnabled: false)
        ..addExtension(
          CodeAssetExtension(
            targetArchitecture: Architecture.x64,
            targetOS: OS.windows,
            linkModePreference: LinkModePreference.dynamic,
          ),
        ))
      .build()
      .config
      .code;
}

void main() {
  // The characters WindowsBuilder subtracts from MAX_PATH come from the
  // archive layout, so they are checked against the archive rather than
  // restated. Lives here because 3rdparty is only downloaded for these tests.
  test('leaves room for the path msbuild hands to cl.exe', () {
    final sut = WindowsBuilder(createCodeConfig(), MockHookLogger());
    final archive = Extractor.extractArchive(
      Directory.current.uri.resolveUri(HookConstants.libsodiumArchive),
    );
    addTearDown(archive.clear);

    // Every name the build script can pick, see WindowsBuilder.
    for (final vsName in ['vs2017', 'vs2019', 'vs2022', 'vs2026']) {
      final projectDir = 'builds/msvc/$vsName/libsodium';
      final depth = projectDir.split('/').length;

      // Throws if the project is no longer where the build script looks.
      final sources = archive
          .readAsLines('libsodium-stable/$projectDir/libsodium.vcxproj')
          .expand((l) => RegExp(r'Include="([^"]*\.c)"').allMatches(l))
          .map((m) => m.group(1)!);

      expect(sources, isNotEmpty);
      expect(
        sources.every((s) => s.startsWith(r'..\' * depth)),
        isTrue,
        reason: '$vsName must reference its sources from $depth levels down',
      );

      // Covers #193: without this headroom an extracted path of 219 to 259
      // characters passes a bare MAX_PATH check, extracts in place instead of
      // falling back to a temporary directory, and then overruns cl.exe.
      final overhead = (projectDir.length + 1) + depth * 3;
      expect(sut.maxSourcePathLength, 259 - overhead);
      expect(sut.maxSourcePathLength, lessThan(219));
    }
  });
}
