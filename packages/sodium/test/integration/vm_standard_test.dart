import 'dart:async';

// dart_pre_commit:ignore-library-import
import 'package:sodium/sodium.dart';

import 'cases/aead_test_case.dart';
import 'cases/auth_test_case.dart';
import 'cases/box_test_case.dart';
import 'cases/generic_hash_test_case.dart';
import 'cases/kdf_test_case.dart';
import 'cases/kx_test_case.dart';
import 'cases/pwhash_test_case.dart';
import 'cases/randombytes_test_case.dart';
import 'cases/secret_box_test_case.dart';
import 'cases/secret_stream_test_case.dart';
import 'cases/short_hash_test_case.dart';
import 'cases/sign_test_case.dart';
import 'cases/sodium_init_test_case.dart';
import 'cases/sodium_test_case.dart';
import 'test_case.dart';
import 'vm_common_test.dart';

class VmStandardTestRunner extends VmCommonTestRunner {
  VmStandardTestRunner() : super(isSumoTest: false);

  @override
  Future<Sodium> loadSodium() async {
    final dylib = await loadSodiumDylib();
    return SodiumInit.init(dylib);
  }

  @override
  Iterable<TestCase> createTestCases() => [
        SodiumTestCase(this),
        SodiumInitTestCase(this),
        RandombytesTestCase(this),
        SecretBoxTestCase(this),
        SecretStreamTestCase(this),
        AeadTestCase(this),
        AuthTestCase(this),
        BoxTestCase(this),
        SignTestCase(this),
        GenericHashTestCase(this),
        ShortHashTestCase(this),
        PwhashTestCase(this),
        KdfTestCase(this),
        KxTestCase(this),
      ];
}

void main() {
  VmStandardTestRunner().setupTests();
}
