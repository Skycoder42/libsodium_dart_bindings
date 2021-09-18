import 'dart:async';

// dart_pre_commit:ignore-library-import
import 'package:sodium/sodium.sumo.dart';

import 'vm_common_test.dart';

class VmAdvancedTestRunner extends VmCommonTestRunner {
  VmAdvancedTestRunner() : super(isSumoTest: true);

  @override
  Future<AdvancedSodium> loadSodium() async {
    final dylib = await loadSodiumDylib();
    return SodiumInit.initSumo(dylib);
  }
}

void main() {
  VmAdvancedTestRunner().setupTests();
}
