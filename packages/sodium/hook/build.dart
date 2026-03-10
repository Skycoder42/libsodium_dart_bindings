import 'dart:io';

import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

import '../tool/libsodium/constants.dart';
import 'common/hook_logger.dart';
import 'libsodium/sodium_builder.dart';

/// special environment variable to skip build hooks. Must be prefixed by
/// "NIX_" as otherwise it would be stripped.
///
/// See https://dart.dev/tools/hooks#environment-variables
const skipBuildHooksVariableName = 'NIX_SKIP_SODIUM_BUILD_HOOKS';

void main(List<String> args) async => await build(args, (input, output) async {
  final logger = HookLogger('sodium');

  if (Platform.environment[skipBuildHooksVariableName] == '1') {
    logger.warning(
      'Skipping sodium build hooks because environment variable '
      '$skipBuildHooksVariableName is set.',
    );
    return;
  }

  final sourceArchive = input.packageRoot.resolve(
    '3rdparty/libsodium-${libsodiumVersion.ffi}-stable.tar.gz',
  );
  if (!File.fromUri(sourceArchive).existsSync()) {
    throw Exception(
      'libsodium source archive does not exist! This should not be possible. '
      'Please report this to the package maintainers.',
    );
  }

  final config = input.config.code;
  final builder = SodiumBuilder.forConfig(config, logger);
  final asset = await builder.build(input: input, sourceArchive: sourceArchive);

  output.assets.code.add(asset);
});
