import 'dart:async';

// dart_pre_commit:ignore-library-import
import 'package:sodium/sodium.dart';

import 'vm_test_common.dart';

class VmTestStandardRunner extends VmTestCommonRunner {
  VmTestStandardRunner() : super(isSumoTest: false);

  @override
  Future<Sodium> loadSodium() async {
    final dylib = await loadSodiumDylib();
    return SodiumInit.init(dylib);
  }
}

void main() {
  VmTestStandardRunner().setupTests();
}
