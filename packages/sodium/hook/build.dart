import 'package:code_assets/code_assets.dart';
import 'package:hooks/hooks.dart';

import 'libsodium/download.dart';
import 'libsodium/sodium_builder.dart';

void main(List<String> args) async => await build(args, (input, output) async {
  final config = input.config.code;

  final builder = SodiumBuilder.forConfig(config);

  final sourceDir = await downloadLibsodium(input);
  final asset = await builder.build(input: input, sourceDir: sourceDir);

  output.assets.code.add(asset);
});
