import 'dart:async';

// dart_pre_commit:ignore-library-import
import 'package:sodium/sodium.dart';

import 'vm_common_test.dart';

class VmStandardTestRunner extends VmCommonTestRunner {
  VmStandardTestRunner() : super(isSumoTest: false);

  @override
  Future<Sodium> loadSodium() async {
    final dylib = await loadSodiumDylib();
    return SodiumInit.init(dylib);
  }
}

void main() {
  VmStandardTestRunner().setupTests();
}
