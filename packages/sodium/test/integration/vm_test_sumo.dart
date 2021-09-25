import 'dart:async';

// dart_pre_commit:ignore-library-import
import 'package:sodium/sodium.sumo.dart';

import 'vm_test_common.dart';

class VmTestSumoRunner extends VmTestCommonRunner {
  VmTestSumoRunner() : super(isSumoTest: true);

  @override
  Future<AdvancedSodium> loadSodium() async {
    final dylib = await loadSodiumDylib();
    return SodiumInit.initSumo(dylib);
  }
}

void main() {
  VmTestSumoRunner().setupTests();
}
