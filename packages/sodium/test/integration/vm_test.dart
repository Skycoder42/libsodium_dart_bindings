@TestOn('dart-vm')
library;

import 'dart:async';
import 'dart:ffi';
import 'dart:io';

// ignore: no_self_package_imports
import 'package:sodium/sodium_sumo.dart';
import 'package:test/test.dart';

import 'test_runner.dart';

class VmTestRunner extends SumoTestRunner {
  VmTestRunner();

  @override
  bool get is32Bit => sizeOf<IntPtr>() == 4;

  @override
  Future<SodiumSumo> loadSodium() {
    String libSodiumPath;
    if (Platform.isLinux) {
      libSodiumPath = 'test/integration/binaries/linux/lib/libsodium.so';
    } else if (Platform.isWindows) {
      libSodiumPath =
          'test/integration/binaries/windows/x64/Release/v143/dynamic/libsodium.dll';
    } else if (Platform.isMacOS) {
      libSodiumPath = 'test/integration/binaries/macos/lib/libsodium.dylib';
    } else {
      fail('Operating system ${Platform.operatingSystem} not supported');
    }

    final libSodiumFile = File(libSodiumPath).absolute;

    expect(libSodiumFile.existsSync(), isTrue);
    // ignore: avoid_print
    print('Found libsodium at: ${libSodiumFile.path}');
    return SodiumSumoInit.init(() => DynamicLibrary.open(libSodiumFile.path));
  }
}

void main() {
  VmTestRunner().setupTests();
}
