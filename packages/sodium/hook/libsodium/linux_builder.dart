import 'package:code_assets/code_assets.dart';

import 'automake_builder.dart';

final class LinuxBuilder extends AutomakeBuilder {
  const LinuxBuilder(super.config);

  @override
  Map<String, String> get environment {
    final cFlags = ['-Os'];
    return {...super.environment, 'CFLAGS': cFlags.join(' ')};
  }

  @override
  Iterable<String> get configureArgs sync* {
    yield* super.configureArgs;
    yield '--host=${_mapHost(config.targetArchitecture)}';
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
