import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';
import 'package:sodium/src/hooks/common/hook_logger.dart';
import 'package:sodium/src/hooks/constants.dart';
import 'package:sodium/src/hooks/sodium_builder/sodium_builder.dart';

void main(List<String> args) async => await build(args, (input, output) async {
  final logger = HookLogger(
    'sodium',
    logDebug: _isSet(HookConstants.debugLogEnvVarName),
  );

  if (_isSet(HookConstants.skipBuildHooksEnvVarName)) {
    logger.warning(
      'Skipping sodium build hooks because environment variable '
      '${HookConstants.skipBuildHooksEnvVarName} is set.',
    );
    return;
  }

  final sourceArchive = input.packageRoot.resolveUri(
    HookConstants.libsodiumArchive,
  );
  if (!File.fromUri(sourceArchive).existsSync()) {
    throw Exception(
      'libsodium source archive does not exist! This should not be possible. '
      'Please report this to the package maintainers.',
    );
  }

  final config = input.config.code;
  final builder = SodiumBuilder.forConfig(config, logger);
  final asset = await builder.build(
    input: input,
    sourceArchive: sourceArchive,
    exportHeadersTo: _isSet(HookConstants.exportHeadersEnvVarName)
        ? HookConstants.libsodiumHeadersLocation
        : null,
  );

  output.assets.code.add(asset);
});

bool _isSet(String envVar) => Platform.environment[envVar] == '1';
