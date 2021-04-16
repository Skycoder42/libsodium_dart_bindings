import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:sodium/sodium.dart';
import 'package:test/test.dart';

import 'test_runner.dart';

class VmTestRunner extends TestRunner {
  @override
  Future<Sodium> loadSodium() async {
    String libSodiumPath;
    if (Platform.isLinux) {
      final ldConfigRes = await Process.run('ldconfig', const ['-p']);
      expect(ldConfigRes.exitCode, 0);
      libSodiumPath = (ldConfigRes.stdout as String)
          .split('\n')
          .map((e) => e.split('=>').map((e) => e.trim()).toList())
          .where((e) => e.length == 2)
          .map((e) => MapEntry(
                e[0].split(' ').first,
                e[1],
              ))
          .where((e) => e.key == 'libsodium.so')
          .map((e) => e.value)
          .first;
    } else if (Platform.isWindows) {
      final scriptDir = File.fromUri(Platform.script).parent;
      printOnFailure('scriptDir detected as: $scriptDir');
      printOnFailure('pwd detected as: ${Directory.current}');
      libSodiumPath =
          scriptDir.uri.resolve('binaries/win/libsodium.dll').toFilePath();
    } else if (Platform.isMacOS) {
      final libDir = Directory('/usr/local/Cellar/libsodium');
      final subDirs = await libDir
          .list()
          .where((e) => e is Directory)
          .cast<Directory>()
          .toList();
      expect(subDirs, isNotEmpty);
      subDirs.sort((lhs, rhs) => lhs.path.compareTo(rhs.path));
      libSodiumPath = '${subDirs.last.path}/lib/libsodium.dylib';
    } else {
      throw UnsupportedError(
        'Operating system ${Platform.operatingSystem} not supported',
      );
    }

    expect(File(libSodiumPath).existsSync(), isTrue);
    // ignore: avoid_print
    print('Found libsodium at: $libSodiumPath');
    final dylib = DynamicLibrary.open(libSodiumPath);
    return SodiumFFIInit.init(dylib);
  }
}

void main() {
  VmTestRunner().setupTests();
}
