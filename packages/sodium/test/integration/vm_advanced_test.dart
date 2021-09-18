import 'dart:async';

// dart_pre_commit:ignore-library-import
import 'package:sodium/sodium.sumo.dart';

import 'cases/advanced/advanced_scalarmult_case.dart';
import 'test_case.dart';
import 'vm_common_test.dart';

class VmAdvancedTestRunner extends VmCommonTestRunner {
  VmAdvancedTestRunner() : super(isSumoTest: true);

  @override
  Future<AdvancedSodium> loadSodium() async {
    final dylib = await loadSodiumDylib();
    return SodiumInit.initSumo(dylib);
  }

  @override
  Iterable<TestCase> createTestCases() => [
        AdvancedScalarMultTestCase(this),
      ];
}

void main() {
  VmAdvancedTestRunner().setupTests();
}
