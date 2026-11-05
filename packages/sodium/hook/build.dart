import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:sodium/src/hooks/common/hook_logger.dart';
import 'package:sodium/src/hooks/constants.dart';
import 'package:sodium/src/hooks/sodium_builder/sodium_builder.dart';

void main(List<String> args) async => await build(args, (input, output) async {
  final skipMissingBinaries = input.userDefines.getBool(
    'skip_missing_binaries',
  );
  final exportHeaders = input.userDefines.getBool('export_headers');
  final verbose = input.userDefines.getBool('verbose');

  final logger = HookLogger('sodium', logDebug: verbose);

  if (!input.config.buildCodeAssets) {
    logger.info(
      'Skipping sodium build hooks because build code assets is disabled in '
      'the config. Without building libsodium, the package will not work.',
    );
    return;
  }

  final sourceArchive = input.packageRoot.resolveUri(
    HookConstants.libsodiumArchive,
  );

  output.dependencies.add(sourceArchive);
  if (!File.fromUri(sourceArchive).existsSync()) {
    if (skipMissingBinaries) {
      logger.warning(
        'Skipping sodium build hooks because libsodium source archive does '
        'not exist. Without building libsodium, the package will not work.',
      );
      return;
    } else {
      throw Exception(
        'libsodium source archive does not exist! This should not be possible. '
        'Please report this to the package maintainers.',
      );
    }
  }

  final config = input.config.code;
  final builder = SodiumBuilder.forConfig(config, logger);
  final asset = await builder.build(
    input: input,
    sourceArchive: sourceArchive,
    exportHeadersTo: exportHeaders
        ? HookConstants.libsodiumHeadersLocation
        : null,
  );

  output.assets.code.add(asset);
});

extension on HookInputUserDefines {
  bool getBool(String key, {bool defaultValue = false}) => switch (this[key]) {
    null => defaultValue,
    final bool value => value,
    Object(:final runtimeType) => throw Exception(
      '"hooks.user_defines.sodium.$key" has an invalid type. '
      'Expected bool, got $runtimeType.',
    ),
  };
}
