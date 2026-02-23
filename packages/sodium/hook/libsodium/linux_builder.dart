import 'package:code_assets/code_assets.dart';

import 'automake_builder.dart';

final class LinuxBuilder extends AutomakeBuilder {
  const LinuxBuilder(super.config);

  @override
  Future<Map<String, String>> get environment async {
    final cFlags = ['-Os'];
    return {...await super.environment, 'CFLAGS': cFlags.join(' ')};
  }

  @override
  Future<List<String>> get configureArgs async => [
    ...await super.configureArgs,
    '--host=${_mapArch(config.targetArchitecture)}-unknown-linux-gnu',
  ];

  // See https://wiki.debian.org/Multiarch/Tuples
  String _mapArch(Architecture arch) => switch (arch) {
    .arm => 'arm',
    .arm64 => 'aarch64',
    .ia32 => 'i386',
    .riscv32 => 'riscv',
    .riscv64 => 'riscv64',
    .x64 => 'x86_64',
    _ => throw UnsupportedError('Unsupported linux architecture: $arch'),
  };
}
