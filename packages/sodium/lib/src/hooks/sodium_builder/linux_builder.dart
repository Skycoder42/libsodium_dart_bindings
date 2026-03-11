import 'package:code_assets/code_assets.dart';
import 'package:meta/meta.dart';

import 'automake_builder.dart';

@internal
final class LinuxBuilder extends AutomakeBuilder {
  LinuxBuilder(super.config, super.logger);

  @override
  Map<String, String> get environment {
    final cFlags = ['-Os'];
    return {...super.environment, 'CFLAGS': cFlags.join(' ')};
  }

  @override
  Iterable<String> get configureArgs sync* {
    yield* super.configureArgs;
    final host = _mapHost(config.targetArchitecture);
    logger.debug('Detected host target: $host');
    yield '--host=$host';
  }

  // See https://wiki.debian.org/Multiarch/Tuples
  String _mapHost(Architecture arch) => switch (arch) {
    .arm => 'arm-unknown-linux-gnueabihf',
    .arm64 => 'aarch64-unknown-linux-gnu',
    .ia32 => 'i686-unknown-linux-gnu',
    .x64 => 'x86_64-unknown-linux-gnu',
    .riscv32 => 'riscv32-unknown-linux-gnu',
    .riscv64 => 'riscv64-unknown-linux-gnu',
    _ => throw UnsupportedError('Unsupported linux architecture: $arch'),
  };
}
