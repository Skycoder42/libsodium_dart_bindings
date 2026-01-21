@TestOn('dart-vm')
library;

import 'dart:async';
import 'dart:ffi';

import 'package:sodium/sodium_sumo.dart';
import 'package:test/test.dart';

import 'test_runner.dart';

class VmTestRunner extends SumoTestRunner {
  VmTestRunner();

  @override
  bool get is32Bit => sizeOf<IntPtr>() == 4;

  @override
  FutureOr<SodiumSumo> loadSodium() => SodiumSumoInit.init();
}

void main() {
  VmTestRunner().setupTests();
}
