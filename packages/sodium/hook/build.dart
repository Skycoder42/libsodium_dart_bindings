import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

import 'libsodium/build_common.dart';
import 'libsodium/download.dart';

void main(List<String> args) async => await build(args, (input, output) async {
  final config = input.config.code;

  if (config.targetOS == .macOS) {
    final sourceDir = await downloadLibsodium(input);

    final builder = BuildCommon.forOs(config.targetOS);
    final installDir = await builder.build(input: input, sourceDir: sourceDir);

    final sourceLib = Uri.file(
      await File(
        installDir.resolve('lib/libsodium.dylib').toFilePath(),
      ).resolveSymbolicLinks(),
    );

    output.assets.code.add(
      CodeAsset(
        package: 'sodium',
        name: 'libsodium',
        linkMode: /*linkStatic ? StaticLinking() :*/ DynamicLoadingBundled(),
        file: sourceLib,
      ),
    );
  } else {
    throw UnsupportedError('Unsupported OS: ${config.targetOS}');
  }
});
