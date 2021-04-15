import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:sodium/sodium.dart';

import 'test_runner.dart';

class VmTestRunner extends TestRunner {
  @override
  Future<Sodium> loadSodium() async {
    DynamicLibrary dylib;
    if (Platform.isLinux) {
      dylib = DynamicLibrary.open('/usr/lib/libsodium.so');
    } else if (Platform.isWindows) {
      final scriptDir = File.fromUri(Platform.script).parent;
      dylib = DynamicLibrary.open(
        scriptDir.uri.resolve('binaries/win/libsodium.dll').toFilePath(),
      );
    } else if (Platform.isMacOS) {
      final libDir = Directory('/usr/local/Cellar/libsodium');
      final subDirs = await libDir
          .list()
          .where((e) => e is Directory)
          .cast<Directory>()
          .toList();
      subDirs.sort((lhs, rhs) => lhs.path.compareTo(rhs.path));
      dylib = DynamicLibrary.open(
        '${subDirs.last}/lib/libsodium.dylib',
      );
    } else {
      throw UnsupportedError(
        'Operating system ${Platform.operatingSystem} not supported',
      );
    }

    return SodiumFFIInit.init(dylib);
  }
}

void main() {
  VmTestRunner().setupTests();
}
